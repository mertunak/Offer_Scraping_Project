import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart';
import 'package:uuid/uuid.dart';

class PushNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static int _notificationIdCounter = 0;
  final FirestoreService firestoreService = FirestoreService();
  final Map<OfferModel, String> uniqueIds = {};
  List<DocumentSnapshot> allOffers = [];
  List<String> notificationIds = [];
  Map<String, bool> _notificationDisplayedMap = {};
  DateTime currentDate = DateTime.now();
  late tz.Location _local = tz.getLocation('Europe/Istanbul');
  bool isGnerated = false;

  //initialize local notifications
  static Future initLocalNotifications() async {
    tzdata.initializeTimeZones();
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
  Future<void> showNotification(
      {required String title,
      required String body,
      required String payload}) async {
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
    int notificationId = _notificationIdCounter++;
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
    required TZDateTime scheduledDate,
    required String payload,
  }) async {
    final String channelId = const Uuid().v4();
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      ticker: 'ticker',
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    final int notificationId = _notificationIdCounter++;
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  void generateUniqueIds(List<OfferModel> offerModels) {
    for (OfferModel offer in offerModels) {
      var uuid = const Uuid();
      String uniqueId = uuid.v4();
      uniqueIds[offer] = uniqueId;
    }
  }

  Future<void> getAllOffers() async {
    allOffers = await firestoreService.getOffersBySites(await firestoreService
        .getSiteNamesByIds(UserManager.instance.currentUser.favSites));

    List<OfferModel> offerModels = allOffers.map((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return OfferModel.fromJson(data);
    }).toList();
    if (!isGnerated) {
      generateUniqueIds(offerModels);
      isGnerated = true;
    }
    scheduleNotifications(offerModels);
  }

  Future<void> scheduleNotifications(List<OfferModel> offerModels) async {
    print("allOffers length: ${offerModels.length}");
    for (OfferModel offer in offerModels) {
      if (offer.endDate != "") {
        String offerDate = offer.endDate;
        DateFormat format = DateFormat("dd.MM.yyyy");
        DateTime endDate = format.parse(offerDate);

        if (endDate.isAfter(currentDate) &&
            endDate.isBefore(currentDate.add(const Duration(days: 1)))) {
          print("got here");
          // Schedule notification for each offer

          if (!checkSent(uniqueIds[offer]!)) {
            await sendLastDayNotificationBackGround(
              offer.site,
              offer.header,
              uniqueIds[offer]!,
            );
          }
        }
      }
    }
  }

  bool checkSent(String notificationId) {
    //Bildirim gönderildi mi kontrol et. Gönderildiyse true

    if (_notificationDisplayedMap[notificationId] == true ||
        notificationIds.contains(notificationId)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> sendLastDayNotificationBackGround(
      String offerSite, String offerHeader, String id) async {
    final now = DateTime.now();
    final scheduledDate =
        TZDateTime.from(now.add(const Duration(seconds: 40)), _local);
    print(scheduledDate);
    print(checkSent(id));
    if (checkSent(id) == false) {
      notificationIds.add(id);
      await PushNotifications.scheduleNotification(
        title: offerSite,
        body: offerHeader,
        scheduledDate: scheduledDate,
        payload: id,
      );
      setTrueForSentNotification(id);
      print("Last day notification sent in background");
    }
  }

  void setTrueForSentNotification(String notificationId) {
    if (notificationIds.contains(notificationId)) {
      _notificationDisplayedMap[notificationId] = true;
    }
  }
}
