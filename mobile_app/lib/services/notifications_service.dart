import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:intl/intl.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;

class PushNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static int _notificationIdCounter = 0;
  final FirestoreService firestoreService = FirestoreService();
  static const _notificationsEnabledKey = 'notifications_enabled';

  List<DocumentSnapshot> allOffers = [];
  DateTime currentDate = DateTime.now();

  static Future<void> setNotificationsEnabled(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  static Future<bool> areNotificationsEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ??
        true; // Default to true if not set
  }

  //initialize local notifications
  static Future initLocalNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    //request notification permissions for android 13 or above
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  //on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!.pushNamed(NavigationConstants.NOTIFICATIONS_VIEW,
        arguments: notificationResponse);
  }

  //show a simple notification
  Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    bool notificationsEnabled = await areNotificationsEnabled();
    if (!notificationsEnabled) return;
    final String channelId = Uuid().v4();
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      ticker: 'ticker',
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    final int notificationId = _notificationIdCounter++;
    print('notification id: $notificationId');
    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    bool notificationsEnabled = await areNotificationsEnabled();
    if (!notificationsEnabled) return;

    final String channelId = const Uuid().v4();
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iosDetails = const DarwinNotificationDetails();
    final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosDetails);
    final int notificationId = _notificationIdCounter++;

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30)),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> scheduleFavOfferNotification(
      OfferModel offerModel, int scheduledDate) async {
    if (offerModel.endDate != "") {
      String offerDate = offerModel.endDate;
      DateFormat format = DateFormat("dd.MM.yyyy");
      DateTime endDate = format.parse(offerDate);

      if (endDate.isAfter(currentDate) &&
          endDate.isBefore(currentDate.add(Duration(days: scheduledDate)))) {
        print("got here");
        // Use offerModel.id as the key
        String uniqueId = offerModel.id;
        if (uniqueId != null) {
          await sendLastDayNotificationBackGround(
            offerModel.site,
            offerModel.header,
            uniqueId,
          );
        }
      }
    }
  }

  Future<void> sendLastDayNotificationBackGround(
      String offerSite, String offerHeader, String id) async {
    final scheduledDate = DateTime.now().add(const Duration(seconds: 10));

    print(scheduledDate);
    //if ( isFavNotificationEnable) {
    await PushNotifications.scheduleNotification(
      title: offerSite,
      body: offerHeader,
      scheduledDate: scheduledDate,
      payload: id,
    );
    print("Last day notification sent in background");
    //}
  }
}
