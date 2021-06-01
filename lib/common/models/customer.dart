class Customer {
  String _name;
  String _mobileNo;
  String _cRefId;
  String _address;
  String _email;

  String get name => _name;

  String get mobileNo => _mobileNo;

  String get cRefId => _cRefId;

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

  set cRefId(String value) {
    _cRefId = value;
  }

  Customer(String name, String mobileNo, String cRefId, String address,
      String email) {
    _name = name;
    _mobileNo = mobileNo;
    _cRefId = cRefId;
    _address = address;
    _email = email;
  }

  Customer.fromJson(dynamic json) {
    _name = json["name"];
    _mobileNo = json["mobileNo"];
    _cRefId = json["cRefId"];
    _address = json["address"];
    _email = json["email"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["name"] = _name;
    map["mobileNo"] = _mobileNo;
    map["cRefId"] = _cRefId;
    map["address"] = _address;
    map["email"] = _email;
    return map;
  }
}
