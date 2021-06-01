import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/billing_info.dart';
import 'package:project_netsurf/common/models/price.dart';
import 'package:project_netsurf/common/models/product.dart';
import 'package:project_netsurf/common/models/retailer.dart';

class Billing {
  BillingInfo billingInfo;
  Retailer retailer;
  Customer customer;
  List<Product> selectedProducts;
  Price price;

  Billing(this.billingInfo, this.retailer, this.customer, this.selectedProducts,
      this.price);

  Billing.fromJson(dynamic json) {
    billingInfo = json["billingInfo"] != null
        ? BillingInfo.fromJson(json["billingInfo"])
        : null;
    retailer =
        json["retailer"] != null ? Retailer.fromJson(json["retailer"]) : null;
    customer =
        json["customer"] != null ? Customer.fromJson(json["customer"]) : null;
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
}
