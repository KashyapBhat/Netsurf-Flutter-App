import 'package:flutter/material.dart';
import '../contants.dart';

ThemeData NetsurfAppTheme() {
  return ThemeData(
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      bodyMedium: TextStyle(fontSize: 14.0),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      toolbarTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      color: const Color(PRIMARY_COLOR),
    ),
    primaryColor: Color(PRIMARY_COLOR),
    hintColor: Color(SECONDARY_COLOR),
    primarySwatch: MaterialColor(SECONDARY_COLOR, THEME_COLOR),
  );
}

Widget AppContainer(context, child) {
  return SafeArea(
    child: Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: Colors.white),
      child: child,
    ),
  );
}
