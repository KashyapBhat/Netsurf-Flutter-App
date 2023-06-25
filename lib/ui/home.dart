import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:project_netsurf/common/analytics.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/models/product.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/edittext.dart';
import 'package:project_netsurf/common/ui/loader.dart';
import 'package:project_netsurf/ui/drawer.dart';
import 'package:project_netsurf/ui/select_products.dart';

class HomePage extends StatefulWidget {
  final String billingIdVal;
  final bool isRetailer;
  final User? retailer;
  final DisplayData displayData;

  HomePage(
      {Key? key,
      required this.isRetailer,
      this.retailer,
      required this.displayData,
      required this.billingIdVal})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static FirebaseAnalytics analytics = GetIt.I.get<FirebaseAnalytics>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController categoryTextController =
      new TextEditingController();
  final TextEditingController itemTextController = new TextEditingController();
  late ScrollController _controller;
  bool silverCollapsed = false;

  List<Product?>? allCategories;
  List<Product?>? allProducts;
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
        widget.retailer!.name.isNotEmpty &&
        widget.retailer!.mobileNo.isNotEmpty) retailer = widget.retailer!;
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
    analytics.setCurrentScreen(
        screenName: isRetailer ? CT_DISTRIBUTER_SCREEN : CT_USER_SCREEN);
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
                                snapshot.data!.name.isNotEmpty &&
                                snapshot.data!.mobileNo.isNotEmpty) {
                              print("RetailerData: " + snapshot.data!.name);
                              if (retailer.name.isEmpty &&
                                  retailer.mobileNo.isEmpty)
                                retailer = snapshot.data!;
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
    textValue = isRetailer ? "Distributor" : "Customer";
    return CustomScrollView(
      controller: _controller,
      slivers: <Widget>[
        scrollAppBar(),
        inputDataAndNext(),
      ],
    );
  }

  Widget scrollAppBar() {
    List<String>? bannerList = widget.displayData.bannerList;
    int length = 1;
    if (bannerList != null && bannerList.isNotEmpty) {
      length = widget.displayData.bannerList!.length;
    } else {
      bannerList = [];
      bannerList.add(widget.displayData.banner);
    }
    return SliverAppBar(
      expandedHeight: 200,
      pinned: false,
      iconTheme: IconThemeData(color: Color(PRIMARY_COLOR)),
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "",
          style: TextStyle(color: Colors.grey[100]),
        ),
        centerTitle: true,
        background: Center(
          child: CarouselSlider(
            options: CarouselOptions(height: 400.0),
            items: Iterable<int>.generate(length).toList().map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: CachedNetworkImage(
                      imageUrl: bannerList![i],
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => CustomLoader(),
                      fit: BoxFit.contain,
                      fadeInCurve: Curves.easeInToLinear,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget inputDataAndNext() {
    return SliverFillRemaining(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            if (isRetailer)
              Flexible(
                child: Text(
                  "Before moving forward, let's update the distributor details!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            Flexible(
              child: EditText(
                  required: true,
                  initTextValue: user.name,
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
                  initTextValue: user.mobileNo,
                  type: TextInputType.phone,
                  isPhone: true,
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
            Flexible(
              child: EditText(
                  required: false,
                  initTextValue: user.cRefId,
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
            // Flexible(
            //   child: EditText(
            //       required: false,
            //       editTextName: "Address",
            //       initTextValue: user.address ?? "",
            //       type: TextInputType.streetAddress,
            //       maxline: 3,
            //       onText: (text) async {
            //         user.address = text;
            //         await Preference.setItem(SP_CUSTOMER_ADDRESS, text);
            //         print(text);
            //       },
            //       onTap: () {
            //         _controller.jumpTo(_controller.position.maxScrollExtent);
            //       }),
            // ),
            if (!isRetailer)
              Flexible(
                child: EditText(
                    required: false,
                    initTextValue: user.email,
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
              onClick: () async {
                if (user.name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Please fill the " + textValue + " name!"),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.fixed,
                    backgroundColor: Colors.red,
                  ));
                  return;
                }
                if (user.mobileNo.length != 10) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Please fill the 10 digit " +
                        textValue +
                        " mobile number!"),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.fixed,
                    backgroundColor: Colors.red,
                  ));
                  return;
                }
                if (isRetailer) {
                  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                  analytics.logEvent(
                    name: CT_DISTRIBUTOR_LOGIN,
                    parameters: <String, dynamic>{
                      CT_DISTRIBUTOR_NAME: retailer.name,
                      CT_DISTRIBUTOR_PH_NO: retailer.mobileNo,
                      CT_MODEL_NAME: androidInfo.model,
                      CT_MANUFACTURER_NAME: androidInfo.manufacturer,
                      CT_ANDROID_VERSION_STRING: androidInfo.version.release,
                      CT_ANDROID_VERSION: androidInfo.version.baseOS
                    },
                  );
                  Preference.setRetailer(user);
                  Phoenix.rebirth(context);
                } else {
                  if (allCategories == null ||
                      allCategories!.isEmpty ||
                      allProducts == null ||
                      allProducts!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Products "),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.fixed,
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (__) => new SelectProductsPage(
                        customerData: user,
                        allCategories: allCategories!,
                        allProducts: allProducts!,
                        retailer: retailer,
                        billingIdVal: widget.billingIdVal,
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
