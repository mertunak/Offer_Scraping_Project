import 'package:flutter/material.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/screens/offer_detail/view/offer_detail_view.dart';
import 'package:mobile_app/screens/home/view/home_view.dart';
import 'package:mobile_app/screens/notifications/view/notifications_view.dart';
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
        return MaterialPageRoute(builder: (_) => const NotificationsView());
      case NavigationConstants.OFFER_DETAIL_VIEW:
        final args = settings.arguments as OfferModel;
        return MaterialPageRoute(builder: (_) => OfferDetailView(args));
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
