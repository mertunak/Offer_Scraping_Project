import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/texts/screen_texts.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/widget/buttons/login_register_button.dart';
import 'package:mobile_app/product/widget/text_fields/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kaydol",
        ),
      ),
      body: Padding(
        padding: AppPaddings.LARGE_H,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: AppPaddings.SMALL_V,
                child: Text(
                  ScreenTexts.REGISTER_TEXT_SUBTITLE,
                  style: TextStyles.SMALL,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'İsim',
                style: TextStyles.SMALL_B,
              ),
              CustomTextField(controller: nameController, isEmail: true),
              const Text(
                'Soyisim',
                style: TextStyles.SMALL_B,
              ),
              CustomTextField(controller: surnameController, isEmail: true),
              const Text(
                'Email',
                style: TextStyles.SMALL_B,
              ),
              CustomTextField(controller: emailController, isEmail: false),
              const Text(
                'Şifre',
                style: TextStyles.SMALL_B,
              ),
              CustomTextField(controller: passwordController, isEmail: false),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LoginAndRegisterButton(
                    emailController: emailController,
                    passwordController: passwordController,
                    nameController: nameController,
                    surnameController: surnameController,
                    isLoginButton: false,
                    buttonText: 'Hesap Oluştur'),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Zaten bir hesabın var mı?',
                    style: TextStyles.SMALL,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Giriş Yap',
                    style: TextStyles.TEXT_BUTTON,
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
