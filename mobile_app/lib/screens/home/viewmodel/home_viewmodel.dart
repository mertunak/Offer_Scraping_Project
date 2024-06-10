import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobile_app/screens/fav_offers/viewmodel/fav_offers_viewmodel.dart';
import 'package:mobile_app/screens/offer/viewmodel/offer_viewmodel.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobx/mobx.dart';
part 'home_viewmodel.g.dart';

class HomeViewModel = _HomeViewModelBase with _$HomeViewModel;

abstract class _HomeViewModelBase extends BaseViewModel with Store {
  OfferViewModel offerviewModel = OfferViewModel();
  FavOffersViewModel favOffersViewModel = FavOffersViewModel();

  @override
  void init() {}

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }

  /* Future<List<OfferNotificationModel>> getSetNotifications() async {
    List<OfferNotificationModel> notificationsList = await FirestoreService()
        .getAllNotifications(UserManager.instance.currentUser.id ?? "");
    List<OfferNotificationModel> notifications = [];
    for (var notification in notificationsList) {
      var offerData = notification.offerData;
      for (var offerId in offerData.keys) {
        if (offerData[offerId] is Map<String, dynamic> &&
            offerData[offerId]?['isNotified'] == false) {
          // Check if isNotified is false
          notifications.add(notification); // Add to notifications
        }
      }
    }
    return notifications;
  } */
}
