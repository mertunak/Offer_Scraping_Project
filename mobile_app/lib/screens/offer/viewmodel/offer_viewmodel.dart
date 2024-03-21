import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobx/mobx.dart';

import '../../../services/firestore.dart';
part 'offer_viewmodel.g.dart';

class OfferViewModel = _OfferViewModelBase with _$OfferViewModel;

abstract class _OfferViewModelBase extends BaseViewModel with Store {
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late UserModel currentUser;

  List<DocumentSnapshot> allOffers = [];
  List<DocumentSnapshot> filterResults = [];

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

  @override
  void init() {
    choiceFilters = {
      'marka': brandMap,
      'boyut': sizeMap,
      'site': siteMap,
    };
  }

  Future<void> getAllOffers() async {
    allOffers = await firestoreService.getOffersBySites(
        await firestoreService.getSiteNamesByIds(currentUser.favSites));
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

  Future<void> setCurrentUser() async {
    final User user = auth.currentUser!;
    final uid = user.uid;
    currentUser = await firestoreService.getCurrentUser(uid);
  }

  Future<void> updateCurrentUser() async {
    currentUser.setFavSites = await firestoreService.getCurrentUserFavSites(auth.currentUser!.uid);
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
}
