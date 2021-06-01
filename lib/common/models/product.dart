class Product {
  int _id;
  String _name;
  String _weight;
  double _price;
  int _quantity;
  int _productCategoryId;

  int get id => _id;

  String get name => _name;

  String get weight => _weight;

  double get price => _price;

  int get quantity => _quantity;

  int get productCategoryId => _productCategoryId;

  set id(int value) {
    _id = value;
  }

  set name(String value) {
    _name = value;
  }

  set productCategoryId(int value) {
    _productCategoryId = value;
  }

  set quantity(int value) {
    _quantity = value;
  }

  set price(double value) {
    _price = value;
  }

  set weight(String value) {
    _weight = value;
  }

  Product(int id, String name, String weight, double price, int quantity,
      int productCategoryId) {
    _id = id;
    _name = name;
    _weight = weight;
    _price = price;
    _quantity = quantity;
    _productCategoryId = productCategoryId;
  }

  Product.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _weight = json["weight"];
    _price = json["price"];
    _quantity = json["quantity"];
    _productCategoryId = json["productCategoryId"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["weight"] = _weight;
    map["price"] = _price;
    map["quantity"] = _quantity;
    map["productCategoryId"] = _productCategoryId;
    return map;
  }

  String getDisplayName() {
    return name + " - " + weight;
  }

  String getDispPrice() {
    return price.ceil().toString();
  }

  String getDispTotal() {
    final total = this.price * this.quantity;
    return total.ceil().toString();
  }
}
