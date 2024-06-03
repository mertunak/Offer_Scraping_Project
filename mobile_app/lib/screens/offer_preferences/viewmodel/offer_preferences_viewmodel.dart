import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobx/mobx.dart';
part 'offer_preferences_viewmodel.g.dart';

class OfferPreferencesViewModel = _OfferPreferencesViewModelBase
    with _$OfferPreferencesViewModel;

abstract class _OfferPreferencesViewModelBase extends BaseViewModel with Store {
  final FirestoreService firestoreService = FirestoreService();
  final urlCheck = RegExp(r"^https:\/\/www\..*\.(com|tr|org)$");

  List<DocumentSnapshot> allSites = [];

  @observable
  ObservableList<DocumentSnapshot> prefered = ObservableList.of([]);

  @observable
  ObservableList<DocumentSnapshot> notPrefered = ObservableList.of([]);

  @action
  Future<void> changePreference(bool isPrefered, String siteId) async {
    final siteDoc = allSites.firstWhere((element) => element.id == siteId);
    if (isPrefered) {
      prefered.remove(siteDoc);
      notPrefered.add(siteDoc);
    } else {
      notPrefered.remove(siteDoc);
      prefered.add(siteDoc);
    }
    UserManager.instance.changePreference(isPrefered, siteId);
  }

  Future<void> getAllSites() async {
    final data = await firestoreService.getScrapedSites();
    allSites = data.docs;
  }

  void splitPreferencesSites() {
    prefered.clear();
    notPrefered.clear();
    for (var siteDoc in allSites) {
      if (UserManager.instance.currentUser.favSites.contains(siteDoc.id)) {
        prefered.add(siteDoc);
      } else {
        notPrefered.add(siteDoc);
      }
    }
  }

  bool siteExist(String url) {
    for (var siteDoc in allSites) {
      if (siteDoc.get("url") == url) {
        return true;
      }
    }
    return false;
  }

  @override
  void init() {}

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }
}
