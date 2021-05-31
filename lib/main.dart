import 'package:flutter/material.dart';
import 'package:project_netsurf/ui/biller.dart';
import 'package:project_netsurf/ui/home.dart';
import 'package:project_netsurf/ui/select_products.dart';

void main() {
  runApp(MyApp());
}

const String TITLE = "NET SURF";
const String PATH_HOME = "/";
const String PATH_PRODUCT = "/selectproducts";
const String PATH_BILLER = "/billerpage";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Net Surf',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) => SafeArea(child: child),
      initialRoute: PATH_HOME,
      routes: {
        PATH_HOME: (context) => HomePage(),
        PATH_PRODUCT: (context) => SelectProductsPage(),
        PATH_BILLER: (context) => BillerPage(),
      },
    );
  }
}
