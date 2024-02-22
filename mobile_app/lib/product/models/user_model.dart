class UserModel {
  late final String _id;
  late final String _email;
  late final String _password;
  late final String _name;
  late final String _surname;
  late final List<String> _favSites;
  late final List<String> _favOffers;

  UserModel.mock(this._id, this._email, this._password, this._name, this._surname, this._favSites, this._favOffers);
  UserModel();

  String? get userId => _id;
  void setId(String id) => _id = id;
  String? get email => _email;
  String? get password => _password;
  String? get name => _name;
  String? get surname => _surname;
  List<String>? get favSites => _favSites;
  List<String>? get favOffers => _favOffers;

  UserModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _email = json['email'];
    _password = json['password'];
    _name = json['name'];
    _surname = json['surname'];
    _favSites = List.castFrom<dynamic, String>(json['fav_sites']);
    _favOffers = List.castFrom<dynamic, String>(json['fav_offers']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['email'] = _email;
    data['password'] = _password;
    data['name'] = _name;
    data['surname'] = _surname;
    data['fav_sites'] = _favSites;
    data['fav_offers'] = _favOffers;
    return data;
  }
}
