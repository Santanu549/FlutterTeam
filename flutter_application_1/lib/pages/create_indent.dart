import 'dart:async';
import 'dart:convert';

import 'package:cargo_flow/helperUI/custom_form_field.dart';
import 'package:cargo_flow/services/appwrite_auth_san.dart';
import 'package:cargo_flow/services/indent_service.dart';
import 'package:cargo_flow/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationSuggestion {
  const LocationSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;
}

class IndentFrom extends StatefulWidget {
  const IndentFrom({super.key});

  @override
  State<IndentFrom> createState() => _IndentFromState();
}

class _IndentFromState extends State<IndentFrom> {
  bool _isCalculatePressed = false;
  bool _isCreatePressed = false;
  bool _isCreatingIndent = false;
  bool _isFetchingLoadingPoint = false;
  bool _isSearchingLoadingSuggestions = false;
  bool _isSearchingUnloadingSuggestions = false;
  static const Color _fiveImageBackground = Color(0xFF4683D9);

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController itemTypeController = TextEditingController();
  final TextEditingController itemWeightController = TextEditingController();
  final TextEditingController loadingChargeController = TextEditingController();
  final TextEditingController unloadingChargeController =
      TextEditingController();
  final TextEditingController executiveNameController = TextEditingController();
  final TextEditingController executiveIdController = TextEditingController();
  final TextEditingController loadingController = TextEditingController();
  final TextEditingController unloadingController = TextEditingController();
  final IndentService _indentService = IndentService();
  final NotificationService _notificationService = NotificationService();
  final AuthServiceAppwrite _authServiceAppwrite = AuthServiceAppwrite();

  Timer? _loadingDebounce;
  Timer? _unloadingDebounce;
  List<LocationSuggestion> _loadingSuggestions = [];
  List<LocationSuggestion> _unloadingSuggestions = [];
  LocationSuggestion? _selectedLoadingSuggestion;
  LocationSuggestion? _selectedUnloadingSuggestion;
  String distance = "";

  @override
  void dispose() {
    _loadingDebounce?.cancel();
    _unloadingDebounce?.cancel();
    customerNameController.dispose();
    vehicleTypeController.dispose();
    itemTypeController.dispose();
    itemWeightController.dispose();
    loadingChargeController.dispose();
    unloadingChargeController.dispose();
    executiveNameController.dispose();
    executiveIdController.dispose();
    loadingController.dispose();
    unloadingController.dispose();
    super.dispose();
  }

  Future<Location?> getLocation(String address) async {
    try {
      final locations = await locationFromAddress(address);
      return locations.first;
    } catch (e) {
      debugPrint("Error: $e");
      return null;
    }
  }

  Future<void> _fillLoadingPointFromCurrentLocation() async {
    if (_isFetchingLoadingPoint) return;

    setState(() => _isFetchingLoadingPoint = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage("Please enable location service");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showMessage("Location permission denied");
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage("Location permission permanently denied");
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        _showMessage("Unable to get device location. Check GPS and try again.");
        return;
      }

      String resolvedAddress =
          "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final addressParts = [
            place.name,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode,
          ]
              .where((part) => part != null && part!.trim().isNotEmpty)
              .cast<String>()
              .toList();

          if (addressParts.isNotEmpty) {
            resolvedAddress = addressParts.join(", ");
          }
        }
      } catch (_) {
        _showMessage("Location found. Address lookup failed, using coordinates.");
      }

      setState(() {
        loadingController.text = resolvedAddress;
        _loadingSuggestions = [];
        _selectedLoadingSuggestion = LocationSuggestion(
          displayName: resolvedAddress,
          latitude: position!.latitude,
          longitude: position.longitude,
        );
      });
    } catch (e) {
      _showMessage("Location error: $e");
    } finally {
      if (mounted) {
        setState(() => _isFetchingLoadingPoint = false);
      }
    }
  }

  Future<List<LocationSuggestion>> _fetchLocationSuggestions(
    String query,
  ) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': query,
        'format': 'jsonv2',
        'limit': '5',
      },
    );

    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'cargo_flow_flutter_app/1.0',
        'Accept-Language': 'en',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load suggestions');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return LocationSuggestion(
        displayName: (map['display_name'] ?? '').toString(),
        latitude: double.tryParse((map['lat'] ?? '').toString()) ?? 0,
        longitude: double.tryParse((map['lon'] ?? '').toString()) ?? 0,
      );
    }).where((item) => item.displayName.isNotEmpty).toList();
  }

  void _scheduleSuggestionSearch({
    required String query,
    required bool isLoadingField,
  }) {
    final trimmedQuery = query.trim();

    if (isLoadingField) {
      _loadingDebounce?.cancel();
    } else {
      _unloadingDebounce?.cancel();
    }

    if (trimmedQuery.length < 3) {
      setState(() {
        if (isLoadingField) {
          _loadingSuggestions = [];
          _isSearchingLoadingSuggestions = false;
          _selectedLoadingSuggestion = null;
        } else {
          _unloadingSuggestions = [];
          _isSearchingUnloadingSuggestions = false;
          _selectedUnloadingSuggestion = null;
        }
      });
      return;
    }

    setState(() {
      if (isLoadingField) {
        _isSearchingLoadingSuggestions = true;
      } else {
        _isSearchingUnloadingSuggestions = true;
      }
    });

    final timer = Timer(const Duration(milliseconds: 450), () async {
      try {
        final suggestions = await _fetchLocationSuggestions(trimmedQuery);
        if (!mounted) return;

        final activeValue = isLoadingField
            ? loadingController.text.trim()
            : unloadingController.text.trim();
        if (activeValue != trimmedQuery) return;

        setState(() {
          if (isLoadingField) {
            _loadingSuggestions = suggestions;
            _isSearchingLoadingSuggestions = false;
          } else {
            _unloadingSuggestions = suggestions;
            _isSearchingUnloadingSuggestions = false;
          }
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          if (isLoadingField) {
            _loadingSuggestions = [];
            _isSearchingLoadingSuggestions = false;
          } else {
            _unloadingSuggestions = [];
            _isSearchingUnloadingSuggestions = false;
          }
        });
      }
    });

    if (isLoadingField) {
      _loadingDebounce = timer;
    } else {
      _unloadingDebounce = timer;
    }
  }

  void _selectSuggestion({
    required LocationSuggestion suggestion,
    required bool isLoadingField,
  }) {
    setState(() {
      if (isLoadingField) {
        loadingController.text = suggestion.displayName;
        _loadingSuggestions = [];
        _selectedLoadingSuggestion = suggestion;
      } else {
        unloadingController.text = suggestion.displayName;
        _unloadingSuggestions = [];
        _selectedUnloadingSuggestion = suggestion;
      }
    });
  }

  Widget _buildSuggestionList({
    required List<LocationSuggestion> suggestions,
    required bool isLoadingField,
  }) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            leading: Icon(
              Icons.location_on_outlined,
              color: colorScheme.primary,
            ),
            title: Text(
              suggestion.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectSuggestion(
              suggestion: suggestion,
              isLoadingField: isLoadingField,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: MediaQuery.of(context).size.width * 0.92,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _gap([double height = 16]) => SizedBox(height: height);

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> calculateDistance() async {
    final from = loadingController.text;
    final to = unloadingController.text;

    if (from.isEmpty || to.isEmpty) {
      setState(() => distance = "Enter both locations");
      return;
    }

    final start = await getLocation(from);
    final end = await getLocation(to);

    if (start != null && end != null) {
      final meters = Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );

      setState(() {
        distance = "${(meters / 1000).toStringAsFixed(2)} km";
      });
    } else {
      setState(() => distance = "Invalid location");
    }
  }

  Future<void> _handleCreate() async {
    if (_isCreatingIndent) return;

    final customerName = customerNameController.text.trim();
    final vehicleType = vehicleTypeController.text.trim();
    final itemType = itemTypeController.text.trim();
    final itemWeight = itemWeightController.text.trim();
    final loadingCharge = loadingChargeController.text.trim();
    final unloadingCharge = unloadingChargeController.text.trim();
    final executiveName = executiveNameController.text.trim();
    final executiveId = executiveIdController.text.trim();
    final loadingPoint = loadingController.text.trim();
    final unloadingPoint = unloadingController.text.trim();

    if (customerName.isEmpty ||
        vehicleType.isEmpty ||
        itemType.isEmpty ||
        itemWeight.isEmpty ||
        loadingCharge.isEmpty ||
        unloadingCharge.isEmpty ||
        executiveName.isEmpty ||
        executiveId.isEmpty ||
        loadingPoint.isEmpty ||
        unloadingPoint.isEmpty) {
      _showMessage("Please fill all fields before creating indent.");
      return;
    }

    setState(() => _isCreatingIndent = true);

    try {
      final createdIndent = await _indentService.createIndent(
        IndentData(
          customerName: customerName,
          vehicleType: vehicleType,
          itemType: itemType,
          itemWeight: itemWeight,
          loadingCharge: loadingCharge,
          unloadingCharge: unloadingCharge,
          executiveName: executiveName,
          executiveId: executiveId,
          loadingPoint: loadingPoint,
          unloadingPoint: unloadingPoint,
          distanceKm: distance.isEmpty ? null : distance,
        ),
      );

      final users = await _authServiceAppwrite.getAllUsers();
      await _notificationService.createNotificationsForUsers(
        users: users,
        indentId: createdIndent.$id,
        loadingPoint: loadingPoint,
        unloadingPoint: unloadingPoint,
      );

      _showMessage("Indent created successfully.");
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isCreatingIndent = false);
      }
    }
  }

  void _clearForm() {
    customerNameController.clear();
    vehicleTypeController.clear();
    itemTypeController.clear();
    itemWeightController.clear();
    loadingChargeController.clear();
    unloadingChargeController.clear();
    executiveNameController.clear();
    executiveIdController.clear();
    loadingController.clear();
    unloadingController.clear();
    setState(() {
      distance = "";
      _loadingSuggestions = [];
      _unloadingSuggestions = [];
      _selectedLoadingSuggestion = null;
      _selectedUnloadingSuggestion = null;
    });
  }

  Widget _buildActionButton({
    required String label,
    required bool isPressed,
    required VoidCallback onTap,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required List<Color> colors,
    required Color borderColor,
    required Color textColor,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      onTap: onTap,
      child: AnimatedScale(
        scale: isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          height: 60,
          width: 132,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPressed
                  ? colors
                      .map((color) => color.withValues(alpha: 0.82))
                      .toList()
                  : colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: isPressed ? 0.18 : 0.28),
                blurRadius: isPressed ? 8 : 14,
                spreadRadius: isPressed ? 1 : 2,
                offset: Offset(0, isPressed ? 3 : 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSuffix() {
    if (_isFetchingLoadingPoint) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      onPressed: _isCreatingIndent ? null : _fillLoadingPointFromCurrentLocation,
      icon: _isSearchingLoadingSuggestions
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.my_location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pageBackground = const Color(0xFFE7EEF9);

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Create Indent'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _fiveImageBackground,
                      Color.alphaBlend(
                        Colors.white.withValues(alpha: 0.14),
                        _fiveImageBackground,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _fiveImageBackground.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Indent',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Plan the route, assign the executive, and create the job in one pass.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.route_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              distance.isEmpty
                                  ? 'Distance will appear after calculation'
                                  : 'Current route distance: $distance',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                title: 'Shipment Details',
                subtitle: 'Customer, vehicle, item and charges',
                icon: Icons.inventory_2_rounded,
                children: [
                  CustomFormField(
                    hintText: "Enter your name",
                    wid: 1,
                    controller: customerNameController,
                  ),
                  _gap(),
                  CustomFormField(
                    hintText: "Vehicle Type",
                    wid: 1,
                    controller: vehicleTypeController,
                  ),
                  _gap(),
                  CustomFormField(
                    hintText: "Item Type",
                    wid: 1,
                    controller: itemTypeController,
                  ),
                  _gap(),
                  CustomFormField(
                    hintText: "Item Weight",
                    wid: 1,
                    controller: itemWeightController,
                  ),
                  _gap(),
                  CustomFormField(
                    hintText: "Loading Charge",
                    wid: 1,
                    controller: loadingChargeController,
                  ),
                  _gap(),
                  CustomFormField(
                    hintText: "Unloading Charge",
                    wid: 1,
                    controller: unloadingChargeController,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Assignment',
                subtitle: 'Executive details for this indent',
                icon: Icons.badge_rounded,
                children: [
                  CustomFormField(
                    hintText: "Executive Name",
                    wid: 1,
                    controller: executiveNameController,
                  ),
                  _gap(),
                  CustomFormField(
                    hintText: "Executive ID",
                    wid: 1,
                    controller: executiveIdController,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                title: 'Route Planner',
                subtitle: 'Search locations or use current position',
                icon: Icons.route_rounded,
                children: [
                  CustomFormField(
                    hintText: "Loading Point",
                    wid: 1,
                    controller: loadingController,
                    onChanged: (value) => _scheduleSuggestionSearch(
                      query: value,
                      isLoadingField: true,
                    ),
                    suffixIcon: _buildLoadingSuffix(),
                  ),
                  _buildSuggestionList(
                    suggestions: _loadingSuggestions,
                    isLoadingField: true,
                  ),
                  _gap(),
                  CustomFormField(
                    hintText: "Unloading Point",
                    wid: 1,
                    controller: unloadingController,
                    onChanged: (value) => _scheduleSuggestionSearch(
                      query: value,
                      isLoadingField: false,
                    ),
                    suffixIcon: _isSearchingUnloadingSuggestions
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Icon(
                            Icons.search_rounded,
                            color: colorScheme.primary,
                          ),
                  ),
                  _buildSuggestionList(
                    suggestions: _unloadingSuggestions,
                    isLoadingField: false,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    label: "Calculate",
                    isPressed: _isCalculatePressed,
                    onTap: () async {
                      await calculateDistance();
                    },
                    onTapDown: () {
                      setState(() => _isCalculatePressed = true);
                    },
                    onTapUp: () {
                      setState(() => _isCalculatePressed = false);
                    },
                    colors: const [
                      Color(0xFFF3F7FF),
                      Color(0xFFD9E8FF),
                    ],
                    borderColor: const Color(0xFFABC8F5),
                    textColor: const Color(0xFF1D4E89),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    label: "Create",
                    isPressed: _isCreatePressed,
                    onTap: _handleCreate,
                    onTapDown: () {
                      setState(() => _isCreatePressed = true);
                    },
                    onTapUp: () {
                      setState(() => _isCreatePressed = false);
                    },
                    colors: const [
                      Color(0xFF2E6FCE),
                      Color(0xFF19478F),
                    ],
                    borderColor: const Color(0xFFB8D0F6),
                    textColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isCreatingIndent)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              if (!_isCreatingIndent && distance.isNotEmpty)
                Container(
                  width: MediaQuery.of(context).size.width * 0.92,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.straighten_rounded,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Distance: $distance",
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
