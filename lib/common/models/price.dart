class Price {
  double _total = 0;
  double _discountAmt = 0;
  double _finalAmt = 0;

  double get total => _total;

  double get discountAmt => _discountAmt;

  double get finalAmt => _finalAmt;

  set total(double value) {
    _total = value;
  }

  set discountAmt(double value) {
    _discountAmt = value;
  }

  set finalAmt(double value) {
    _finalAmt = value;
  }

  Price(double total, double discountAmt, double finalAmt) {
    _total = total;
    _discountAmt = discountAmt;
    _finalAmt = finalAmt;
  }

  Price.fromJson(dynamic json) {
    _total = json["total"];
    _discountAmt = json["discountAmt"];
    _finalAmt = json["finalAmt"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["total"] = _total;
    map["discountAmt"] = _discountAmt;
    map["finalAmt"] = _finalAmt;
    return map;
  }

  String dispTotal() {
    return total.ceil().toString();
  }

  String dispDiscAmt() {
    return discountAmt.ceil().toString();
  }

  String dispFinalAmt() {
    return finalAmt.ceil().toString();
  }
}
