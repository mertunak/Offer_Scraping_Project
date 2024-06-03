class OfferModel {
  late final String _id;
  late final String _header;
  late final String _description;
  late final String _link;
  late final String _site;
  late final String _img;
  late final String _startDate;
  late final String _endDate;

  OfferModel({
    required String id,
    required String header,
    required String description,
    required String link,
    required String site,
    required String img,
    required String startDate,
    required String endDate,
  })  : _id = id,
        _header = header,
        _description = description,
        _link = link,
        _site = site,
        _img = img,
        _startDate = startDate,
        _endDate = endDate;

  String get id => _id;
  String get header => _header;
  String get description => _description;
  String get link => _link;
  String get site => _site;
  String get img => _img;
  String get startDate => _startDate;
  String get endDate => _endDate;

  OfferModel.fromJson(Map<String, dynamic> json)
      : _id = json['id'] ?? '', // Initialize in the initializer list
        _header = json['title'],
        _description = json['description'],
        _link = json['link'],
        _site = json['site'],
        _img = json['image'],
        _startDate = json['startDate'],
        _endDate = json['endDate'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['title'] = _header;
    data['description'] = _description;
    data['link'] = _link;
    data['site'] = _site;
    data['image'] = _img;
    data['startDate'] = _startDate;
    data['endDate'] = _endDate;
    return data;
  }
}
