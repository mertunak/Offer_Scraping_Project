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

  Map<String, String> uniqueIds = {}; // Map by offer ID
  List<DocumentSnapshot> allOffers = [];
  List<String> notificationIds = [];
  Map<String, bool> _notificationDisplayedMap = {};
  DateTime currentDate = DateTime.now();
  bool isGenerated = false;

  static Future<void> setNotificationsEnabled(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  static Future<bool> areNotificationsEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ??
        true; // Default to true if not set
  }

  static Future<void> cancelFavNotification(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(id, false);
    print("Notification cancelled for $id");
  }

  static Future<bool> isFavNotificationEnabled(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(id) ?? true;
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

  void generateUniqueIds(List<OfferModel> offerModels) {
    for (OfferModel offer in offerModels) {
      var uuid = const Uuid();
      String uniqueId = uuid.v4();
      uniqueIds[offer.id] = uniqueId; // Use offer.id as the key
      print('Generated uniqueId for ${offer.id}: $uniqueId');
    }
  }

  Future<void> getAllOffers() async {
    allOffers = await firestoreService.getOffersBySites(
      await firestoreService
          .getSiteNamesByIds(UserManager.instance.currentUser.favSites),
    );

    List<OfferModel> offerModels = allOffers.map((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return OfferModel.fromJson(data, snapshot.id);
    }).toList();

    if (!isGenerated) {
      print(isGenerated);
      generateUniqueIds(offerModels);
      isGenerated = true;
      print("Generated unique IDs: $uniqueIds");
    } else {
      print("isGenerated: $isGenerated");
    }
  }

  Future<void> scheduleFavOfferNotification(
      OfferModel offerModel, int scheduledDate) async {
    if (!isGenerated) {
      print("Error: Unique IDs have not been generated yet.");
      return;
    }

    if (offerModel.endDate != "") {
      String offerDate = offerModel.endDate;
      DateFormat format = DateFormat("dd.MM.yyyy");
      DateTime endDate = format.parse(offerDate);

      if (endDate.isAfter(currentDate) &&
          endDate.isBefore(currentDate.add(Duration(days: scheduledDate)))) {
        print("got here");
        String? uniqueId =
            uniqueIds[offerModel.id]; // Use offerModel.id as the key

        if (uniqueId != null && !checkSent(uniqueId)) {
          await sendLastDayNotificationBackGround(
            offerModel.site,
            offerModel.header,
            uniqueId,
          );
        } else {
          print(offerModel.id);
          print(uniqueId ?? "neden");
          print("uniqueIds[offerModel.id] is null or already sent");
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
    final scheduledDate = DateTime.now().add(const Duration(seconds: 10));

    print(scheduledDate);
    print(checkSent(id));
    bool isFavNotificationEnable = await isFavNotificationEnabled(id);
    if (checkSent(id) == false && isFavNotificationEnable) {
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
