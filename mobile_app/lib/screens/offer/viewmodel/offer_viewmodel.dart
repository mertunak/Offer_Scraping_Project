import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobx/mobx.dart';

import '../../../services/firestore.dart';
part 'offer_viewmodel.g.dart';

class OfferViewModel = _OfferViewModelBase with _$OfferViewModel;

abstract class _OfferViewModelBase extends BaseViewModel with Store {
  final FirestoreService firestoreService = FirestoreService();
  List<DocumentSnapshot> allOffers = [];
  List<DocumentSnapshot> filterResults = [];
  List<bool> isSelected = <bool>[true, false, false, false];

  Map<String, bool> categoryMap = {
    'filterActive': false,
    'giyim': false,
    'elektronik': false,
    'ev': false,
    'finans': false,
    'tatil': false,
    'ulaşım': false,
    'telekom': false,
    'bebek': false,
    'araç': false,
    'kozmetik': false,
    'market': false,
  };

  Map<String, bool> typeMap = {
    'filterActive': false,
    'özel günler': false,
    'indirim': false,
    'kupon': false,
    'çekiliş': false,
  };

  // Map<String, bool> siteMap = {
  //   'filterActive': false,
  //   'vatan': false,
  //   'mediamarkt': false,
  //   'teknosa': false,
  // };

  @observable
  ObservableList<DocumentSnapshot> resultOffers = ObservableList.of([]);

  @observable
  ObservableList<String> favSiteNames = ObservableList.of([]);

  @observable
  int resultCount = 0;

  @observable
  Map<String, Map<String, bool>> choiceFilters = {};

  _OfferViewModelBase() {
    init();
  }

  @override
  void init() {
    choiceFilters = {
      'kategori': categoryMap,
      'tip': typeMap,
      // 'site': siteMap,
    };
  }

  @action
  Future<void> getAllOffers() async {
    allOffers = await firestoreService.getOffersBySites(await firestoreService
        .getSiteNamesByIds(UserManager.instance.currentUser.favSites));
  }

  @action
  void initOfferLists() {
    updateResultOffers(allOffers);
    filterResults = List.from(allOffers);
  }

  @action
  void updateResultOffers(List<DocumentSnapshot> resultList) {
    resultOffers = ObservableList.of(resultList);
    sortResultOffers(true, true);
    resultCount = resultOffers.length;
  }

  @action
  void sortResultOffers(bool isDate, bool isDesc) {
    print(isDate.toString() + " " + isDesc.toString());
    if (isDate) {
      resultOffers.sort((a, b) => a.get('endDate').compareTo(b.get('endDate')));
    } else {
      resultOffers.sort((a, b) => a.get('site').compareTo(b.get('site')));
    }
    if (isDesc) {
      resultOffers = ObservableList.of(resultOffers.reversed);
    }
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
  Future<void> getFavSiteNames(List<String> siteIds) async {
    favSiteNames =
        ObservableList.of(await firestoreService.getSiteNamesByIds(siteIds));
  }

  @action
  void changeCheckboxFilter(
      String filterKey, String choiceKey, bool isSelected) {
    filterKey = filterKey.toLowerCase();
    choiceKey = choiceKey.toLowerCase();
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
  Future<void> filterOffers() async {
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
              filterOfferIds = await firestoreService.getFilterOfferIds(
                  filterMapKey, choiceFilterKey);
              tmpIds = List.from(tmpIds)..addAll(filterOfferIds);
            }
          }
        }
        offerIds.removeWhere((element) => !tmpIds.contains(element));
      }
    }

    filterResults = List.of(allOffers);
    filterResults.removeWhere((element) => !offerIds.contains(element.id));
    updateResultOffers(filterResults);
  }

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }

  Future<void> monitorAllNotifications(String userId) async {
    List<OfferNotificationModel> notifications =
        await FirestoreService().getAllNotifications(userId);

    for (OfferNotificationModel notification in notifications) {
      notification.offerData.forEach((offerId, offerDetails) {
        String scheduledDateStr = offerDetails['scheduledDate'];
        DateTime scheduledDate =
            DateFormat("dd.MM.yyyy HH:mm").parse(scheduledDateStr);
        print(scheduledDate.toString());
        if (!offerDetails['isNotified']) {
          monitorNotification(userId, offerId, scheduledDate);
        }
      });
    }
  }

  void monitorNotification(
      String userId, String offerId, DateTime scheduledDate) async {
    print("monitorNotification");
    print("scheduledDate: " + scheduledDate.toString());
    print(DateTime.now().toString());
    Timer.periodic(Duration(minutes: 1), (timer) async {
      if (DateTime.now().isAfter(scheduledDate)) {
        // Update Firestore to set isNotified to true
        await FirestoreService().updateNotificationStatus(userId, offerId);
        // Stop the timer
        timer.cancel();
      }
    });
  }
}
