import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/widget/buttons/custom_button.dart';
import 'package:mobile_app/screens/home/view/home_view.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobile_app/services/shared_preferences.dart';

import '../../models/user_model.dart';

class LoginAndRegisterButton extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final bool isLoginButton;
  final String buttonText;

  const LoginAndRegisterButton({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.surnameController,
    required this.isLoginButton,
    required this.buttonText,
  });

  @override
  State<LoginAndRegisterButton> createState() => _LoginAndRegisterButtonState();
}

class _LoginAndRegisterButtonState extends BaseState<LoginAndRegisterButton> {
  late UserModel currentUser;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.MEDIUM_V,
      child: InkWell(
        child: CustomButton(buttonText: widget.buttonText),
        onTap: () async {
          if (widget.isLoginButton) {
            User? user = await authService.signIn(
                widget.emailController.text, widget.passwordController.text);
            if (user != null) {
              currentUser = await FirestoreService().getCurrentUser(user.uid);
              await SharedManager.saveUserInformations('informations', [
                currentUser.id ?? "",
                currentUser.name ?? "",
                currentUser.surname ?? "",
                currentUser.email ?? "",
                currentUser.password ?? ""
              ]);
              await SharedManager.saveUserInformations(
                  'favSites', currentUser.favSites ?? []);
              await SharedManager.saveUserInformations(
                  'favOffers', currentUser.favOffers ?? []);
              // ignore: use_build_context_synchronously
              await UserManager.instance.setCurrentUser();
              await Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeView()));
            }
          } else {
            User? user = await authService.signUp(
                widget.emailController.text, widget.passwordController.text);

            if (user != null) {
              UserModel newUser = UserModel(
                user.uid,
                widget.emailController.text,
                widget.passwordController.text,
                widget.nameController.text,
                widget.surnameController.text,
                [],
                [],
              );
              await FirestoreService().addNewUser(newUser);
              await SharedManager.saveUserInformations('informations', [
                user.uid,
                widget.nameController.text,
                widget.surnameController.text,
                widget.emailController.text,
                widget.passwordController.text,
              ]);
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeView()),
                (route) => false,
              );
            }
          }
        },
      ),
    );
  }
}
