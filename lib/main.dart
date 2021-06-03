import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_netsurf/common/product_constant.dart';
import 'package:project_netsurf/ui/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

const String TITLE = "NET SURF";
const String PATH_HOME = "/";
const String PATH_PRODUCT = "/selectproducts";
const String PATH_BILLER = "/billerpage";

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Net Surf',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) => SafeArea(child: child),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return FutureBuilder(
              future: Products.getAllProducts(FirebaseFirestore.instance),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return HomePage();
                } else if (snapshot.hasError) {
                  return Text(
                    "Sorry, Something went wrong.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          } else if (snapshot.hasError) {
            return Text(
              "Sorry, Something went wrong.",
              style: TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
