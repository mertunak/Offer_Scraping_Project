import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobx/mobx.dart';
part 'offer_preferences_viewmodel.g.dart';

class OfferPreferencesViewModel = _OfferPreferencesViewModelBase
    with _$OfferPreferencesViewModel;

abstract class _OfferPreferencesViewModelBase extends BaseViewModel with Store {
  final urlCheck = RegExp(r"^https:\/\/www\..*\.(com|tr|org)$");
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late UserModel currentUser;

  List<DocumentSnapshot> allSites = [];

  @observable
  ObservableList<DocumentSnapshot> prefered = ObservableList.of([]);

  @observable
  ObservableList<DocumentSnapshot> notPrefered = ObservableList.of([]);

  @action
  Future<void> changePreference(bool isPrefered, String siteId) async {
    final siteDoc = allSites.firstWhere((element) => element.id == siteId);
    if (isPrefered) {
      currentUser.favSites.remove(siteId);
      prefered.remove(siteDoc);
      notPrefered.add(siteDoc);
    } else {
      currentUser.favSites.add(siteId);
      notPrefered.remove(siteDoc);
      prefered.add(siteDoc);
    }
    await firestoreService.users
        .doc(currentUser.id)
        .update({'fav_sites': currentUser.favSites});
  }

  Future<void> getAllSites() async {
    final data = await firestoreService.getscrapedSites();
    allSites = data.docs;
  }

  Future<void> changeNewSitePreference(String url) async {
    final siteDoc = await firestoreService.getSiteByUrl(url);
    currentUser.favSites.add(siteDoc.id);
    await firestoreService.users
        .doc(currentUser.id)
        .update({'fav_sites': currentUser.favSites});
  }

  Future<void> setCurrentUser() async {
    final User user = auth.currentUser!;
    final uid = user.uid;
    currentUser = await firestoreService.getCurrentUser(uid);
    print(currentUser.favSites);
  }

  void splitPreferencesSites() {
    prefered.clear();
    notPrefered.clear();
    for (var siteDoc in allSites) {
      if (currentUser.favSites.contains(siteDoc.id)) {
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
