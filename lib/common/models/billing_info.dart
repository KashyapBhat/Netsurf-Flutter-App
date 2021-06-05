class BillingInfo {
  String _description;
  String _number;
  DateTime _date;
  DateTime _dueDate;

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get number => _number;

  DateTime get date => _date;

  DateTime get dueDate => _dueDate;

  set number(String value) {
    _number = value;
  }

  set dueDate(DateTime value) {
    _dueDate = value;
  }

  set date(DateTime value) {
    _date = value;
  }

  BillingInfo(String description, String number, DateTime date,
      {DateTime dueDate}) {
    _description = description;
    _number = number;
    _date = date;
    _dueDate = dueDate;
  }

  BillingInfo.fromJson(dynamic json) {
    _description = json["description"];
    _number = json["number"];
    _date = DateTime.tryParse(json["date"]);
    _dueDate = DateTime.tryParse(json["dueDate"] ?? "");
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["description"] = _description;
    map["number"] = _number;
    map["date"] = _date.toIso8601String();
    map["dueDate"] = _dueDate?.toIso8601String();
    return map;
  }
}
