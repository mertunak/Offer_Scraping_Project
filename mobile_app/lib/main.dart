import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/services/notifications_service.dart';
import 'package:mobile_app/services/shared_preferences.dart';
import 'product/navigation/navigation_constants.dart';
import 'product/navigation/route_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //initialize local notifications
  await PushNotifications.initLocalNotifications();

  if (FirebaseAuth.instance.currentUser != null) {
    await UserManager.instance.setCurrentUser();
    await SharedManager.init();
    await UserManager.instance.setCurrentUser();
    await PushNotifications().getAllOffers();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: NavigationConstants.SPLASH_VIEW,
    );
  }
}
