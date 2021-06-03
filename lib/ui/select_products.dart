import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/billing_info.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/price.dart';
import 'package:project_netsurf/common/models/retailer.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/bottomsheet.dart';
import 'package:project_netsurf/common/ui/edittext.dart';
import 'package:project_netsurf/common/models/product.dart';
import 'package:project_netsurf/common/product_constant.dart';
import 'package:project_netsurf/ui/biller.dart';

class SelectProductsPage extends StatefulWidget {
  final String title;
  final Customer customerData;

  SelectProductsPage({Key key, this.title, this.customerData})
      : super(key: key);

  @override
  SelectProductsPageState createState() => SelectProductsPageState();
}

class SelectProductsPageState extends State<SelectProductsPage> {
  List<TextEditingController> _controllers = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController discountedPriceController =
      new TextEditingController();
  final TextEditingController categoryTextController =
      new TextEditingController();
  final TextEditingController itemTextController = new TextEditingController();
  final TextEditingController discountController = new TextEditingController();

  Price price = Price(0, 0, 0);
  List<Product> selectedProducts = [];
  Product selectedCategory = Products.getProductCategory(null);

  @override
  void initState() {
    super.initState();
    print("Selected customer: " + widget.customerData.name ?? "");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<Product> products = await Preference.getProducts();
      products.forEach((element) {
        print("Fetched" + element.name);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Net Surf", textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Card(
              child: Container(
                padding: EdgeInsets.all(5),
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: selectedProducts.length ?? 0,
                    separatorBuilder: (context, int) {
                      return Container(
                        padding: EdgeInsets.only(
                            left: 5, top: 0, right: 5, bottom: 0),
                        child: Divider(
                          thickness: 1,
                          height: 6,
                        ),
                      );
                    },
                    itemBuilder: (context, index) {
                      _controllers.add(new TextEditingController(text: "1"));
                      return Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 0, top: 8, right: 5, bottom: 8),
                              child: Text(
                                  selectedProducts[index].getDisplayName(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      height: 1.3),
                                  textAlign: TextAlign.start),
                            ),
                          ),
                          Container(
                            width: 80,
                            child: Center(
                              child: Text(itemPrice(index),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                  textAlign: TextAlign.left),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 3),
                            width: 80,
                            height: 30,
                            child: InputText(
                              controller: _controllers[index],
                              onText: (value) {
                                setState(() {
                                  print(value);
                                  if (value != null) {
                                    if (value.isEmpty) {
                                      selectedProducts[index].quantity = 0;
                                      selectedCategory.quantity = 0;
                                      _controllers[index].clear();
                                    } else {
                                      int quant = double.parse(value).ceil();
                                      if (quant > 0) {
                                        selectedProducts[index].quantity =
                                            quant;
                                        selectedCategory.quantity = quant;
                                      } else {
                                        selectedProducts[index].quantity = 0;
                                        selectedCategory.quantity = 0;
                                        _controllers[index].clear();
                                      }
                                    }
                                  }
                                  calculateTotal();
                                });
                              },
                            ),
                          )
                        ],
                      ));
                    }),
              ),
            ),
          ),
          CustomButton(
              buttonText: selectedCategory.name ?? "Select Category",
              onClick: () {
                showModelBottomSheet(
                    context,
                    _scaffoldKey,
                    Products.getProductCategories(),
                    categoryTextController, (product) {
                  if (product != null) {
                    setState(() {
                      selectedCategory = product;
                      calculateTotal();
                    });
                  }
                });
              }),
          CustomButton(
            buttonText: _getButtonText(),
            onClick: () {
              showModelBottomSheet(
                  context,
                  _scaffoldKey,
                  Products.getProductsFromCategoryId(selectedCategory),
                  itemTextController, (product) {
                if (product != null) {
                  setState(() {
                    if (!selectedProducts.contains(product)) {
                      selectedProducts.add(product);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Item is already in the list!"),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                    calculateTotal();
                  });
                }
              });
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: EdgeInsets.only(left: 16, top: 5, right: 16, bottom: 2),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12, top: 5, right: 12, bottom: 5),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Total ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  RUPEE_SYMBOL + " " + price.dispTotal(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[800], fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Discount ",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  "% ",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.grey[800], fontSize: 15),
                                ),
                                Container(
                                  width: 65,
                                  height: 30,
                                  child: TextFormField(
                                    cursorWidth: 1.3,
                                    controller: discountController,
                                    textAlign: TextAlign.start,
                                    onTap: () {
                                      setState(() {
                                        price.finalAmt = price.total;
                                        discountController.clear();
                                        discountedPriceController.clear();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 18),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          (RegExp("[.0-9]"))),
                                    ],
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    textAlignVertical: TextAlignVertical.center,
                                    cursorColor: Colors.black,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value != null) {
                                          if (value.isNotEmpty) {
                                            double discount =
                                                double.parse(value);
                                            price.discountAmt = 0;
                                            if (discount > 0) {
                                              price.discountAmt = price.total *
                                                  (discount / 100);
                                              price.finalAmt = price.total -
                                                  price.discountAmt;
                                              if (price.finalAmt < 0) {
                                                price.finalAmt = 0;
                                              }
                                            }
                                          } else {
                                            price.finalAmt = price.total;
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Text(
                                  RUPEE_SYMBOL + " ",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Colors.grey[800], fontSize: 15),
                                ),
                                Container(
                                  width: 60,
                                  height: 30,
                                  child: TextFormField(
                                    cursorWidth: 1.3,
                                    controller: discountedPriceController,
                                    textAlign: TextAlign.start,
                                    onTap: () {
                                      setState(() {
                                        price.finalAmt = price.total;
                                        discountController.clear();
                                        discountedPriceController.clear();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 18),
                                    ),
                                    inputFormatters: [
                                      new LengthLimitingTextInputFormatter(4),
                                      FilteringTextInputFormatter.allow(
                                          (RegExp("[.0-9]"))),
                                    ],
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    textAlignVertical: TextAlignVertical.center,
                                    cursorColor: Colors.black,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value != null) {
                                          if (value.isNotEmpty) {
                                            double discountPrice =
                                                double.parse(value);
                                            price.discountAmt = 0;
                                            if (discountPrice > 0) {
                                              price.finalAmt =
                                                  price.total - discountPrice;
                                              if (price.finalAmt < 0) {
                                                price.finalAmt = 0;
                                              }
                                            }
                                          } else {
                                            price.finalAmt = price.total;
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          alignment: Alignment.topLeft,
                          child: Center(
                            child: Text(
                              RUPEE_SYMBOL + " " + price.dispFinalAmt(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CustomButton(
                  buttonText: "Done",
                  onClick: () async {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (__) =>
                                new BillerPage(billing: createBilling())));
                  }),
            ],
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (selectedCategory != null &&
        selectedCategory.name != null &&
        selectedCategory.name.isNotEmpty) {
      return "Select Item from: ${selectedCategory.weight}";
    } else {
      return "Select product category first";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void calculateTotal() {
    price.total = 0;
    for (var item in selectedProducts) {
      print(item.price);
      price.total += item.price * item.quantity;
      price.finalAmt = price.total;
    }
  }

  String itemPrice(int index) {
    return RUPEE_SYMBOL +
        " " +
        (selectedProducts[index].price * selectedProducts[index].quantity)
            .ceil()
            .toString();
  }

  Billing createBilling() {
    BillingInfo billingInfo = BillingInfo("", "123412", DateTime.now());
    Retailer retailer = Retailer(name: "Shrinidhi", mobileNo: "9876567342");
    Billing billing = Billing(
        billingInfo, retailer, widget.customerData, selectedProducts, price);
    return billing;
  }
}
