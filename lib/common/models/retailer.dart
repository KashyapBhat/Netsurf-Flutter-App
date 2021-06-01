class Retailer {
  String _name;
  String _mobileNo;
  String _refId;
  String _address;
  String _email;

  String get name => _name;

  String get mobileNo => _mobileNo;

  String get refId => _refId;

  String get address => _address;

  String get email => _email;

  set name(String value) {
    _name = value;
  }

  set mobileNo(String value) {
    _mobileNo = value;
  }

  set email(String value) {
    _email = value;
  }

  set address(String value) {
    _address = value;
  }

  set refId(String value) {
    _refId = value;
  }

  Retailer(
      {String name,
      String mobileNo,
      String refId,
      String address,
      String email}) {
    _name = name;
    _mobileNo = mobileNo;
    _refId = refId;
    _address = address;
    _email = email;
  }

  Retailer.fromJson(dynamic json) {
    _name = json["name"];
    _mobileNo = json["mobileNo"];
    _refId = json["refId"];
    _address = json["address"];
    _email = json["email"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["name"]    = _name;
    map["mobileNo"]  = _mobileNo;
    map["refId"]    = _refId;
    map["address"]  = _address;
    map["email"] =  _email;
    return map;
  }
}
