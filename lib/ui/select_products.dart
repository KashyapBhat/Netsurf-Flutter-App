import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/ui/bottomsheet.dart';
import 'package:project_netsurf/common/ui/edittext.dart';
import 'package:project_netsurf/common/models/product.dart';
import 'package:project_netsurf/common/product_constant.dart';

class SelectProductsPage extends StatefulWidget {
  final String title;
  final CustomerData customerData;

  SelectProductsPage({Key key, this.title, this.customerData})
      : super(key: key);

  @override
  SelectProductsPageState createState() => SelectProductsPageState();
}

class SelectProductsPageState extends State<SelectProductsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController categoryTextController =
      new TextEditingController();
  final TextEditingController itemTextController = new TextEditingController();
  List<TextEditingController> _controllers = [];

  bool silverCollapsed = false;
  String myTitle = "";
  double priceAfterDiscount = 0;

  double total = 0;
  List<Product> selectedProducts = [];
  Product selectedCategory = Products.getProductCategory(null);

  @override
  void initState() {
    super.initState();
    print("Selected customer: " + widget.customerData.name ?? "");
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
          SizedBox(height: 13),
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
          SizedBox(height: 5),
          Expanded(
            child: Card(
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: ListView.separated(
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
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text("Total: " + total.toString(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        Row(
                          children: [
                            Text("Discount: ",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            Container(
                                width: 43,
                                child: TextFormField(
                                  initialValue: "",
                                  inputFormatters: [
                                    new LengthLimitingTextInputFormatter(4),
                                    FilteringTextInputFormatter.allow(
                                        (RegExp("[.0-9]"))),
                                  ],
                                  textAlign: TextAlign.right,
                                  enableInteractiveSelection: false,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value != null && value.isNotEmpty) {
                                        double discount = double.parse(value);
                                        double discountedPrice = 0;
                                        if (discount > 0) {
                                          discountedPrice =
                                              total * (discount / 100);
                                          priceAfterDiscount =
                                              total - discountedPrice;
                                          if (priceAfterDiscount < 0) {
                                            priceAfterDiscount = 0;
                                          }
                                          print(priceAfterDiscount);
                                        }
                                      }
                                    });
                                  },
                                )),
                            Text("%",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 16)),
                          ],
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                              "Final Amount: " + priceAfterDiscount.toString(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CustomButton(
                  buttonText: "Done",
                  onClick: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(priceAfterDiscount.toString()),
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ));
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
    total = 0;
    for (var item in selectedProducts) {
      print(item.price);
      total += item.price * item.quantity;
    }
  }

  String itemPrice(int index) {
    return RUPEE_SYMBOL +
        " " +
        (selectedProducts[index].price * selectedProducts[index].quantity)
            .ceil()
            .toString();
  }
}
