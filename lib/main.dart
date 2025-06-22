import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:project_netsurf/common/analytics.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/product_constant.dart';
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
  DisplayData? displayData = GetIt.I.get<DisplayData>();

  @override
  Widget build(BuildContext context) {
    onAppStart();
    return MaterialApp(
      title: APP_NAME,
      theme: NetsurfAppTheme(),
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      builder: (context, child) => AppContainer(context, child),
      home: FutureBuilder(
        future: Products.getAllProducts(fireStore, false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return navigateToHome(context);
          } else if (snapshot.hasError) {
            return showErrorMessage(context);
          } else {
            return CustomLoader();
          }
        },
      ),
    );
  }

  void onAppStart() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    analytics.logAppOpen();
    analytics.setCurrentScreen(screenName: CT_HOME_SCREEN);
  }

  Widget navigateToHome(BuildContext context) {
    User? retailUser = GetIt.I.get<User>();
    String? billingId = GetIt.I.get<String>(instanceName: BILLING_ID);
    if (displayData == null) {
      return showErrorMessage(context);
    }
    var userLogin =
        retailUser.name.isNotEmpty && retailUser.mobileNo.isNotEmpty;
    print("RetailerData: " + retailUser.name);
    return HomePage(
        isRetailer: !userLogin,
        retailer: userLogin ? retailUser : null,
        displayData: displayData!,
        billingIdVal: billingId);
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
