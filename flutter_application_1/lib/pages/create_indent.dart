import 'package:cargo_flow/helperUI/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class IndentFrom extends StatefulWidget {
  const IndentFrom({super.key});

  @override
  State<IndentFrom> createState() => _IndentFromState();
}

class _IndentFromState extends State<IndentFrom> {
  bool _isLoginPressed = false;
  static const Color _fiveImageBackground = Color(0xFF4683D9);

  // 🔹 Controllers
  TextEditingController loadingController = TextEditingController();
  TextEditingController unloadingController = TextEditingController();

  String distance = "";

  // 🔹 Convert address → LatLng
  Future<Location?> getLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      return locations.first;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // 🔹 Calculate distance
  Future<void> calculateDistance() async {
    String from = loadingController.text;
    String to = unloadingController.text;

    if (from.isEmpty || to.isEmpty) {
      setState(() => distance = "Enter both locations");
      return;
    }

    Location? start = await getLocation(from);
    Location? end = await getLocation(to);

    if (start != null && end != null) {
      double meters = Geolocator.distanceBetween(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fiveImageBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.36,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/five.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 20),

              CustomFormField(hintText: "Enter your name", wid: 0.9),
              SizedBox(height: 20),

              CustomFormField(hintText: "Vehicle Type", wid: 0.9),
              SizedBox(height: 20),

              CustomFormField(hintText: "Item Type", wid: 0.9),
              SizedBox(height: 20),

              CustomFormField(hintText: "Item Weight", wid: 0.9),
              SizedBox(height: 20),

              CustomFormField(hintText: "Loading Charge", wid: 0.9),
              SizedBox(height: 20),

              CustomFormField(hintText: "Unloading Charge", wid: 0.9),
              SizedBox(height: 20),

              CustomFormField(hintText: "Executive Name", wid: 0.9),
              SizedBox(height: 20),

              CustomFormField(hintText: "Executive ID", wid: 0.9),
              SizedBox(height: 20),

              // ✅ Loading Point
              CustomFormField(
                hintText: "Loading Point",
                wid: 0.9,
                controller: loadingController,
              ),
              SizedBox(height: 20),

              // ✅ Unloading Point
              CustomFormField(
                hintText: "Unloading Point",
                wid: 0.9,
                controller: unloadingController,
              ),
              SizedBox(height: 20),

              // 🔘 Button
              InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTapDown: (_) {
                      setState(() => _isLoginPressed = true);
                    },
                    onTapUp: (_) {
                      setState(() => _isLoginPressed = false);
                    },
                    onTapCancel: () {
                      setState(() => _isLoginPressed = false);
                    },
                    onTap: () async {
                    await calculateDistance();
                    },
                    child: AnimatedScale(
                      scale: _isLoginPressed ? 0.94 : 1.0,
                      duration: Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        height: 60,
                        width: 100,
                        decoration: BoxDecoration(
                          color: _isLoginPressed
                              ? _fiveImageBackground.withValues(alpha: 0.7)
                              : _fiveImageBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white, width: 1),
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
                            child: Text("Calculate",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )
                                )
                                )
                                ,
                      ),
                    ),
                  ),

              SizedBox(height: 20),

              // ✅ Distance Result
              Text(
                "Distance: $distance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}