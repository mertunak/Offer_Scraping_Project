import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _offer =
      FirebaseFirestore.instance.collection("offers");

  Future<QuerySnapshot> getOffers() => _offer.get();

  Future<List<String>> getFilterTabletIds(String indexKey) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('inverted_index')
        .doc(indexKey)
        .get();

    if (documentSnapshot.exists) {
      final Map<String, dynamic> tabletIdsMap =
          documentSnapshot.data() as Map<String, dynamic>;
      return List<String>.from(tabletIdsMap["tablet_ids"]);
    }else{
      return [];
    }
  }
}
