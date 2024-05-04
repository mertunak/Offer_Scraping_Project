import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/product/models/user_model.dart';
import 'package:mobile_app/services/firestore.dart';

class UserManager {
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late UserModel currentUser;
  static UserManager? _instance;

  UserManager._init();

  static UserManager get instance {
    _instance ??= UserManager._init();
    return _instance!;
  }

  Future<void> setCurrentUser() async {
    final User user = auth.currentUser!;
    final uid = user.uid;
    currentUser = await firestoreService.getCurrentUser(uid);
  }

  Future<void> updateCurrentUserFavSites() async {
    currentUser.setFavSites =
        await firestoreService.getCurrentUserFavSites(currentUser.id!);
  }

  Future<void> updateCurrentUserFavOffers() async {
    currentUser.setFavSites =
        await firestoreService.getCurrentUserFavOffers(currentUser.id!);
  }

  Future<void> changeNewSitePreference(String url) async {
    final siteDoc = await firestoreService.getSiteByUrl(url);
    currentUser.favSites.add(siteDoc.id);
    await firestoreService.users
        .doc(currentUser.id)
        .update({'fav_sites': currentUser.favSites});
  }

  Future<void> changePreference(bool isPrefered, String siteId) async {
    if (isPrefered) {
      currentUser.favSites.remove(siteId);
    } else {
      currentUser.favSites.add(siteId);
    }
    await firestoreService.users
        .doc(currentUser.id)
        .update({'fav_sites': currentUser.favSites});
  }

  Future<void> changeFavorite(bool isFavorite, String offerId) async {
    if (isFavorite) {
      currentUser.favOffers.remove(offerId);
    } else {
      currentUser.favOffers.add(offerId);
    }
    await firestoreService.users
        .doc(currentUser.id)
        .update({'fav_offers': currentUser.favOffers});
    await updateCurrentUserFavOffers();
  }
}
