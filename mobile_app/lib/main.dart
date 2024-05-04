import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/services/notifications_service.dart';
import 'package:mobile_app/services/shared_preferences.dart';
import 'product/navigation/navigation_constants.dart';
import 'product/navigation/route_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

//function to listen background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification received in background");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //initialize firebase messaging
  await PushNotifications.init();

  //initialize local notifications
  await PushNotifications.initLocalNotifications();

  //Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  //onbackground notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Notification tapped in background");
      navigatorKey.currentState!.pushNamed(
          NavigationConstants.NOTIFICATIONS_VIEW,
          arguments: message);
    }
  });

  //to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    if (message.notification != null) {
      print("Notification received in foreground");
      PushNotifications.showNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  //for handling notifications when app is terminated
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed(
          NavigationConstants.NOTIFICATIONS_VIEW,
          arguments: message);
    });
  }

  await SharedManager.init();
  await UserManager.instance.setCurrentUser();
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
