import 'package:flutter/material.dart';
import 'package:mobile_app/product/constants/utils/border_radius_constants.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/padding_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobile_app/product/widget/buttons/custom_button.dart';
import 'package:mobile_app/product/widget/text_fields/custom_text_field.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobile_app/services/shared_preferences.dart';

class UpdateProfileAlert extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final double width;
  final double height;

  UpdateProfileAlert({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: AppPaddings.MEDIUM_H,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: AppPaddings.SMALL_V,
        constraints: BoxConstraints(maxHeight: height),
        decoration: BoxDecoration(
          color: SurfaceColors.PRIMARY_COLOR,
          borderRadius: AppBorderRadius.MEDIUM,
        ),
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
                        SharedManager.getUserInformations('informations') ?? [];
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
                    await FirestoreService().updateUserInformations(userModel);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
