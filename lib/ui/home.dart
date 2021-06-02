import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/product_constant.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/edittext.dart';
import 'package:project_netsurf/ui/drawer.dart';
import 'package:project_netsurf/ui/select_products.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

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
  String myTitle = "";

  Customer data = Customer("", "", "", "", "");

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    // Preference.getItem(SP_CUSTOMER_NAME).then((value) => {name = value});
    // Preference.getItem(SP_CUSTOMER_M_NO).then((value) => {mobileNo = value});
    // Preference.getItem(SP_CUSTOMER_RF_ID).then((value) => {cRefId = value});
    // Preference.getItem(SP_CUSTOMER_ADDRESS).then((value) => {address = value});
    // Preference.getItem(SP_CUSTOMER_EMAIL).then((value) => {email = value});

    _controller.addListener(() {
      if (_controller.offset > 100 && !_controller.position.outOfRange) {
        if (!silverCollapsed) {
          myTitle = "Net Surf";
          silverCollapsed = true;
          setState(() {});
        }
      }
      if (_controller.offset <= 100 && !_controller.position.outOfRange) {
        if (silverCollapsed) {
          myTitle = "";
          silverCollapsed = false;
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(),
        key: _scaffoldKey,
        body: FutureBuilder(
          future: Products.getAllProducts(FirebaseFirestore.instance),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CustomScrollView(
                controller: _controller,
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        myTitle,
                        style: TextStyle(color: Colors.grey[100]),
                      ),
                      centerTitle: true,
                      background: Image.asset(
                        'assets/netsurf.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(height: 0),
                          EditText(
                              required: true,
                              initTextValue: data.name ?? "",
                              type: TextInputType.name,
                              editTextName: "Customer Name",
                              onText: (text) async {
                                data.name = text;
                                Preference.setItem(SP_CUSTOMER_NAME, text);
                                print(text);
                              },
                              onTap: () {
                                _controller.jumpTo(
                                    _controller.position.maxScrollExtent);
                              }),
                          EditText(
                              required: true,
                              initTextValue: data.mobileNo ?? "",
                              type: TextInputType.phone,
                              editTextName: "Customer Mobile Number",
                              onText: (text) async {
                                data.mobileNo = text;
                                Preference.setItem(SP_CUSTOMER_M_NO, text);
                                print(text);
                              },
                              onTap: () {
                                _controller.jumpTo(
                                    _controller.position.maxScrollExtent);
                              }),
                          EditText(
                              required: false,
                              initTextValue: data.cRefId ?? "",
                              editTextName: "Customer Reference ID",
                              onText: (text) async {
                                data.cRefId = text;
                                await Preference.setItem(
                                    SP_CUSTOMER_RF_ID, text);
                                print(text);
                              },
                              onTap: () {
                                _controller.jumpTo(
                                    _controller.position.maxScrollExtent);
                              }),
                          EditText(
                              required: false,
                              editTextName: "Address",
                              initTextValue: data.address ?? "",
                              type: TextInputType.streetAddress,
                              maxline: 3,
                              onText: (text) async {
                                data.address = text;
                                await Preference.setItem(
                                    SP_CUSTOMER_ADDRESS, text);
                                print(text);
                              },
                              onTap: () {
                                _controller.jumpTo(
                                    _controller.position.maxScrollExtent);
                              }),
                          EditText(
                              required: false,
                              initTextValue: data.email ?? "",
                              editTextName: "Email",
                              type: TextInputType.emailAddress,
                              onText: (text) async {
                                data.email = text;
                                await Preference.setItem(
                                    SP_CUSTOMER_EMAIL, text);
                                print(text);
                              },
                              onTap: () {
                                _controller.jumpTo(
                                    _controller.position.maxScrollExtent);
                              }),
                          CustomButton(
                              buttonText: "Next",
                              onClick: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (__) => new SelectProductsPage(
                                            customerData: data)));
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.connectionState == ConnectionState.none) {
              return Text("No product data found");
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
