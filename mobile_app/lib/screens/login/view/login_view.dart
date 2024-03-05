import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/paths/image_paths.dart';
import 'package:mobile_app/product/constants/texts/screen_texts.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/product/widget/buttons/login_register_button.dart';
import 'package:mobile_app/product/widget/text_fields/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends BaseState<LoginView> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: dynamicHeightDevice(0.13),
            ),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    ImagePaths.LOGIN_IMAGE_PATH,
                    width: dyanmicWidthDevice(0.5),
                    height: dynamicHeightDevice(0.25),
                  ),
                  const Padding(
                    padding: AppPaddings.SMALL_V,
                    child: Text(ScreenTexts.LOGIN_TEXT_TITLE,
                        style: TextStyles.LARGE),
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppPaddings.LARGE_H + AppPaddings.SMALL_V,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyles.SMALL,
                  ),
                  CustomTextField(
                    controller: emailController,
                    isEmail: true,
                  ),
                  const Text(
                    'Şifre',
                    style: TextStyles.SMALL,
                  ),
                  CustomTextField(
                    controller: passwordController,
                    isEmail: false,
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Şifreni mi unuttun?',
                      style: TextStyles.TEXT_BUTTON,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  LoginAndRegisterButton(
                    emailController: emailController,
                    passwordController: passwordController,
                    nameController: TextEditingController(),
                    surnameController: TextEditingController(),
                    isLoginButton: true,
                    buttonText: 'Giriş Yap',
                  ),
                  Padding(
                    padding: AppPaddings.LARGE_H,
                    child: Row(
                      children: [
                        const Text(
                          "Henüz hesabın yok mu?",
                          style: TextStyles.SMALL,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          child: const Text(
                            'Kaydol',
                            style: TextStyles.TEXT_BUTTON,
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(NavigationConstants.REGISTER_VIEW);
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
