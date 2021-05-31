import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/price.dart';
import 'package:project_netsurf/common/models/product.dart';
import 'package:project_netsurf/common/models/retailer.dart';

class Billing {
  BillingInfo billingInfo;
  Retailer retailer;
  CustomerData customerData;
  List<Product> productsSelected;
  Price price;

  Billing(this.billingInfo, this.retailer, this.customerData,
      this.productsSelected, this.price);
}

class BillingInfo {
  String description;
  String number;
  DateTime date;
  DateTime dueDate;

  BillingInfo(this.description, this.number, this.date, this.dueDate);
}
