import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/edittext.dart';

void showLogoutErrorDialog(BuildContext buildContext) {
  showDialog(
    context: buildContext,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text("Are you sure you want to logout?")),
        actions: <Widget>[
          CustomButton(
            buttonText: "Logout",
            onClick: () async {
              Navigator.of(context).pop();
              if (await Preference.remove(SP_RETAILER))
                Phoenix.rebirth(buildContext);
            },
          ),
        ],
      );
    },
  );
}
