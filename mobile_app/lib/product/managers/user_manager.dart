import 'package:mobile_app/product/models/user_model.dart';

class UserManager{
  static UserManager? _instance;

  final UserModel currentUser;

  UserManager._init(this.currentUser);
  static UserManager instance(UserModel user) {
    _instance ??= UserManager._init(user);
    return _instance!;
  }
}