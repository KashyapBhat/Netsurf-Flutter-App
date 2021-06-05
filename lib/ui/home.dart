import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/models/product.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/edittext.dart';
import 'package:project_netsurf/common/ui/loader.dart';
import 'package:project_netsurf/ui/drawer.dart';
import 'package:project_netsurf/ui/select_products.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  final bool isRetailer;
  final User retailer;
  final DisplayData displayData;

  HomePage({Key key, this.isRetailer, this.retailer, this.displayData})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController categoryTextController =
      new TextEditingController();
  final TextEditingController itemTextController = new TextEditingController();
  ScrollController _controller;
  bool silverCollapsed = false;

  List<Product> allCategories;
  List<Product> allProducts;
  bool isRetailer = false;
  String textValue = "";
  User user = User("", "", "", "", "");
  User retailer = User("", "", "", "", "");

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    isRetailer = widget.isRetailer;
    if (widget.retailer != null &&
        widget.retailer.name.isNotEmpty &&
        widget.retailer.mobileNo.isNotEmpty) retailer = widget.retailer;
    _controller.addListener(() {
      if (_controller.offset > 100 && !_controller.position.outOfRange) {
        if (!silverCollapsed) {
          silverCollapsed = true;
        }
      }
      if (_controller.offset <= 100 && !_controller.position.outOfRange) {
        if (silverCollapsed) {
          silverCollapsed = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
          drawer:
              AppDrawer(retailer: retailer, displayData: widget.displayData),
          key: _scaffoldKey,
          body: FutureBuilder(
            future: Preference.getProducts(SP_CATEGORY_IDS),
            builder: (context, AsyncSnapshot<List<Product>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                allCategories = snapshot.data;
                return FutureBuilder(
                  future: Preference.getProducts(SP_PRODUCTS),
                  builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      allProducts = snapshot.data;
                      return FutureBuilder(
                        future: Preference.getRetailer(),
                        builder: (context, AsyncSnapshot<User> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data != null &&
                                snapshot.data.name.isNotEmpty &&
                                snapshot.data.mobileNo.isNotEmpty) {
                              print("RetailerData: " + snapshot.data.name);
                              if (retailer.name.isEmpty &&
                                  retailer.mobileNo.isEmpty)
                                retailer = snapshot.data;
                              isRetailer = false;
                              return scrollView();
                            } else {
                              isRetailer = true;
                              return scrollView();
                            }
                          } else if (snapshot.hasError) {
                            return Text(
                              "Sorry, Something went wrong.",
                              style: TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return CustomLoader();
                          }
                        },
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.none) {
                      return Text("No product data found");
                    }
                    return CustomLoader();
                  },
                );
              } else if (snapshot.connectionState == ConnectionState.none) {
                return Text("No product data found");
              }
              return CustomLoader();
            },
          )),
    );
  }

  Widget scrollView() {
    textValue = isRetailer ? "Retailer" : "Customer";
    return CustomScrollView(
      controller: _controller,
      slivers: <Widget>[
        scrollAppBar(),
        inputDataAndNext(),
      ],
    );
  }

  Widget scrollAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: false,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "",
          style: TextStyle(color: Colors.grey[100]),
        ),
        centerTitle: true,
        background: CachedNetworkImage(
          imageUrl: widget.displayData.banner,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CustomLoader(),
          fit: BoxFit.cover,
          fadeInCurve: Curves.easeInToLinear,
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }

  Widget inputDataAndNext() {
    return SliverFillRemaining(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              child: EditText(
                  required: true,
                  initTextValue: user.name ?? "",
                  type: TextInputType.name,
                  editTextName: textValue + " Name",
                  onText: (text) async {
                    user.name = text;
                    Preference.setItem(SP_CUSTOMER_NAME, text);
                    print(text);
                  },
                  onTap: () {
                    _controller.jumpTo(_controller.position.maxScrollExtent);
                  }),
            ),
            Flexible(
              child: EditText(
                  required: true,
                  initTextValue: user.mobileNo ?? "",
                  type: TextInputType.phone,
                  editTextName: textValue + " Mobile Number",
                  onText: (text) async {
                    user.mobileNo = text;
                    Preference.setItem(SP_CUSTOMER_M_NO, text);
                    print(text);
                  },
                  onTap: () {
                    _controller.jumpTo(_controller.position.maxScrollExtent);
                  }),
            ),
            if (!isRetailer)
              Flexible(
                child: EditText(
                    required: false,
                    initTextValue: user.cRefId ?? "",
                    editTextName: textValue + " Reference ID",
                    onText: (text) async {
                      user.cRefId = text;
                      await Preference.setItem(SP_CUSTOMER_RF_ID, text);
                      print(text);
                    },
                    onTap: () {
                      _controller.jumpTo(_controller.position.maxScrollExtent);
                    }),
              ),
            Flexible(
              child: EditText(
                  required: false,
                  editTextName: "Address",
                  initTextValue: user.address ?? "",
                  type: TextInputType.streetAddress,
                  maxline: 3,
                  onText: (text) async {
                    user.address = text;
                    await Preference.setItem(SP_CUSTOMER_ADDRESS, text);
                    print(text);
                  },
                  onTap: () {
                    _controller.jumpTo(_controller.position.maxScrollExtent);
                  }),
            ),
            if (!isRetailer)
              Flexible(
                child: EditText(
                    required: false,
                    initTextValue: user.email ?? "",
                    editTextName: "Email",
                    type: TextInputType.emailAddress,
                    onText: (text) async {
                      user.email = text;
                      await Preference.setItem(SP_CUSTOMER_EMAIL, text);
                      print(text);
                    },
                    onTap: () {
                      _controller.jumpTo(_controller.position.maxScrollExtent);
                    }),
              ),
            CustomButton(
              buttonText: isRetailer ? "Save" : "Next",
              onClick: () {
                if (user.name.isEmpty && user.mobileNo.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Please fill all the required fields!"),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.fixed,
                    backgroundColor: Colors.red,
                  ));
                  return;
                }
                if (isRetailer) {
                  Preference.setRetailer(user);
                  setState(() {});
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (__) => new SelectProductsPage(
                        customerData: user,
                        allCategories: allCategories,
                        allProducts: allProducts,
                        retailer: retailer,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
