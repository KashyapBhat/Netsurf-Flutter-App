import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_netsurf/common/utils/pdf_api.dart';

class BillerPage extends StatefulWidget {
  final File file;

  BillerPage({Key key, this.file}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<BillerPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    PdfApi.openFile(widget.file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey, body: Center());
  }

  @override
  void dispose() {
    super.dispose();
  }
}
