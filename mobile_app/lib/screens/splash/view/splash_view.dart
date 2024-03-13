import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/state/base_state.dart';
import 'package:mobile_app/product/constants/paths/image_paths.dart';
import 'package:mobile_app/product/constants/texts/screen_texts.dart';
import 'package:mobile_app/product/constants/utils/color_constants.dart';
import 'package:mobile_app/product/constants/utils/text_styles.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/services/shared_preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends BaseState<SplashView> {
  @override
  void initState() {
    inits();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SurfaceColors.PRIMARY_COLOR,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImagePaths.SPLASH_IMAGE,
              height: 300,
            ),
            const Text(
              ScreenTexts.SPLASH_TITLE,
              style: TextStyles.HOME_HEADING,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> inits() async {
    await Future.delayed(const Duration(seconds: 2), () async {
      await SharedManager.checkIsFirstTime().then((isFirstTime) async {
        if (isFirstTime) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              NavigationConstants.LOGIN_VIEW, (route) => false);
        } else {
          User? user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            await Navigator.pushReplacementNamed(
                context, NavigationConstants.LOGIN_VIEW);
          } else {
            await Navigator.pushReplacementNamed(
                context, NavigationConstants.HOME_VIEW);
          }
        }
      });
    });
  }
}
