import 'package:mobile_app/product/models/user_model.dart';

class UserMock{

  static List<UserModel> users = [
    UserModel.mock("1", "mert.tuna.kurnaz@gmail.com", "123", "Mert Tuna", "Kurnaz", [], []),
    UserModel.mock("2", "ayse.kaya@gmail.com", "321", "Ayse", "Kaya", [], []),
  ];
}