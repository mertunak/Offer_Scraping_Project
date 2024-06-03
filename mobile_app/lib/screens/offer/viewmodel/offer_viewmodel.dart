import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobx/mobx.dart';

import '../../../services/firestore.dart';
part 'offer_viewmodel.g.dart';

class OfferViewModel = _OfferViewModelBase with _$OfferViewModel;

abstract class _OfferViewModelBase extends BaseViewModel with Store {
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<DocumentSnapshot> allOffers = [];
  List<DocumentSnapshot> filterResults = [];
  List<bool> isSelected = <bool>[true, false, false, false];

  @observable
  ObservableList<DocumentSnapshot> resultOffers = ObservableList.of([]);

  @observable
  ObservableList<String> favSiteNames = ObservableList.of([]);

  @observable
  int resultCount = 0;

  @observable
  Map<String, Map<String, bool>> choiceFilters = {};

  @observable
  List<String> priceFilter = [];

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
      resultOffers
          .sort((a, b) => a.get('endDate').compareTo(b.get('endDate')));
    } else {
      resultOffers
          .sort((a, b) => a.get('site').compareTo(b.get('site')));
    }
    if (isDesc){
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

  @override
  void init() {}

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }
}
