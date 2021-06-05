import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/loader.dart';
import 'package:project_netsurf/ui/bills.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  final User retailer;
  final DisplayData displayData;

  const AppDrawer({Key key, this.retailer, this.displayData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  fit: BoxFit.cover,
                  fadeInCurve: Curves.easeInToLinear,
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error_outlined),
                ),
                if (retailer.name.isNotEmpty) SizedBox(height: 8),
                if (retailer.name.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            retailer.name,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            retailer.mobileNo,
                            style:
                                TextStyle(color: Colors.black, fontSize: 13.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (retailer.name.isNotEmpty) Divider(),
                SizedBox(height: 8),
                _createDrawerItem(
                  icon: Icons.home_rounded,
                  text: 'Home',
                  onTap: () {},
                ),
                _createDrawerItem(
                  icon: Icons.collections_bookmark_rounded,
                  text: 'Saved bills',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (__) => BillsPage(
                              retailer: retailer, displayData: displayData)),
                    );
                  },
                ),
                _createDrawerItem(
                  icon: Icons.account_box_rounded,
                  text: 'Clear user',
                  onTap: () async {
                    if (await Preference.remove(SP_RETAILER))
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "Cleared!",
                          textAlign: TextAlign.end,
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ));
                  },
                ),
                Divider(),
                _createDrawerItem(
                  icon: Icons.tag_faces,
                  text: displayData.aname,
                  onTap: () {
                    _launchURL(displayData.alink);
                  },
                ),
                Divider(),
                _createDrawerItem(
                  icon: Icons.bug_report,
                  text: 'Report an issue',
                  onTap: () async {
                    final Uri params = Uri(
                      scheme: 'mailto',
                      path: displayData.aemail,
                      query: 'subject=App Feedback&body=App Version: ' +
                          snapshot.data.version, //add subject and body here
                    );
                    _launchURL(params.toString());
                  },
                ),
                ListTile(
                  title: Text("v " + snapshot.data.version),
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
}

Widget _createDrawerItem(
    {IconData icon, String text, GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
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
