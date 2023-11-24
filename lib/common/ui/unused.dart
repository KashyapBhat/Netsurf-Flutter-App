import 'package:flutter/material.dart';

void elevatedButtonAdd() {
  ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      minimumSize: Size(15, 40),
    ),
    child: Icon(Icons.add),
    onPressed: () {
      // setState(() {
      //   if (selectedProducts != null)
      //     selectedProducts[index].quantity++;
      //   calculateTotal();
      // });
    },
  );
}

void elevatedButtonSub() {
  ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      minimumSize: Size(15, 40),
    ),
    child: Icon(Icons.remove),
    onPressed: () {
      // setState(() {
      //   if (selectedProducts[index].quantity > 1)
      //     selectedProducts[index].quantity--;
      //   calculateTotal();
      // });
    },
  );
}
