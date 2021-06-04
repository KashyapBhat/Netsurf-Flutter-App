import 'package:flutter/material.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';

class AppDrawer extends StatelessWidget {
  final User retailer;

  const AppDrawer({Key key, this.retailer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(retailer),
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
                  content: Text("Cleared."),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ));
            },
          ),
          Divider(),
          _createDrawerItem(
            icon: Icons.face,
            text: 'Author',
            onTap: () {},
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
            onTap: () {},
          ),
          ListTile(
            title: Text('0.0.1'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

Widget _createHeader(User retailer) {
  return DrawerHeader(
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    decoration: BoxDecoration(
      color: Colors.white70,
      image: new DecorationImage(
        image: NetworkImage(
            "https://images.pexels.com/photos/3687999/pexels-photo-3687999.jpeg?cs=srgb&dl=pexels-mehrad-vosoughi-3687999.jpg&fm=jpg"),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(),
  );
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
