import 'package:flutter/material.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/screens/login/view/login_view.dart';
import 'package:mobile_app/screens/offer_detail/view/offer_detail_view.dart';
import 'package:mobile_app/screens/home/view/home_view.dart';
import 'package:mobile_app/screens/notifications/view/notifications_view.dart';
import 'package:mobile_app/screens/profile/view/profile_view.dart';
import 'package:mobile_app/screens/register/view/register_view.dart';
import 'package:mobile_app/screens/splash/view/splash_view.dart';
import 'navigation_constants.dart';

class RouteGenerator {
  RouteGenerator._init();
  static RouteGenerator? _instance;
  static RouteGenerator get instance {
    _instance ??= RouteGenerator._init();
    return _instance!;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case NavigationConstants.HOME_VIEW:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case NavigationConstants.NOTIFICATIONS_VIEW:
        return MaterialPageRoute(builder: (_) => NotificationsView());
      case NavigationConstants.OFFER_DETAIL_VIEW:
        final args = settings.arguments as OfferModel;
        return MaterialPageRoute(builder: (_) => OfferDetailView(args));
      case NavigationConstants.LOGIN_VIEW:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case NavigationConstants.REGISTER_VIEW:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case NavigationConstants.SPLASH_VIEW:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case NavigationConstants.PROFILE_VIEW:
        return MaterialPageRoute(builder: (_) => const ProfileView());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
