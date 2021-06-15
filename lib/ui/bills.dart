import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  BillsPage({Key key, this.retailer, this.displayData}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<BillsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Billing> bills;
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  bool _isSearching;
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
    return Listener(
      onPointerDown: (_) {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          centerTitle: true,
          actions: <Widget>[
            new IconButton(
              icon: actionIcon,
              onPressed: () {
                setState(() {
                  if (this.actionIcon.icon == Icons.search) {
                    this.actionIcon = new Icon(
                      Icons.close,
                      color: Colors.white,
                    );
                    this.appBarTitle = new TextField(
                      controller: _searchQuery,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          hintText: "Enter name/phno/billno...",
                          hintStyle: new TextStyle(color: Colors.white)),
                    );
                    _handleSearchStart();
                  } else {
                    _handleSearchEnd();
                  }
                });
              },
            ),
          ],
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
                return inputDataAndNext(
                    _isSearching ? _buildSearchList(bills) : bills);
              } else {
                return Center(child: Text("No bills found!"));
              }
            } else if (snapshot.connectionState == ConnectionState.none) {
              return Text("No product data found");
            }
            return CustomLoader();
          },
        ),
      ),
    );
  }

  List<Billing> _buildSearchList(List<Billing> bills) {
    if (_searchText.isEmpty) {
      return bills;
    } else {
      return bills
          .where((bill) =>
              bill.billingInfo.number.contains(_searchText) ||
              bill.customer.mobileNo.contains(_searchText) ||
              bill.customer.name
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
          .toList();
    }
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
                          print("" + element.price.dispFinalAmt());
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
                        color: Color(0xFF333366),
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
                                        bills[index].customer.name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15),
                                      ),
                                      Text(
                                        bills[index].customer.mobileNo,
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
                                      Text(
                                        "Bill No: " +
                                            bills[index].billingInfo.number,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (bills[index]
                                          .customer
                                          .cRefId
                                          .isNotEmpty)
                                        Text(
                                          "CRef: " +
                                              bills[index].customer.cRefId,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Center(
                                    child: Text(
                                      RUPEE_SYMBOL +
                                          " " +
                                          bills[index].price.dispFinalAmt(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
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
