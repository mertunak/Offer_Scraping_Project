import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/texts/screen_texts.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobile_app/product/widget/buttons/custom_button.dart';
import 'package:mobile_app/product/widget/text_fields/custom_text_field.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobile_app/services/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends BaseState<ProfileView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ScreenTexts.PROFILE_TITLE,
          style: TextStyles.MEDIUM_B,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: AppPaddings.LARGE_V + AppPaddings.LARGE_H,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'İsim',
                  style: TextStyles.SMALL_B,
                ),
                CustomTextField(
                  controller: nameController,
                  isProfile: true,
                  isName: true,
                ),
                const Text(
                  'Soy İsim',
                  style: TextStyles.SMALL_B,
                ),
                CustomTextField(
                  controller: surnameController,
                  isProfile: true,
                  isSurName: true,
                ),
                const Text(
                  'Email',
                  style: TextStyles.SMALL_B,
                ),
                CustomTextField(
                  controller: mailController,
                  isProfile: true,
                  isEmail: true,
                ),
                const Text(
                  'Şifre',
                  style: TextStyles.SMALL_B,
                ),
                CustomTextField(
                  controller: passwordController,
                  isProfile: true,
                  isPassword: true,
                ),
                Padding(
                  padding: AppPaddings.MEDIUM_V,
                  child: InkWell(
                    child: const CustomButton(buttonText: "Güncelle"),
                    onTap: () async {
                      List<String> userInformations =
                          SharedManager.getUserInformations('informations') ??
                              [];
                      List<String> favSites =
                          SharedManager.getUserInformations('favSites') ?? [];
                      List<String> favOffers =
                          SharedManager.getUserInformations('favOffers') ?? [];
                      UserModel userModel = UserModel(
                          userInformations[0],
                          mailController.text,
                          passwordController.text,
                          nameController.text,
                          surnameController.text,
                          favSites,
                          favOffers);
                      await FirestoreService()
                          .updateUserInformations(userModel);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
