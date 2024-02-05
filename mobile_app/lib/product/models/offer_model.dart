// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: unnecessary_getters_setters

class OfferModel {
  late final String _id;
  late final String _header;
  late final String _description;
  late final String _link;
  late final String _site;
  late final String _img;
  late final String _startDate;
  late final String _endDate;

  OfferModel();

  String get id => _id;
  void setId(String id) => _id = id;
  String get header => _header;
  String get description => _description;
  String get link => _link;
  String get site => _site;
  String get img => _img;
  String get startDate => _startDate;
  String get endDate => _endDate;

  OfferModel.fromJson(Map<String, dynamic> json) {
    _header = json['Title'];
    _description = json['Description'];
    _link = json['Link'];
    _site = json['Site'];
    _img = json['Image'];
    _startDate = json['StartDate'];
    _endDate = json['EndDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['offer_header'] = _header;
    data['offer_header'] = _description;
    data['offer_link'] = _link;
    data['offer_site'] = _site;
    data['offer_img'] = _img;
    data['offer_startDate'] = _startDate;
    data['offer_endDate'] = _endDate;
    return data;
  }
}
