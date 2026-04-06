import 'package:flutter/material.dart';

import 'package:cargo_flow/helperUI/custom_form_field.dart';
import 'package:cargo_flow/pages/Driver/home_page.dart';
import 'package:cargo_flow/services/auth_service.dart';
import 'package:cargo_flow/services/database_service.dart';
import 'package:cargo_flow/theme/app_theme.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _isLoginPressed = false;
  bool _isLoading = false;
  String? _selectedVehicleType;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _regNoController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _regNoController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final regNo = _regNoController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        address.isEmpty ||
        regNo.isEmpty ||
        _selectedVehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final driverData = {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'address': address,
          'vehicleRegNo': regNo,
          'vehicleType': _selectedVehicleType,
          'authUserId': user.id,
          'registeredAt': DateTime.now().toIso8601String(),
        };

        await _databaseService.registerDriver(user.id, driverData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  final List<String> _vehicleTypes = [
    '20 Ft',
    '22 Ft',
    '32 Ft SXL',
    '32 Ft MXL',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isMobile = constraints.maxWidth < 600;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Hero / Banner ──────────────────────────────────────
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image(
                        image: AssetImage("images/four.png"),
                        height: MediaQuery.of(context).size.height * 0.32,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay for text legibility
                      Container(
                        height: MediaQuery.of(context).size.height * 0.32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              theme.scaffoldBackgroundColor
                                  .withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                      // Page title sitting on the image
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Driver Registration',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: theme.colorScheme.onSurface,
                                  ) ??
                                  const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fill in your details to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ) ??
                                  const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Section: Personal Info ─────────────────────────────
                  _SectionHeader(title: 'Personal Information'),
                  const SizedBox(height: 12),

                  isMobile
                      ? _buildVerticalFields([
                          CustomFormField(
                            hintText: 'First Name',
                            wid: 0.88,
                            controller: _firstNameController,
                          ),
                          CustomFormField(
                            hintText: 'Last Name',
                            wid: 0.88,
                            controller: _lastNameController,
                          ),
                        ])
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CustomFormField(
                              hintText: 'First Name',
                              wid: 0.43,
                              controller: _firstNameController,
                            ),
                            CustomFormField(
                              hintText: 'Last Name',
                              wid: 0.43,
                              controller: _lastNameController,
                            ),
                          ],
                        ),

                  const SizedBox(height: 12),

                  CustomFormField(
                    hintText: 'Phone No',
                    wid: isMobile ? 0.88 : 0.7,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 12),

                  CustomFormField(
                    hintText: 'Address',
                    wid: isMobile ? 0.88 : 0.7,
                    controller: _addressController,
                  ),

                  const SizedBox(height: 28),

                  // ── Section: Vehicle Info ──────────────────────────────
                  _SectionHeader(title: 'Vehicle Information'),
                  const SizedBox(height: 12),

                  isMobile
                      ? _buildVerticalFields([
                          CustomFormField(
                            hintText: 'Vehicle Registration No',
                            wid: 0.88,
                            controller: _regNoController,
                          ),
                          _VehicleTypeDropdown(
                            selectedValue: _selectedVehicleType,
                            items: _vehicleTypes,
                            widthFactor: 0.88,
                            onChanged: (val) =>
                                setState(() => _selectedVehicleType = val),
                          ),
                        ])
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CustomFormField(
                              hintText: 'Vehicle Registration No',
                              wid: 0.43,
                              controller: _regNoController,
                            ),
                            _VehicleTypeDropdown(
                              selectedValue: _selectedVehicleType,
                              items: _vehicleTypes,
                              widthFactor: 0.43,
                              onChanged: (val) =>
                                  setState(() => _selectedVehicleType = val),
                            ),
                          ],
                        ),

                  const SizedBox(height: 36),

                  // ── Submit Button ──────────────────────────────────────
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTapDown: (_) => setState(() => _isLoginPressed = true),
                    onTapUp: (_) => setState(() => _isLoginPressed = false),
                    onTapCancel: () => setState(() => _isLoginPressed = false),
                    onTap: _handleRegister,
                    child: AnimatedScale(
                      scale: _isLoginPressed ? 0.94 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        height: 56,
                        width: isMobile
                            ? MediaQuery.of(context).size.width * 0.88
                            : 220,
                        decoration: BoxDecoration(
                          color: _isLoginPressed
                              ? AppTheme.primaryColor.withValues(alpha: 0.7)
                              : AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: theme.colorScheme.onPrimary, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                  alpha: _isLoginPressed ? 0.3 : 0.5),
                              blurRadius: _isLoginPressed ? 6 : 10,
                              spreadRadius: _isLoginPressed ? 1 : 2,
                              offset: Offset(0, _isLoginPressed ? 3 : 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalFields(List<Widget> fields) {
    return Column(
      children: fields
          .expand((field) => [Center(child: field), const SizedBox(height: 14)])
          .toList()
        ..removeLast(),
    );
  }
}

// ── Section Header widget ──────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ) ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Vehicle Type Dropdown widget ───────────────────────────────────────────────
class _VehicleTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final List<String> items;
  final double widthFactor;
  final ValueChanged<String?> onChanged;

  const _VehicleTypeDropdown({
    required this.selectedValue,
    required this.items,
    required this.widthFactor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * widthFactor,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        hint: const Text('Vehicle Type'),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: theme.colorScheme.outline, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.secondaryColor, width: 1.8),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        dropdownColor: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        items: items
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
