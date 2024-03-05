import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/product/models/user_model.dart';

class FirestoreService {
  final CollectionReference _offers =
      FirebaseFirestore.instance.collection("offers");

  final CollectionReference _scrapedSites =
      FirebaseFirestore.instance.collection("scraped_sites");
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<QuerySnapshot> getOffers() => _offers.get();

  Future<QuerySnapshot> getscrapedSites() => _scrapedSites.get();

  Future<UserModel> getCurrentUser(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
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
}