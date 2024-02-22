import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/firestore.dart';

import '../../models/user_model.dart';

class LoginAndRegisterButton extends StatefulWidget {
  const LoginAndRegisterButton(
      {super.key,
      required this.emailController,
      required this.passwordController,
      this.fullnameController,
      required this.isLoginButton,
      required this.buttonText});
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? fullnameController;
  final bool isLoginButton;
  final String buttonText;

  @override
  State<LoginAndRegisterButton> createState() => _LoginAndRegisterButtonState();
}

class _LoginAndRegisterButtonState extends BaseState<LoginAndRegisterButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.MEDIUM_V,
      child: InkWell(
        child: Container(
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
              style: TextStyles.SMALL,
            ),
          ),
        ),
        onTap: () async {
          if (widget.isLoginButton) {
            User? user = await authService.signIn(
                widget.emailController.text, widget.passwordController.text);
            if (user != null) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamed(NavigationConstants.HOME_VIEW);
            }
          } else {
            User? user = await authService.signUp(
                widget.emailController.text, widget.passwordController.text);

            if (user != null) {
              UserModel addUser = UserModel(
                name: widget.fullnameController?.text,
                email: widget.emailController.text,
                password: widget.passwordController.text,
                uid: user.uid,
              );
              await FirestoreService().addNewUser(addUser);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamed(NavigationConstants.HOME_VIEW);
            }
          }
        },
      ),
    );
  }
}
