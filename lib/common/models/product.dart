class Product {
  int id;
  String name;
  String weight;
  double price;
  int quantity;
  int productCategoryId;

  Product(int id, String name, String weight, double price, int quantity, int productCategoryId) {
    this.id = id;
    this.name = name;
    this.weight = weight;
    this.price = price;
    this.quantity = quantity;
    this.productCategoryId = productCategoryId;
  }

  String getDisplayName() {
    return name + " - " + weight;
  }
}
