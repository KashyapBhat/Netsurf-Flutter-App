import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditText extends StatelessWidget {
  String? editTextName = "";
  String? initTextValue = "";
  TextInputType? type = TextInputType.name;
  bool required = false;
  bool? isPhone = false;
  int? maxline = 1;
  Function(String)? onText;
  TextEditingController? _controller;
  Function()? onTap;

  EditText(
      {Key? key,
      this.editTextName,
      this.type,
      required this.required,
      this.maxline,
      this.onText,
      this.onTap,
      this.initTextValue,
      this.isPhone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _controller = TextEditingController();
    if (isPhone == null) {
      isPhone = false;
    }
    return Container(
      constraints: BoxConstraints(minHeight: 55, minWidth: double.infinity),
      padding: EdgeInsets.symmetric(horizontal: 26),
      child: TextFormField(
        controller: _controller,
        textCapitalization: TextCapitalization.characters,
        maxLines: maxline,
        decoration: InputDecoration(
          labelText: editTextName ?? "NA" + (required ? " \*" : ""),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(),
          ),
        ),
        inputFormatters: [
          if (isPhone ?? false)
            FilteringTextInputFormatter.allow((RegExp("[.0-9]"))),
        ],
        maxLength: isPhone ?? false ? 10 : null,
        keyboardType: type,
        onChanged: (value) {
          onText?.call(_controller?.text ?? "NA");
        },
        onTap: () {
          onTap?.call();
        },
      ),
    );
  }
}

class InputText extends StatelessWidget {
  String? keyText = "";
  int? maxline = 1;
  Function(String?)? onText;
  TextEditingController? controller;

  InputText(
      {Key? key, this.maxline, this.onText, this.keyText, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorWidth: 1.3,
      controller: controller,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
      ),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 19),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        onText?.call(controller?.text);
      },
    );
  }
}

class CustomButton extends StatelessWidget {
  String? buttonText = "";
  Function? onClick;

  CustomButton({Key? key, this.buttonText, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: new EdgeInsets.symmetric(vertical: 2, horizontal: 16),
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            fixedSize: Size(120, 48),
          ),
          child: Text(
            buttonText ?? "",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.3,
                letterSpacing: 1.1),
          ),
          onPressed: () {
            onClick?.call();
          },
        ));
  }
}

class SideButtons extends StatelessWidget {
  String? buttonText = "";
  Function? onClick;

  SideButtons({Key? key, this.buttonText, this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        fixedSize: Size(120, 48),
      ),
      child: Text(
        buttonText ?? "NA",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.3,
            letterSpacing: 1.1),
      ),
      onPressed: () {
        onClick?.call();
      },
    );
  }
}
