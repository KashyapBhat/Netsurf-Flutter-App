import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:project_netsurf/common/analytics.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/loader.dart';
import 'package:project_netsurf/ui/biller.dart';

class BillsPage extends StatefulWidget {
  final DisplayData displayData;
  final User retailer;

  BillsPage({Key? key, required this.retailer, required this.displayData})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<BillsPage> {
  static FirebaseAnalytics analytics = GetIt.I.get<FirebaseAnalytics>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  late bool _isSearching;
  String _searchText = "";
  final TextEditingController _searchQuery = new TextEditingController();
  Widget appBarTitle = new Text(
    SAVED,
    style: new TextStyle(color: Colors.white),
  );

  @override
  void initState() {
    super.initState();
    _isSearching = false;
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    analytics.setCurrentScreen(screenName: CT_SAVED_BILLS);
    return Listener(
      onPointerDown: (_) {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: appBarTitle,
            centerTitle: true,
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: actionIcon,
                  onPressed: () {
                    setState(() {
                      if (this.actionIcon.icon == Icons.search) {
                        this.actionIcon = Icon(
                          Icons.close,
                          color: Colors.white,
                        );
                        this.appBarTitle = Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            controller: _searchQuery,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.white,
                              ),
                              prefixIconConstraints: BoxConstraints(
                                minWidth: 30,
                                minHeight: 30,
                              ),
                              hintText: "Search saved bills",
                              hintStyle: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                        _handleSearchStart();
                      } else {
                        _handleSearchEnd();
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                  future: Preference.getBills(),
                  builder: (context, AsyncSnapshot<List<Billing>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                        snapshot.data!.forEach((element) {
                          if (element.price != null)
                            print("BILLS: " + element.price!.dispFinalAmt());
                        });
                        return inputDataAndNext(_isSearching
                            ? _buildSearchList(snapshot.data!)
                            : snapshot.data!);
                      } else {
                        return Container(
                            margin: EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 0),
                            child: Center(
                                child: Text(
                              "No bills found",
                              style: TextStyle(fontSize: 16),
                            )));
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.none) {
                      return Text("No product data found");
                    }
                    return CustomLoader();
                  },
                ),
                SizedBox(height: 5),
                Container(
                  margin:
                      EdgeInsets.only(left: 18, right: 18, bottom: 18, top: 5),
                  child: Text(
                      "You can search the saved bills by name, phone number or bill number!",
                      style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          )),
    );
  }

  List<Billing> _buildSearchList(List<Billing> bills) {
    print("_searchText");
    if (_searchText.isEmpty) {
      print("isEmpty");
      return bills;
    } else {
      return bills.where((bill) => checkBill(bill)).toList();
    }
  }

  bool checkBill(Billing bill) {
    bool hasSearch = false;
    if (bill.billingInfo != null) {
      hasSearch = hasSearch || bill.billingInfo!.number.contains(_searchText);
    }
    if (bill.customer != null) {
      hasSearch = hasSearch ||
          (bill.customer!.mobileNo.contains(_searchText) ||
              bill.customer!.name
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()));
    }
    return hasSearch;
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = Text(
        SAVED,
        style: TextStyle(color: Colors.white),
      );
      _isSearching = false;
      _searchQuery.clear();
    });
  }

  Widget inputDataAndNext(List<Billing> bills) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: bills.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                if (!_isSearching)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        print(bills.length);
                        bills.remove(bills[index]);
                        print(bills.length);
                        bills.forEach((element) {
                          if (element.price != null)
                            print("" + element.price!.dispFinalAmt());
                        });
                        Preference.addBills(bills);
                      });
                    },
                    icon: Icon(
                      Icons.delete_forever_rounded,
                      size: 30,
                    ),
                    color: Colors.black87,
                  ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (__) => BillerPage(billing: bills[index])),
                      );
                    },
                    child: Container(
                      constraints: BoxConstraints(minHeight: 125),
                      decoration: BoxDecoration(
                        color: Color(SECONDARY_COLOR),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10.0,
                            offset: Offset(0.0, 10.0),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 24, top: 8, bottom: 8, right: 8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        bills[index].customer?.name ?? "NA",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15),
                                      ),
                                      Text(
                                        bills[index].customer?.mobileNo ?? "NA",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (bills[index].billingInfo != null)
                                        Text(
                                          "Bill No: " +
                                              bills[index].billingInfo!.number,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (bills[index].customer != null &&
                                          bills[index]
                                              .customer!
                                              .cRefId
                                              .isNotEmpty)
                                        Text(
                                          "CRef: " +
                                              bills[index].customer!.cRefId,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  if (bills[index].price != null)
                                    Center(
                                      child: Text(
                                        RUPEE_SYMBOL +
                                            " " +
                                            bills[index].price!.dispFinalAmt(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              print("Delete click");
                            },
                            icon: Icon(
                              Icons.navigate_next,
                              size: 35,
                            ),
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
