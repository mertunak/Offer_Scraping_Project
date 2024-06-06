import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/product/models/offer_model.dart';
import 'package:mobile_app/product/models/offer_notifcation_model.dart';
import 'package:mobile_app/product/models/user_model.dart';

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

  Future<List<String>> getFilterTabletIds(String indexKey) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('inverted_index')
        .doc(indexKey)
        .get();

    if (documentSnapshot.exists) {
      final Map<String, dynamic> tabletIdsMap =
          documentSnapshot.data() as Map<String, dynamic>;
      return List<String>.from(tabletIdsMap["tablet_ids"]);
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

  Future<void> saveFavOfferNotification(
      OfferNotificationModel offerNotificationModel) async {
    await _favOffers
        .doc(offerNotificationModel.userId)
        .set(offerNotificationModel.toJson());
  }

  Future<void> addOrUpdateOfferData(
      OfferNotificationModel offerNotificationModel) async {
    await _favOffers
        .doc(offerNotificationModel.userId)
        .set(offerNotificationModel.toJson(), SetOptions(merge: true));
  }

  Future<bool> favOffersExists(String userID) async {
    final documentReference = await _favOffers.doc(userID).get();
    return documentReference.exists;
  }

  Future<void> updateNotificationStatus(String userId, String offerId) async {
    print("bbbbb");
    await _favOffers.doc(userId).update({
      'offer_data.$offerId.isNotified': true,
    });
  }

  Future<List<OfferNotificationModel>> getAllNotifications(
      String userId) async {
    try {
      DocumentSnapshot snapshot = await _favOffers.doc(userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        OfferNotificationModel model = OfferNotificationModel.fromJson(data);
        return [model];
      } else {
        return [];
      }
    } catch (e) {
      print("Failed to fetch notifications: $e");
      return [];
    }
  }
}
