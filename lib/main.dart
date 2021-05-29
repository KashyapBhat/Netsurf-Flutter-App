import 'package:flutter/material.dart';
import 'package:project_netsurf/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NETSURF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) => SafeArea(child: child),
      home: MyHomePage(title: 'NETSURF'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}
