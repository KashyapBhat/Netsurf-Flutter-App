import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:project_netsurf/common/analytics.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/product_constant.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/loader.dart';
import 'package:project_netsurf/ui/home.dart';
import 'common/ui/theme.dart';
import 'di/singletons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = GetIt.I.get<FirebaseAnalytics>();
  static FirebaseFirestore fireStore = GetIt.I.get<FirebaseFirestore>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    analytics.logAppOpen();
    analytics.setCurrentScreen(screenName: CT_HOME_SCREEN);
    return MaterialApp(
      title: APP_NAME,
      theme: NetsurfAppTheme(),
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      builder: (context, child) => AppContainer(context, child),
      home: FutureBuilder(
        future: Products.getDisplayData(fireStore, false),
        builder: (context, AsyncSnapshot<DisplayData?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              DisplayData displayData = snapshot.data!;
              return FutureBuilder(
                future:
                    Products.getAllProducts(fireStore, false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return FutureBuilder(
                      future: Preference.getItem(SP_BILLING_ID),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          String? billingId = snapshot.data;
                          if (billingId == null || billingId.isEmpty) {
                            billingId = "1001";
                          } else {
                            int lastBillID = int.parse(billingId);
                            lastBillID++;
                            billingId = lastBillID.toString();
                          }
                          print("Billing:" + billingId);
                          return FutureBuilder(
                            future: Preference.getRetailer(),
                            builder: (context, AsyncSnapshot<User> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.data != null &&
                                    snapshot.data!.name.isNotEmpty &&
                                    snapshot.data!.mobileNo.isNotEmpty) {
                                  print("RetailerData: " + snapshot.data!.name);
                                  return HomePage(
                                      isRetailer: false,
                                      retailer: snapshot.data!,
                                      displayData: displayData,
                                      billingIdVal: billingId!);
                                } else {
                                  return HomePage(
                                      isRetailer: true,
                                      retailer: null,
                                      displayData: displayData,
                                      billingIdVal: billingId!);
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
            } else {
              return showErrorMessage(context);
            }
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
