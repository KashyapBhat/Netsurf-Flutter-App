import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:project_netsurf/common/analytics.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/product_constant.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/error.dart';
import 'package:project_netsurf/common/ui/loader.dart';
import 'package:project_netsurf/ui/bills.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  static FirebaseAnalytics analytics = GetIt.I.get<FirebaseAnalytics>();
  final User retailer;
  final DisplayData displayData;

  const AppDrawer({Key? key, required this.retailer, required this.displayData})
      : super(key: key);

  @override
  Widget build(BuildContext buildContext) {
    analytics.setCurrentScreen(screenName: CT_DRAWER);
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                CachedNetworkImage(
                  height: 170,
                  imageUrl: displayData.drawer,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CustomLoader(),
                  fit: BoxFit.fill,
                  fadeInCurve: Curves.easeInToLinear,
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error_outlined),
                ),
                if (retailer.name.isNotEmpty) SizedBox(height: 8),
                if (retailer.name.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 6, bottom: 6),
                    child: Padding(
                      padding: EdgeInsets.only(left: 14, right: 16),
                      child: Row(
                        children: [
                          Icon(Icons.account_circle_rounded,
                              size: 32, color: Color(PRIMARY_COLOR)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  retailer.name,
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(height: 2),
                              Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  retailer.mobileNo,
                                  style: TextStyle(fontSize: 13.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (retailer.name.isNotEmpty) Divider(),
                _createDrawerIconItem(
                  icon: Icon(
                    Icons.collections_bookmark_rounded,
                    size: 28,
                    color: Color(PRIMARY_COLOR),
                  ),
                  text: SAVED,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (__) => BillsPage(
                              retailer: retailer, displayData: displayData)),
                    );
                  },
                ),
                Divider(),
                _createDrawerItem(
                  icon: Icons.refresh_rounded,
                  text: 'Refresh app',
                  onTap: () async {
                    Navigator.of(context).pop();
                    if (await Preference.contains(SP_DT_REFRESH)) {
                      DateTime oldDateTime =
                          await Preference.getDateTime(SP_DT_REFRESH);
                      DateTime timeNow = DateTime.now();
                      Duration timeDifference = timeNow.difference(oldDateTime);
                      print("TimeDif: " + timeDifference.inDays.toString());
                      if (timeDifference.inDays > 1) {
                        refresh(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Already updated! No need to refresh."),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.fixed,
                          ),
                        );
                      }
                    } else {
                      refresh(context);
                    }
                  },
                ),
                _createDrawerItem(
                  icon: Icons.account_box_rounded,
                  text: 'Distributor logout',
                  onTap: () async {
                    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                    AndroidDeviceInfo androidInfo =
                        await deviceInfo.androidInfo;
                    analytics.logEvent(
                      name: CT_LOGOUT,
                      parameters: <String, Object>{
                        CT_DISTRIBUTOR_NAME: retailer.name,
                        CT_DISTRIBUTOR_PH_NO: retailer.mobileNo,
                        CT_MODEL_NAME: androidInfo.model,
                        CT_MANUFACTURER_NAME: androidInfo.manufacturer,
                        CT_ANDROID_VERSION_STRING: androidInfo.version.release,
                        CT_ANDROID_VERSION: androidInfo.version.baseOS ?? ""
                      },
                    );
                    showLogoutErrorDialog(context);
                  },
                ),
                Divider(),
                _createDrawerItem(
                  icon: Icons.face_retouching_natural,
                  text: displayData.aname,
                  onTap: () async {
                    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                    AndroidDeviceInfo androidInfo =
                        await deviceInfo.androidInfo;
                    analytics.logEvent(
                      name: CT_AUTHOR,
                      parameters: <String, Object>{
                        CT_DISTRIBUTOR_NAME: retailer.name,
                        CT_DISTRIBUTOR_PH_NO: retailer.mobileNo,
                        CT_MODEL_NAME: androidInfo.model,
                        CT_MANUFACTURER_NAME: androidInfo.manufacturer,
                        CT_ANDROID_VERSION_STRING: androidInfo.version.release,
                        CT_ANDROID_VERSION: androidInfo.version.baseOS ?? ""
                      },
                    );
                    _launchURL(displayData.alink);
                  },
                ),
                if (snapshot.data != null)
                  _createDrawerItem(
                    icon: Icons.bug_report,
                    text: 'Report issue',
                    onTap: () async {
                      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                      AndroidDeviceInfo androidInfo =
                          await deviceInfo.androidInfo;
                      analytics.logEvent(
                        name: CT_REPORT_ISSUE,
                        parameters: <String, Object>{
                          CT_DISTRIBUTOR_NAME: retailer.name,
                          CT_DISTRIBUTOR_PH_NO: retailer.mobileNo,
                          CT_MODEL_NAME: androidInfo.model,
                          CT_MANUFACTURER_NAME: androidInfo.manufacturer,
                          CT_ANDROID_VERSION_STRING:
                              androidInfo.version.release,
                          CT_ANDROID_VERSION: androidInfo.version.baseOS ?? ""
                        },
                      );
                      final Uri params = Uri(
                        scheme: 'mailto',
                        path: displayData.aemail,
                        query: 'subject=App Feedback&body=App Version: ' +
                            snapshot.data!.version, //add subject and body here
                      );
                      _launchURL(params.toString());
                    },
                  ),
                _createDrawerItem(
                  icon: Icons.mobile_screen_share_rounded,
                  text: "Share with friends",
                  onTap: () async {
                    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                    AndroidDeviceInfo androidInfo =
                        await deviceInfo.androidInfo;
                    analytics.logEvent(
                      name: CT_SHARE_APP,
                      parameters: <String, Object>{
                        CT_DISTRIBUTOR_NAME: retailer.name,
                        CT_DISTRIBUTOR_PH_NO: retailer.mobileNo,
                        CT_MODEL_NAME: androidInfo.model,
                        CT_MANUFACTURER_NAME: androidInfo.manufacturer,
                        CT_ANDROID_VERSION_STRING: androidInfo.version.release,
                        CT_ANDROID_VERSION: androidInfo.version.baseOS ?? ""
                      },
                    );
                    print("Play Link: " + displayData.playlink);
                    Share.share(displayData.playlink);
                  },
                ),
                Divider(),
                if (snapshot.data != null)
                  ListTile(
                    title: Text(
                      "Version - " + snapshot.data!.version,
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {},
                  ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Sorry, Something went wrong.",
            style: TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          );
        } else {
          return CustomLoader();
        }
      },
    );
  }

  void refresh(BuildContext context) async {
    await Preference.setDateTime(SP_DT_REFRESH);
    FirebaseFirestore fireStore = GetIt.I.get<FirebaseFirestore>();
    await Products.getDisplayData(fireStore, true);
    await Products.getAllProducts(fireStore, true);
    await Phoenix.rebirth(context);
  }
}

Widget _createDrawerItem(
    {required IconData icon,
    required String text,
    required GestureTapCallback onTap}) {
  return _createDrawerIconItem(icon: Icon(icon), text: text, onTap: onTap);
}

Widget _createDrawerIconItem(
    {required Icon icon,
    required String text,
    required GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        icon,
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(text),
        )
      ],
    ),
    onTap: onTap,
  );
}

void _launchURL(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

Future<String> getPackageInfo() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
