import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _campaigns =
      FirebaseFirestore.instance.collection("campaigns");

  Future<QuerySnapshot> getCampaigns() => _campaigns.get();

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
