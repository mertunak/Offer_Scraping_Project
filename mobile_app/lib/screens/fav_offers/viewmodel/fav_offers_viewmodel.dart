import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobx/mobx.dart';
part 'fav_offers_viewmodel.g.dart';

class FavOffersViewModel = _FavOffersVieModelBase with _$FavOffersViewModel;

abstract class _FavOffersVieModelBase extends BaseViewModel with Store {
  final FirestoreService firestoreService = FirestoreService();
  List<DocumentSnapshot> allOffers = [];

  @observable
  ObservableList<DocumentSnapshot> favOffers = ObservableList.of([]);

  Future<void> getFavOffers() async {
    favOffers = ObservableList.of(await firestoreService
        .getOffersByIds(UserManager.instance.currentUser.favOffers));
    print("Fav Offers: $favOffers");
  }

  @override
  void init() {}

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }

  @action
  Future<void> getAllOffers() async {
    allOffers = await firestoreService.getOffersBySites(await firestoreService
        .getSiteNamesByIds(UserManager.instance.currentUser.favSites));
  }

  @action
  Future<void> deleteNotifications(String offerId) async {
    print(UserManager.instance.currentUser.id);
    await firestoreService.deleteOfferFromUserNotifications(
        UserManager.instance.currentUser.id ?? "", offerId);
  }
}
