import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key, required this.controller, required this.isEmail});
  final TextEditingController controller;
  final bool isEmail;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends BaseState<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.SMALL_V,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppBorderRadius.SMALL,
          border: Border.all(
            color: BorderColors.SECONDARY_COLOR,
            width: 2,
          ),
        ),
        child: TextField(
          decoration: const InputDecoration(
            contentPadding: AppPaddings.MEDIUM_H,
            border: InputBorder.none,
          ),
          controller: widget.controller,
        ),
      ),
    );
  }
}
