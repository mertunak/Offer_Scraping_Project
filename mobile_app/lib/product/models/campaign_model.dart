// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: unnecessary_getters_setters

class CampaignModel {
  late final String _id;
  late final String _header;
  late final String _description;
  late final String _link;
  late final String _site;
  late final String _img;
  late final String _startDate;
  late final String _endDate;

  CampaignModel();

  String get id => _id;
  void setId(String id) => _id = id;
  String get header => _header;
  String get description => _description;
  String get link => _link;
  String get site => _site;
  String get img => _img;
  String get startDate => _startDate;
  String get endDate => _endDate;

  CampaignModel.fromJson(Map<String, dynamic> json) {
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
    data['campaign_header'] = _header;
    data['campaign_header'] = _description;
    data['campaign_link'] = _link;
    data['campaign_site'] = _site;
    data['campaign_img'] = _img;
    data['campaign_startDate'] = _startDate;
    data['campaign_endDate'] = _endDate;
    return data;
  }
}
