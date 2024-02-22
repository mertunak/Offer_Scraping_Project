class UserModel {
  String? name;
  String? email;
  String? password;
  String? uid;

  UserModel({
    this.name,
    this.email,
    this.password,
    this.uid,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    password = json['password'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['uid'] = uid;
    return data;
  }
}
