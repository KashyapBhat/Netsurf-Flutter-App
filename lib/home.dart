import 'package:flutter/material.dart';
import 'package:project_netsurf/bottomsheet.dart';
import 'package:project_netsurf/edittext.dart';
import 'package:project_netsurf/main.dart';
import 'package:project_netsurf/product.dart';
import 'package:project_netsurf/product_constant.dart';

class MyHomePageState extends State<MyHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController categoryTextController =
      new TextEditingController();
  final TextEditingController itemTextController = new TextEditingController();

  double total = 0;
  List<Product> selectedProducts = [];
  Product selectedCategory = Products.getProductCategory(null);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            EditText(editTextName: "Customer Name"),
            EditText(
                editTextName: "Customer Mobile Number",
                type: TextInputType.phone),
            EditText(editTextName: "Customer Reference ID"),
            CustomButton(
                buttonText: "Select Category",
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(product.name),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ));
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
                      if (!selectedProducts.contains(product))
                        selectedProducts.add(product);
                      else {
                        for (var item in selectedProducts) {
                          if (item == product) {
                            setState(() {
                              item.quantity++;
                            });
                          }
                        }
                      }
                      calculateTotal();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(product.name),
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ));
                    });
                  }
                });
              },
            ),
            SizedBox(width: 30),
            if (selectedProducts != null && selectedProducts.isNotEmpty)
              Expanded(
                child: ListView.separated(
                    itemCount: selectedProducts.length,
                    separatorBuilder: (context, int) {
                      return Divider(
                        height: 3,
                      );
                    },
                    itemBuilder: (context, index) {
                      return Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Container(
                            child: Text(
                                selectedProducts[index].getDisplayName(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    height: 1.3),
                                textAlign: TextAlign.start),
                            padding: EdgeInsets.only(
                                left: 16, top: 8, right: 0, bottom: 8),
                          )),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0)),
                              minimumSize: Size(15, 40),
                            ),
                            child: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                selectedProducts[index].quantity++;
                                calculateTotal();
                              });
                            },
                          ),
                          SizedBox(width: 3),
                          Container(
                              width: 40,
                              child: TextFormField(
                                key: Key(selectedProducts[index]
                                    .quantity
                                    .toString()),
                                initialValue:
                                    selectedProducts[index].quantity.toString(),
                                textAlign: TextAlign.center,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 0, bottom: 0, top: 0, right: 0),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null && value.isNotEmpty) {
                                      int quant = double.parse(value).ceil();
                                      if (quant > 1)
                                        selectedProducts[index].quantity =
                                            quant;
                                      selectedCategory.quantity = quant;
                                    } else {
                                      selectedProducts[index].quantity = 1;
                                      selectedCategory.quantity = 1;
                                    }
                                    calculateTotal();
                                  });
                                },
                              )),
                          SizedBox(width: 3),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0)),
                              minimumSize: Size(15, 40),
                            ),
                            child: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (selectedProducts[index].quantity > 1)
                                  selectedProducts[index].quantity--;
                                calculateTotal();
                              });
                            },
                          ),
                          SizedBox(width: 3),
                        ],
                      ));
                    }),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 8, right: 20, bottom: 8),
                child: Container(
                  height: 23,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text("Total: " + total.toString(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                      Row(
                        children: [
                          Text("Discount: ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Container(
                              width: 50,
                              child: TextFormField(
                                initialValue: "0",
                                textAlign: TextAlign.right,
                                enableInteractiveSelection: false,
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      left: 2, bottom: 14, top: 0, right: 2),
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              )),
                          Text("%",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 16)),
                        ],
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
                    content: Text(total.toString()),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                  ));
                }),
            SizedBox(width: 3),
          ],
        ),
      ),
    );
  }

  String _getButtonText() {
    if (selectedCategory != null &&
        selectedCategory.name != null &&
        selectedCategory.name.isNotEmpty) {
      return "Select Item from: ${selectedCategory.name}";
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
}
