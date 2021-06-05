import 'dart:convert';

import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/billing_info.dart';
import 'package:project_netsurf/common/models/price.dart';
import 'package:project_netsurf/common/models/product.dart';

/*
{ "billingInfo": { "description": "", "number": "", "date": "", "dueDate": "" }, "retailer": { "name": "", "mobileNo": "", "refId": "", "address": "", "email": "" },
"customer": { "name": "", "mobileNo": "", "cRefId": "", "address": "", "email": "" }, "productsSelected": [ { "id": 10, "name": "", "weight": "", "price": 10, "quantity": 100, "productCategoryId": 3 },
{ "id": 10, "name": "", "weight": "", "price": 10, "quantity": 100, "productCategoryId": 3 } ], "price": { "price": 10, "discountAmt": 10, "finalAmt": 10 } }
*/

class Billing {
  BillingInfo billingInfo;
  User retailer;
  User customer;
  List<Product> selectedProducts;
  Price price;

  Billing(this.billingInfo, this.retailer, this.customer, this.selectedProducts,
      this.price);

  Billing.fromJson(dynamic json) {
    billingInfo = json["billingInfo"] != null
        ? BillingInfo.fromJson(json["billingInfo"])
        : null;
    retailer =
        json["retailer"] != null ? User.fromJson(json["retailer"]) : null;
    customer =
        json["customer"] != null ? User.fromJson(json["customer"]) : null;
    if (json["selectedProducts"] != null) {
      selectedProducts = [];
      json["selectedProducts"].forEach((v) {
        selectedProducts.add(Product.fromJson(v));
      });
    }
    price = json["price"] != null ? Price.fromJson(json["price"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (billingInfo != null) {
      map["billingInfo"] = billingInfo.toJson();
    }
    if (retailer != null) {
      map["retailer"] = retailer.toJson();
    }
    if (customer != null) {
      map["customer"] = customer.toJson();
    }
    if (selectedProducts != null) {
      map["selectedProducts"] =
          selectedProducts.map((v) => v.toJson()).toList();
    }
    if (price != null) {
      map["price"] = price.toJson();
    }
    return map;
  }

  static String encode(Billing billing) => json.encode(billing.toJson());

  static Billing decode(String billing) =>
      Billing.fromJson(json.decode(billing));

  static String encodeList(List<Billing> products) => json.encode(
        products.map<Map<String, dynamic>>((bill) => bill.toJson()).toList(),
      );

  static List<Billing> decodeList(String bills) =>
      (json.decode(bills) as List<dynamic>)
          .map<Billing>((bill) => Billing.fromJson(bill))
          .toList();
}
