import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/loader.dart';
import 'package:project_netsurf/ui/drawer.dart';

class BillsPage extends StatefulWidget {
  final DisplayData displayData;
  final User retailer;

  BillsPage({Key key, this.retailer, this.displayData}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<BillsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Billing> bills;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Net Surf", textAlign: TextAlign.center),
            centerTitle: true,
          ),
          key: _scaffoldKey,
          body: FutureBuilder(
            future: Preference.getBills(),
            builder: (context, AsyncSnapshot<List<Billing>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                bills = snapshot.data;
                if (bills != null && bills.isNotEmpty) {
                  bills.forEach((element) {
                    print("BILLS: " + element.price.dispFinalAmt());
                  });
                  return inputDataAndNext();
                } else {
                  return Center(child: Text("No bills found!"));
                }
              } else if (snapshot.connectionState == ConnectionState.none) {
                return Text("No product data found");
              }
              return CustomLoader();
            },
          )),
    );
  }

  Widget inputDataAndNext() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
