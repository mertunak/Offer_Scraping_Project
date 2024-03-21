import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/services/shared_preferences.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      required this.controller,
      this.isEmail = false,
      this.isProfile = false,
      this.isPassword = false,
      this.isName = false,
      this.isSurName = false});
  final TextEditingController controller;
  final bool isEmail;
  final bool isProfile;
  final bool isPassword;
  final bool isName;
  final bool isSurName;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends BaseState<CustomTextField> {
  List<String> userInformations =
      SharedManager.getUserInformations('informations') ?? [];

  @override
  void initState() {
    super.initState();
    if (widget.isProfile) {
      if (widget.isName) {
        widget.controller.text = userInformations[1];
      } else if (widget.isSurName) {
        widget.controller.text = userInformations[2];
      } else if (widget.isEmail) {
        widget.controller.text = userInformations[3];
        print(userInformations[2]);
      } else if (widget.isPassword) {
        widget.controller.text = userInformations[4];
      }
    }
  }

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
            controller: widget.controller,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: AppPaddings.MEDIUM_H,
              border: InputBorder.none,
              suffixIcon: widget.isProfile
                  ? ((widget.isEmail
                      ? const Icon(Icons.email)
                      : (widget.isPassword
                          ? const Icon(Icons.visibility)
                          : ((widget.isName || widget.isSurName)
                              ? const Icon(Icons.person)
                              : const SizedBox.shrink()))))
                  : const SizedBox.shrink(),
            )),
      ),
    );
  }
}
