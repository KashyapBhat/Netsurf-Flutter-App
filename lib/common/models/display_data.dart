/*
{ "Aemail": "info.codingcurve@gmail.com", "Alink": "https://codingcurve.in/", "Aname": "Author", "banner": "", "drawer": "", playlink : "" }
*/

class DisplayData {
  String _aemail;
  String _alink;
  String _aname;
  String _banner;
  String _drawer;
  String _playlink;

  String get aemail => _aemail;

  String get alink => _alink;

  String get aname => _aname;

  String get banner => _banner;

  String get drawer => _drawer;

  String get playlink => _playlink;

  DisplayData(
      {String aemail,
      String alink,
      String aname,
      String banner,
      String drawer,
      String playlink}) {
    _aemail = aemail;
    _alink = alink;
    _aname = aname;
    _banner = banner;
    _drawer = drawer;
    _playlink = playlink;
  }

  DisplayData.fromJson(dynamic json) {
    _aemail = json["Aemail"];
    _alink = json["Alink"];
    _aname = json["Aname"];
    _banner = json["banner"];
    _drawer = json["drawer"];
    _playlink = json["playlink"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["Aemail"] = _aemail;
    map["Alink"] = _alink;
    map["Aname"] = _aname;
    map["banner"] = _banner;
    map["drawer"] = _drawer;
    map["playlink"] = _playlink;
    return map;
  }
}
