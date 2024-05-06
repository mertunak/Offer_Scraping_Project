import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/services/notifications_service.dart';
import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';

import '../../../services/firestore.dart';
part 'offer_viewmodel.g.dart';

class OfferViewModel = _OfferViewModelBase with _$OfferViewModel;

abstract class _OfferViewModelBase extends BaseViewModel with Store {
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Map<OfferModel, String> uniqueIds = {};
  List<DocumentSnapshot> allOffers = [];
  List<DocumentSnapshot> filterResults = [];
  DateTime currentDate = DateTime.now();

  Map<String, bool> brandMap = {
    'filterActive': false,
    'apple': false,
    'samsung': false,
    'huawei': false,
    'xiomi': false,
    'lenovo': false,
    'casper': false,
  };

  Map<String, bool> sizeMap = {
    'filterActive': false,
    '10_9 inç': false,
    '11 inç': false,
    '12_9 inç': false,
    '8 inç': false,
    '11_7 inç': false,
  };

  Map<String, bool> siteMap = {
    'filterActive': false,
    'İş Bankası': false,
    'Bellona': false,
    'Migros': false,
    'OBilet': false,
    'THY': false,
    'Koton': false,
    'Vatan': false,
    'Mediamarkt': false,
    'Teknosa': false,
  };

  @observable
  ObservableList<DocumentSnapshot> resultOffers = ObservableList.of([]);

  @observable
  int resultCount = 0;

  @observable
  Map<String, Map<String, bool>> choiceFilters = {};

  @observable
  List<String> priceFilter = [];

  @observable
  Map<String, bool> _notificationDisplayedMap = {};

  @observable
  List<String> notificationIds = [];

  @observable
  bool isGnerated = false;

  @override
  void init() {
    choiceFilters = {
      'marka': brandMap,
      'boyut': sizeMap,
      'site': siteMap,
    };
  }

  @action
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

  void generateUniqueIds(List<OfferModel> offerModels) {
    for (OfferModel offer in offerModels) {
      var uuid = const Uuid();
      String uniqueId = uuid.v4();
      uniqueIds[offer] = uniqueId;
    }
  }

  @action
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
            await sendLastDayNotificationInForeGround(
              endDate,
              offer.site,
              offer.header,
              uniqueIds[offer]!,
            );
          }
        }
      }
    }
  }

  @action
  void initOfferLists() {
    updateResultOffers(allOffers);
    filterResults = List.from(allOffers);
  }

  @action
  void updateResultOffers(List<DocumentSnapshot> resultList) {
    resultOffers = ObservableList.of(resultList);
    resultCount = resultOffers.length;
  }

  @action
  void addResultOffers(DocumentSnapshot offerSnapshot) {
    resultOffers.add(offerSnapshot);
    resultCount = resultOffers.length;
  }

  @action
  void clearResultOffers() {
    resultOffers.clear();
    resultCount = resultOffers.length;
  }

  @action
  void changeCheckboxFilter(
      String filterKey, String choiceKey, bool isSelected) {
    filterKey = filterKey.toLowerCase();
    choiceKey = choiceKey.toLowerCase().replaceAll(".", "_");
    Map<String, bool> filterMap = choiceFilters[filterKey]!;
    filterMap[choiceKey] = isSelected;
    filterMap["filterActive"] = false;
    for (var option in filterMap.values) {
      if (option == true) {
        filterMap["filterActive"] = true;
        break;
      }
    }
  }

  @action
  Future<void> filterOffers(
    TextEditingController leastPriceController,
    TextEditingController mostPriceController,
  ) async {
    List<String> offerIds = [];
    List<String> tmpIds = [];
    List<String> filterOfferIds = [];
    Map<String, bool> filterMap;
    for (DocumentSnapshot offerSnapshot in allOffers) {
      offerIds.add(offerSnapshot.id);
    }
    for (var choiceFilterKey in choiceFilters.keys) {
      filterMap = choiceFilters[choiceFilterKey]!;
      if (filterMap["filterActive"] == true) {
        tmpIds = [];
        for (var filterMapKey in filterMap.keys) {
          if (filterMap[filterMapKey] == true) {
            if (filterMapKey.compareTo("filterActive") != 0) {
              // filterOfferIds = await firestoreService.getFilterOfferIds(filterMapKey);
              tmpIds = List.from(tmpIds)..addAll(filterOfferIds);
            }
          }
        }
        offerIds.removeWhere((element) => !tmpIds.contains(element));
      }
    }

    filterResults = List.of(allOffers);
    filterResults.removeWhere((element) => !offerIds.contains(element.id));
    if (leastPriceController.text != "") {
      double leastPrice = double.parse(leastPriceController.text);
      filterResults.removeWhere(
          (element) => double.parse(element["product_price"]) < leastPrice);
    }
    if (mostPriceController.text != "") {
      double mostPrice = double.parse(mostPriceController.text);
      filterResults.removeWhere(
          (element) => double.parse(element["product_price"]) > mostPrice);
    }
    updateResultOffers(filterResults);
  }

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }

  //foreground notification
  @action
  Future<void> sendLastDayNotificationInForeGround(
      DateTime endDate, String offerSite, String offerHeader, String id) async {
    print(checkSent(id));
    if (checkSent(id) == false) {
      // Check if the end date is within 1 day from the current date
      notificationIds.add(id);
      // Show notification using a notification service

      await PushNotifications().showNotification(
        title: offerSite,
        body: offerHeader,
        payload: id,
      );
      setTrueForSentNotification(id);
      print("Last day notification sent in foreground");
    }
  }

  @action
  void resetNotificationFlags() {
    for (String notificationId in notificationIds) {
      _notificationDisplayedMap[notificationId] = false;
    }
  }

  @action
  bool checkSent(String notificationId) {
    //Bildirim gönderildi mi kontrol et. Gönderildiyse true

    if (_notificationDisplayedMap[notificationId] == true ||
        notificationIds.contains(notificationId)) {
      return true;
    } else {
      return false;
    }
  }

  @action
  void setTrueForSentNotification(String notificationId) {
    if (notificationIds.contains(notificationId)) {
      // Display the notification
      print('Notification $notificationId displayed');

      // Set flag to indicate that notification has been displayed
      _notificationDisplayedMap[notificationId] = true;
    }
  }
}
