import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/base/viewmodel/base_viewmodel.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobile_app/services/firestore.dart';
import 'package:mobx/mobx.dart';
part 'notifications_viewmodel.g.dart';

// ignore: library_private_types_in_public_api
class NotificationViewModel = _NotificationViewModelBase
    with _$NotificationViewModel;

abstract class _NotificationViewModelBase extends BaseViewModel with Store {
  UserModel currentUser = UserManager.instance.currentUser;
  List<OfferNotificationModel> notificationsList = [];

  Future<void> getNotifications() async {
    print(currentUser.id ?? '');
    List<OfferNotificationModel> getNotificationsList =
        await FirestoreService().getAllNotifications(currentUser.id ?? '');
    for (var notification in getNotificationsList) {
      var offerData = notification.offerData;
      print(offerData.keys.length);
      for (var offerId in offerData.keys) {
        if (offerData[offerId] is Map<String, dynamic> &&
            offerData[offerId]?['isNotified'] == true) {
          // Check if isNotified is true
          notificationsList.add(notification); // Add to notificationsList
        }
      }
    }
    print(notificationsList.length);
  }

  @override
  void init() {}

  @override
  void setContext(BuildContext context) {
    viewModelContext = context;
  }
}
