import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          SizedBox(
            height: 8,
          ),
          _createDrawerItem(
            icon: Icons.collections_bookmark,
            text: 'Saved bills',
            onTap: () {},
          ),
          Divider(),
          _createDrawerItem(
            icon: Icons.face,
            text: 'Author',
            onTap: () {},
          ),
          _createDrawerItem(
              icon: Icons.account_box, text: 'Flutter Documentation'),
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

Widget _createHeader() {
  return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.blue,
        image: new DecorationImage(
          image: new ExactAssetImage('assets/naturamore.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(children: <Widget>[
        Positioned(
          bottom: 8.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Shrinidhi",
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 3,
              ),
              Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  "9483214259",
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.black, fontSize: 13.0),
                ),
              ),
            ],
          ),
        ),
      ]));
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
