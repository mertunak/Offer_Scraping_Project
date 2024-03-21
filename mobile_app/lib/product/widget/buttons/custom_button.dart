import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({super.key, required this.buttonText});
  final String buttonText;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends BaseState<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: dynamicHeightDevice(0.065),
      decoration: BoxDecoration(
          color: ButtonColors.PRIMARY_COLOR,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              //Bilemedim çok ??
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 3,
              offset: const Offset(3, 4),
            ),
          ]),
      child: Center(
        child: Text(
          widget.buttonText,
          style: TextStyles.BUTTON,
        ),
      ),
    );
  }
}
