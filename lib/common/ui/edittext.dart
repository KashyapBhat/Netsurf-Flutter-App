import 'package:flutter/material.dart';

class EditText extends StatelessWidget {
  String editTextName = "";
  TextInputType type = TextInputType.name;

  EditText({Key key, this.editTextName, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: new EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: new TextFormField(
            decoration: new InputDecoration(
              labelText: editTextName,
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(25.0),
                borderSide: new BorderSide(),
              ),
            ),
            validator: (val) {
              if (val.length == 0) {
                return "Cannot be empty";
              } else {
                return null;
              }
            },
            keyboardType: type,
            style: new TextStyle(
              fontFamily: "Poppins",
            ),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  String buttonText = "";
  Function onClick;

  CustomButton({Key key, this.buttonText, this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: new EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            onPrimary: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            minimumSize: Size(120, 48),
          ),
          child: Text(buttonText),
          onPressed: () {
            onClick.call();
          },
        ));
  }
}
