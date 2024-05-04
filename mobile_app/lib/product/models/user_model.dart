class UserModel {
  late String _id;
  late String _email;
  late String _password;
  late String _name;
  late String _surname;
  late List<String> _favSites;
  late List<String> _favOffers;

  UserModel.mock(this._id, this._email, this._password, this._name,
      this._surname, this._favSites, this._favOffers);

  UserModel(this._id, this._email, this._password, this._name, this._surname,
      this._favSites, this._favOffers);

  String? get id => _id;
  void setId(String id) => _id = id;
  String? get email => _email;
  String? get password => _password;
  String? get name => _name;
  String? get surname => _surname;
  List<String> get favSites => _favSites;
  List<String> get favOffers => _favOffers;
  set setFavSites(List<String> favSites) {
    _favSites = favSites;
  }

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
