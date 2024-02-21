import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';

class LoginTextField extends StatefulWidget {
  const LoginTextField(
      {super.key, required this.controller, required this.isEmail});
  final TextEditingController controller;
  final bool isEmail;

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends BaseState<LoginTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.SMALL_V,
      child: SizedBox(
        height: dynamicHeightDevice(0.055),
        child: TextFormField(
          controller: widget.controller,
          decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: BorderColors.SECONDARY_COLOR, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: BorderColors.TEXTFIELD_COLOR, width: 2.0))),
        ),
      ),
    );
  }
}
