import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/billing_info.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/price.dart';
import 'package:project_netsurf/common/ui/bottomsheet.dart';
import 'package:project_netsurf/common/ui/edittext.dart';
import 'package:project_netsurf/common/models/product.dart';
import 'package:project_netsurf/common/product_constant.dart';
import 'package:project_netsurf/ui/biller.dart';

class SelectProductsPage extends StatefulWidget {
  final String title;
  final User customerData;
  final User retailer;
  final List<Product> allProducts;
  final List<Product> allCategories;

  SelectProductsPage(
      {Key key,
      this.title,
      this.customerData,
      this.allProducts,
      this.allCategories,
      this.retailer})
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
  Product selectedCategory;

  @override
  void initState() {
    super.initState();
    print("Selected customer: " + widget.customerData.name ?? "");
    widget.allCategories.sort((a, b) => a.id.compareTo(b.id));
    selectedCategory = Products.getProductCategorys(widget.allCategories, 1);
    widget.allCategories.forEach((element) {
      print("Products Names: " + element.name);
    });
    widget.allProducts.forEach((element) {
      print("Products: " + element.name);
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          addProductLists(),
          Row(
            children: [
              selectProductList(widget.allCategories),
              selectItemFromProducts(widget.allProducts),
            ],
          ),
          CustomButton(
            buttonText: RUPEE_SYMBOL + " " + price.dispTotal(),
            onClick: () async {
              if (selectedProducts.isNotEmpty && price.total > 0) {
                modalBottomSheetColor(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Add items before moving ahead."),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget addProductLists() {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(5),
          child: ListView.separated(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: selectedProducts.length ?? 0,
              separatorBuilder: (context, int) {
                return Container(
                  padding:
                      EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
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
                        child: Text(selectedProducts[index].getDisplayName(),
                            style: TextStyle(
                                color: Colors.black, fontSize: 14, height: 1.3),
                            textAlign: TextAlign.start),
                      ),
                    ),
                    Container(
                      width: 80,
                      child: Center(
                        child: Text(itemPrice(index),
                            style: TextStyle(color: Colors.black, fontSize: 15),
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
                                  selectedProducts[index].quantity = quant;
                                  selectedCategory.quantity = quant;
                                } else {
                                  selectedProducts[index].quantity = 0;
                                  selectedCategory.quantity = 0;
                                  _controllers[index].clear();
                                }
                              }
                            }
                            calculateTotal();
                            finalAmountReset();
                          });
                        },
                      ),
                    )
                  ],
                ));
              }),
        ),
      ),
    );
  }

  Widget selectProductList(List<Product> allCategories) {
    return Expanded(
      child: Container(
        padding: new EdgeInsets.only(left: 16, top: 8, bottom: 5, right: 8),
        child: SideButtons(
            buttonText: selectedCategory.name ?? "Select Category",
            onClick: () {
              showModelBottomSheet(
                  context, _scaffoldKey, allCategories, categoryTextController,
                  (product) {
                if (product != null) {
                  setState(() {
                    selectedCategory = product;
                    calculateTotal();
                  });
                }
              });
            }),
      ),
    );
  }

  Widget selectItemFromProducts(List<Product> allproducts) {
    return Expanded(
      child: Container(
        padding: new EdgeInsets.only(left: 8, top: 8, bottom: 5, right: 16),
        child: SideButtons(
          buttonText: _getButtonText(),
          onClick: () {
            showModelBottomSheet(
                context,
                _scaffoldKey,
                Products.getProductsFromCategorysIds(
                    allproducts, selectedCategory),
                itemTextController, (product) {
              if (product != null) {
                setState(() {
                  finalAmountReset();
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getButtonText() {
    if (selectedCategory != null &&
        selectedCategory.name != null &&
        selectedCategory.name.isNotEmpty) {
      return "Add products";
    } else {
      return "Select product category first";
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
    Random random = new Random();
    int randomNumber = random.nextInt(90000) + 10000;
    BillingInfo billingInfo =
        BillingInfo("", randomNumber.toString(), DateTime.now());
    Billing billing = Billing(billingInfo, widget.retailer, widget.customerData,
        selectedProducts, price);
    print("Final" + price.finalAmt.toString());
    return billing;
  }

  void modalBottomSheetColor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              margin: EdgeInsets.only(left: 8, top: 26, right: 8, bottom: 8),
              child: Column(
                children: [
                  totalPrice(),
                  discountPrice(setState),
                  CustomButton(
                    buttonText: RUPEE_SYMBOL + " " + price.dispFinalAmt(),
                    onClick: () async {
                      if (selectedProducts.isNotEmpty && price.total > 0) {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (__) => new BillerPage(
                              billing: createBilling(),
                              isAlreadySaved: false,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Add items before moving ahead."),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget totalPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            "Total " + RUPEE_SYMBOL + " " + price.dispTotal(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        )
      ],
    );
  }

  Widget discountPrice(StateSetter setState) {
    return Padding(
      padding: EdgeInsets.only(left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Discount ",
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
          Text(
            "% ",
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.grey[800], fontSize: 15),
          ),
          Container(
            width: 65,
            child: TextFormField(
              cursorWidth: 1.3,
              controller: discountController,
              textAlign: TextAlign.start,
              onTap: () {
                setState(() {
                  finalAmountReset();
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow((RegExp("[.0-9]"))),
              ],
              style: TextStyle(
                fontSize: 15,
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    if (value.isNotEmpty) {
                      double discount = double.parse(value);
                      price.discountAmt = 0;
                      if (discount > 0) {
                        price.discountAmt = price.total * (discount / 100);
                        price.finalAmt = price.total - price.discountAmt;
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
            style: TextStyle(color: Colors.grey[800], fontSize: 15),
          ),
          Container(
            width: 60,
            child: TextFormField(
              cursorWidth: 1.3,
              controller: discountedPriceController,
              textAlign: TextAlign.start,
              onTap: () {
                setState(() {
                  finalAmountReset();
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow((RegExp("[.0-9]"))),
              ],
              style: TextStyle(
                fontSize: 15,
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    if (value.isNotEmpty) {
                      double discountPrice = double.parse(value);
                      price.discountAmt = 0;
                      if (discountPrice > 0) {
                        price.discountAmt = discountPrice;
                        price.finalAmt = price.total - discountPrice;
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
    );
  }

  void calculateTotal() {
    price.total = 0;
    for (var item in selectedProducts) {
      print(item.price);
      price.total += item.price * item.quantity;
      price.finalAmt = price.total;
    }
  }

  void finalAmountReset() {
    price.finalAmt = price.total;
    discountController.clear();
    discountedPriceController.clear();
  }
}
