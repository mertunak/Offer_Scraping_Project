import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/texts/screen_texts.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/product/widget/buttons/login_register_button.dart';
import 'package:mobile_app/product/widget/text_fields/login_text_fields.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextEditingController fullnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(NavigationConstants.LOGIN_VIEW);
            },
            icon: const Padding(
              padding: AppPaddings.SMALL_H,
              child: Icon(
                Icons.arrow_back,
                size: 35,
              ),
            )),
        title: const Text(
          "Let's Sign Up",
          style: TextStyles.MEDIUM_B,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: AppPaddings.LARGE_H + AppPaddings.LARGE_V,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyles.MEDIUM,
              ),
              const Padding(
                padding: AppPaddings.SMALL_V,
                child: Text(
                  ScreenTexts.REGISTER_TEXT_SUBTITLE,
                  style: TextStyles.SMALL,
                ),
              ),
              const Padding(
                padding: AppPaddings.SMALL_V,
                child: Text(
                  'Full Name',
                  style: TextStyles.SMALL_B,
                ),
              ),
              LoginTextField(controller: fullnameController, isEmail: true),
              const Padding(
                padding: AppPaddings.SMALL_V,
                child: Text(
                  'Email',
                  style: TextStyles.SMALL_B,
                ),
              ),
              LoginTextField(controller: emailController, isEmail: false),
              const Padding(
                padding: AppPaddings.SMALL_V,
                child: Text(
                  'Password',
                  style: TextStyles.SMALL_B,
                ),
              ),
              LoginTextField(controller: passwordController, isEmail: false),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LoginAndRegisterButton(
                    emailController: emailController,
                    passwordController: passwordController,
                    fullnameController: fullnameController,
                    isLoginButton: false,
                    buttonText: 'Create Account'),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  Padding(
                    padding: AppPaddings.LARGE_H,
                    child: Text(
                      'Log In',
                      style: TextStyles.BUTTON_TEXTSTYLE,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
