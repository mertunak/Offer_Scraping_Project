import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/data/user_mock.dart';
import 'package:mobile_app/product/models/site_model.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobx/mobx.dart';
part 'offer_preferences_viewmodel.g.dart';

class OfferPreferencesViewModel = _OfferPreferencesViewModelBase
    with _$OfferPreferencesViewModel;

abstract class _OfferPreferencesViewModelBase extends BaseViewModel with Store {
  final urlCheck = RegExp(r"^https:\/\/www\..*\.(com|tr|org)$");
  final FirestoreService firestoreService = FirestoreService();
  UserModel currentUser = UserMock.users[0];

  List<DocumentSnapshot> allSites = [];

  @observable
  ObservableList<DocumentSnapshot> prefered = ObservableList.of([]);

  @observable
  ObservableList<DocumentSnapshot> notPrefered = ObservableList.of([]);

  @action
  void changePreference(bool isPrefered, SiteModel site) {
    final siteDoc = allSites.firstWhere((element) => element.id == site.id);
    if (isPrefered) {
      UserMock.users[0].favSites!.add(site.id!);
      prefered.remove(siteDoc);
      notPrefered.add(siteDoc);
    } else {
      UserMock.users[0].favSites!.remove(site.id!);
      notPrefered.remove(siteDoc);
      prefered.add(siteDoc);
    }
  }

  Future<void> getAllSites() async {
    final data = await firestoreService.getscrapedSites();
    allSites = data.docs;
  }

  void splitPreferencesSites() {
    if (currentUser.favSites != null) {
      for (var siteDoc in allSites) {
        if (currentUser.favSites!.contains(siteDoc.id)) {
          prefered.add(siteDoc);
        } else {
          notPrefered.add(siteDoc);
        }
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
