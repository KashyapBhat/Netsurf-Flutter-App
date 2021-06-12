import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/product_constant.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/loader.dart';
import 'package:project_netsurf/ui/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Phoenix(child: MyApp()));
}

const String PATH_HOME = "/";
const String PATH_PRODUCT = "/selectproducts";
const String PATH_BILLER = "/billerpage";

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: APP_NAME,
      theme: ThemeData(
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0),
        ),
        primaryColor: Color(PRIMARY_COLOR),
        accentColor: Color(SECONDARY_COLOR),
        primarySwatch: MaterialColor(SECONDARY_COLOR, THEME_COLOR),
      ),
      builder: (context, child) => SafeArea(
          child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: child,
      )),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return FutureBuilder(
              future: Products.getDisplayData(FirebaseFirestore.instance),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<DisplayData>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    DisplayData displayData = snapshot.data.data();
                    return FutureBuilder(
                      future: _initialization,
                      builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return FutureBuilder(
                            future: Products.getAllProducts(
                                FirebaseFirestore.instance),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return FutureBuilder(
                                  future: Preference.getItem(SP_BILLING_ID),
                                  builder: (context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      String billingId = snapshot.data;
                                      if (billingId == null ||
                                          billingId.isEmpty) {
                                        billingId = "1001";
                                      } else {
                                        int lastBillID = int.parse(billingId);
                                        lastBillID++;
                                        billingId = lastBillID.toString();
                                      }
                                      print("Billing:" + billingId);
                                      return FutureBuilder(
                                        future: Preference.getRetailer(),
                                        builder: (context,
                                            AsyncSnapshot<User> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            if (snapshot.data != null &&
                                                snapshot.data.name.isNotEmpty &&
                                                snapshot
                                                    .data.mobileNo.isNotEmpty) {
                                              print("RetailerData: " +
                                                  snapshot.data.name);
                                              return HomePage(
                                                  isRetailer: false,
                                                  retailer: snapshot.data,
                                                  displayData: displayData,
                                                  billingIdVal: billingId);
                                            } else {
                                              return HomePage(
                                                  isRetailer: true,
                                                  retailer: null,
                                                  displayData: displayData,
                                                  billingIdVal: billingId);
                                            }
                                          } else if (snapshot.hasError) {
                                            return showErrorMessage(context);
                                          } else {
                                            return CustomLoader();
                                          }
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return showErrorMessage(context);
                                    } else {
                                      return CustomLoader();
                                    }
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return showErrorMessage(context);
                              } else {
                                return CustomLoader();
                              }
                            },
                          );
                        } else if (snapshot.hasError) {
                          return showErrorMessage(context);
                        } else {
                          return CustomLoader();
                        }
                      },
                    );
                  } else {
                    return showErrorMessage(context);
                  }
                } else if (snapshot.hasError) {
                  return showErrorMessage(context);
                } else {
                  return CustomLoader();
                }
              },
            );
          } else if (snapshot.hasError) {
            return showErrorMessage(context);
          } else {
            return CustomLoader();
          }
        },
      ),
    );
  }

  Widget showErrorMessage(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Something went wrong. Please check your internet!",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
              icon: Icon(Icons.refresh_rounded),
              onPressed: () {
                Phoenix.rebirth(context);
              }),
        ],
      ),
    );
  }
}
