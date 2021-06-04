import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/loader.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  final User retailer;

  const AppDrawer({Key key, this.retailer}) : super(key: key);

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
                  imageUrl:
                      "https://firebasestorage.googleapis.com/v0/b/net-surf-app.appspot.com/o/naturamore.png?alt=media&token=de21fdd0-c6f6-4113-babe-ac0abdc53878",
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CustomLoader(),
                  fit: BoxFit.cover,
                  fadeInCurve: Curves.easeInToLinear,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          retailer.name ?? "Anonymous User",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          retailer.mobileNo ?? "**********",
                          style: TextStyle(color: Colors.black, fontSize: 13.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                SizedBox(height: 8),
                _createDrawerItem(
                  icon: Icons.collections_bookmark,
                  text: 'Saved bills',
                  onTap: () {},
                ),
                _createDrawerItem(
                  icon: Icons.account_box_rounded,
                  text: 'Clear user data',
                  onTap: () async {
                    if (await Preference.remove(SP_RETAILER))
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "Cleared.",
                          textAlign: TextAlign.end,
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ));
                  },
                ),
                Divider(),
                _createDrawerItem(
                  icon: Icons.face,
                  text: 'Author',
                  onTap: () {
                    const _url = 'https://codingcurve.in/';
                    _launchURL(_url);
                  },
                ),
                _createDrawerItem(
                  icon: Icons.stars,
                  text: 'Useful Links',
                  onTap: () {},
                ),
                Divider(),
                _createDrawerItem(
                  icon: Icons.bug_report,
                  text: 'Report an issue',
                  onTap: () async {
                    final Uri params = Uri(
                      scheme: 'mailto',
                      path: 'info.codingcurve@gmail.com',
                      query: 'subject=App Feedback&body=App Version: ' +
                          snapshot.data.version, //add subject and body here
                    );
                    _launchURL(params.toString());
                  },
                ),
                ListTile(
                  title: Text(snapshot.data.version),
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
