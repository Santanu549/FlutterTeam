import 'package:flutter/material.dart';
import 'package:flutter_application_1/helperUI/custom_form_field.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  bool _isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // On narrow screens (<600), stack fields vertically
                final bool isMobile = constraints.maxWidth < 600;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                        image: AssetImage("images/four.png"),
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width * 0.8),

                    // First Name & Last Name
                    isMobile
                        ? _buildVerticalFields([
                            CustomFormField(hintText: 'First Name', wid: 0.8),
                            CustomFormField(hintText: 'Last Name', wid: 0.8),
                          ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CustomFormField(hintText: 'First Name', wid: 0.4),
                              CustomFormField(hintText: 'Last Name', wid: 0.4),
                            ],
                          ),

                    SizedBox(height: 20),

                    // Vehicle No & Phone No
                    isMobile
                        ? _buildVerticalFields([
                            CustomFormField(
                                hintText: 'Vehicle Registration No', wid: 0.8),
                            CustomFormField(hintText: 'Phone No', wid: 0.8),
                          ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CustomFormField(
                                  hintText: 'Vehicle Registration No',
                                  wid: 0.4),
                              CustomFormField(hintText: 'Phone No', wid: 0.4),
                            ],
                          ),

                    SizedBox(height: 20),

                    CustomFormField(
                        hintText: 'Address', wid: isMobile ? 0.8 : 0.7),

                    SizedBox(height: 20),

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
                      onTap: () {
                        setState(() {});
                      },
                      child: AnimatedScale(
                        scale: _isLoginPressed ? 0.94 : 1.0,
                        duration: Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 120),
                          curve: Curves.easeOut,
                          height: 60,
                          width: 180,
                          decoration: BoxDecoration(
                            color: _isLoginPressed
                                ? AppTheme.primaryColor.withValues(alpha: 0.7)
                                : AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(10),
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
                              child: Text("Submit",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ))),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }

  /// Stacks fields vertically with spacing between them.
  Widget _buildVerticalFields(List<Widget> fields) {
    return Column(
      children: fields
          .expand((field) => [Center(child: field), SizedBox(height: 15)])
          .toList()
        ..removeLast(), // remove trailing SizedBox
    );
  }
}
