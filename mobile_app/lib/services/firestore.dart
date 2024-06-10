import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/product/managers/user_manager.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final CollectionReference _offers =
      FirebaseFirestore.instance.collection("offers");

  final CollectionReference _favOffers =
      FirebaseFirestore.instance.collection("fav_offers");

  final CollectionReference _scrapedSites =
      FirebaseFirestore.instance.collection("scraped_sites");
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<QuerySnapshot> getOffers() => _offers.get();

  Future<QuerySnapshot> getScrapedSites() => _scrapedSites.get();

  Future<UserModel> getCurrentUser(String uid) async {
    DocumentSnapshot documentSnapshot = await users.doc(uid).get();
    return UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<List<String>> getCurrentUserFavSites(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>)
        .favSites;
  }

  Future<List<String>> getCurrentUserFavOffers(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>)
        .favOffers;
  }

  Future<List<DocumentSnapshot>> getOffersBySites(
      List<String> siteNames) async {
    if (siteNames.isEmpty) {
      return [];
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("offers")
        .where("site", whereIn: siteNames)
        .get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot> getSiteByUrl(String url) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("scraped_sites")
        .where("url", isEqualTo: url)
        .get();

    return snapshot.docs.first;
  }

  Future<List<String>> getSiteNamesByIds(List<String> siteIds) async {
    List<String> favSiteNames = [];
    for (String id in siteIds) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('scraped_sites')
          .doc(id)
          .get();
      if (documentSnapshot.exists) {
        String name = documentSnapshot.get('site_name');
        favSiteNames.add(name);
      }
    }

    return favSiteNames;
  }

  Future<List<DocumentSnapshot>> getOffersByIds(List<String> offerIds) async {
    List<DocumentSnapshot> offers = [];
    for (String id in offerIds) {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('offers').doc(id).get();
      if (documentSnapshot.exists) {
        offers.add(documentSnapshot);
      }
    }

    return offers;
  }

  Future<bool> checkSiteExist(String url) async {
    // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
    //     .collection('inverted_index')
    //     .get();
    return false;
  }

  Future<List<String>> getFilterOfferIds(
      String indexKey, String choiceFilterKey) async {
    DocumentSnapshot documentSnapshot;
    if (choiceFilterKey.contains("kategori")) {
      documentSnapshot = await FirebaseFirestore.instance
          .collection('inverted_index_category')
          .doc(indexKey)
          .get();
    } else {
      documentSnapshot = await FirebaseFirestore.instance
          .collection('inverted_index_type')
          .doc(indexKey)
          .get();
    }

    if (documentSnapshot.exists) {
      final Map<String, dynamic> tabletIdsMap =
          documentSnapshot.data() as Map<String, dynamic>;
      return List<String>.from(tabletIdsMap["offer_ids"]);
    } else {
      return [];
    }
  }

  Future<void> addNewUser(UserModel userModel) async {
    await users.doc(userModel.id).set(userModel.toJson());
  }

  Future<void> updateUserInformations(UserModel userModel) async {
    await users.doc(userModel.id).update(userModel.toJson());
  }

  Future<void> saveToFirebase(
      String userId, OfferNotificationModel offerNotificationModel) async {
    final QuerySnapshot querySnapshot =
        await _favOffers.doc(userId).collection('notifications').get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      OfferNotificationModel model =
          OfferNotificationModel.fromJson(data, doc.id);
      if (model.offerID == offerNotificationModel.offerID &&
          model.notificationTime == offerNotificationModel.notificationTime) {
        print('Notification already exists');
        return;
      }
    }
    final CollectionReference notificationsCollection = FirebaseFirestore
        .instance
        .collection('fav_offers')
        .doc(userId)
        .collection('notifications');
    await notificationsCollection
        .doc(offerNotificationModel.id)
        .set(offerNotificationModel.toJson());
  }

  Future<List<OfferNotificationModel>> offerActiveNotifications(
      String userId, String offerId) async {
    List<OfferNotificationModel> matchingNotifications = [];
    final QuerySnapshot querySnapshot =
        await _favOffers.doc(userId).collection('notifications').get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      OfferNotificationModel model =
          OfferNotificationModel.fromJson(data, doc.id);
      if (model.offerID == offerId && !model.isNotified) {
        matchingNotifications.add(model);
      }
    }
    return matchingNotifications;
  }

  Future<List<OfferNotificationModel>> userPassiveNotifcations(
      String userId) async {
    List<OfferNotificationModel> matchingNotifications = [];
    final QuerySnapshot querySnapshot =
        await _favOffers.doc(userId).collection('notifications').get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      OfferNotificationModel model =
          OfferNotificationModel.fromJson(data, doc.id);
      if (model.isNotified) {
        matchingNotifications.add(model);
      }
    }
    return matchingNotifications;
  }

  Future<void> checkNotifications(String userId) async {
    final QuerySnapshot querySnapshot =
        await _favOffers.doc(userId).collection('notifications').get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      OfferNotificationModel model =
          OfferNotificationModel.fromJson(data, doc.id);
      if (!model.isNotified) {
        String scheduledDateStr = model.scheduledDate;
        DateTime scheduledDate =
            DateFormat("dd.MM.yyyy HH:mm").parse(scheduledDateStr);
        print(scheduledDate.toString());
        Timer.periodic(Duration(seconds: 1), (timer) async {
          if (DateTime.now().isAfter(scheduledDate)) {
            // Update Firestore to set isNotified to true
            await _favOffers
                .doc(userId)
                .collection('notifications')
                .doc(doc.id)
                .update({'isNotified': true});
            // Stop the timer
            timer.cancel();
          }
        });
      }
    }
  }

  Future<void> deleteActiveNotification(
      String userId, OfferNotificationModel offerNotificationModel) async {
    await _favOffers
        .doc(userId)
        .collection('notifications')
        .where('offerID', isEqualTo: offerNotificationModel.offerID)
        .where('id', isEqualTo: offerNotificationModel.id)
        .where('notificationTime',
            isEqualTo: offerNotificationModel.notificationTime)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> deleteFavOfferNotifications(
      String userId, OfferModel offerModel) async {
    await _favOffers
        .doc(userId)
        .collection('notifications')
        .where('offerID', isEqualTo: offerModel.id)
        .where('isNotified', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> updateOfferNotification(String userId,
      OfferNotificationModel offerNotificationModel, int day) async {
    final QuerySnapshot querySnapshot =
        await _favOffers.doc(userId).collection('notifications').get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      OfferNotificationModel model =
          OfferNotificationModel.fromJson(data, doc.id);

      print("sfdsfdsfs");
      if (model.id == offerNotificationModel.id) {
        print("asödşlsd");
        await _favOffers
            .doc(userId)
            .collection('notifications')
            .doc(doc.id)
            .update({'notificationTime': day});
        return;
      }
    }
  }
}
