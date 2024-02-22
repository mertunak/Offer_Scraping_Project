import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/paths/image_paths.dart';
import 'package:mobile_app/product/constants/texts/screen_texts.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/product/widget/buttons/login_register_button.dart';
import 'package:mobile_app/product/widget/text_fields/login_text_fields.dart';

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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  const Text(ScreenTexts.LOGIN_TEXT_TITLE,
                      style: TextStyles.LARGE),
                  const Padding(
                    padding: AppPaddings.SMALL_V,
                    child: Text(
                      ScreenTexts.LOGIN_TEXT_SUBTITLE,
                      style: TextStyles.SMALL,
                    ),
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
                  LoginTextField(
                    controller: emailController,
                    isEmail: true,
                  ),
                  const Text(
                    'Password',
                    style: TextStyles.SMALL,
                  ),
                  LoginTextField(
                    controller: passwordController,
                    isEmail: false,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Forgot Password?',
                        style: TextStyles.BUTTON_TEXTSTYLE,
                      ),
                      LoginAndRegisterButton(
                        emailController: emailController,
                        passwordController: passwordController,
                        isLoginButton: true,
                        buttonText: 'Sign In',
                      ),
                    ],
                  ),
                  Padding(
                    padding: AppPaddings.LARGE_H,
                    child: Row(
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyles.SMALL,
                        ),
                        const Spacer(),
                        InkWell(
                          child: const Text(
                            'Sign Up',
                            style: TextStyles.BUTTON_TEXTSTYLE,
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
