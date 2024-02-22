class SiteModel {
  late final String _id;
  late final String _siteName;
  late final String _url;
  late final String _scrapingDate;
  
  SiteModel();
  
  String? get id => _id;
  String? get siteName => _siteName;
  String? get url => _url;
  String? get scrapingDate => _scrapingDate;

  SiteModel.fromJson(Map<String, dynamic> json, String id) {
    _id = id;
    _siteName = json['site_name'];
    _url = json['url'];
    _scrapingDate = json['scraping_date'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = _id;
    data['site_name'] = _siteName;
    data['url'] = _url;
    data['scraping_date'] = _scrapingDate;
    return data;
  }
}