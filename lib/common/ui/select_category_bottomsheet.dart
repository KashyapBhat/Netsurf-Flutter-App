import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_netsurf/common/models/product.dart';

void showSelectCategoryBottomSheet(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
    List<Product?> productList,
    TextEditingController textController,
    Function(Product?) onClick) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableActuator(
            child: DraggableScrollableSheet(
              expand: false,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 26),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        "Select Category",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: productList.length,
                        separatorBuilder: (context, int) {
                          return Divider(
                            indent: 10,
                            endIndent: 10,
                          );
                        },
                        itemBuilder: (context, index) {
                          return InkWell(
                              child: _showBottomSheetWithSearch(
                                  index, productList),
                              onTap: () {
                                onClick.call(productList[index]);
                                Navigator.of(context).pop();
                              });
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          );
        });
      });
}

Widget _showBottomSheetWithSearch(int index, List<Product?> productList) {
  return Container(
    padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
    child: Text(productList[index]?.getDisplayName() ?? "NA",
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
        ),
        textAlign: TextAlign.start),
  );
}
