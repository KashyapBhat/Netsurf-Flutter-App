import 'package:flutter/material.dart';
import 'package:project_netsurf/common/models/product.dart';
import 'package:project_netsurf/common/ui/edittext.dart';

void selectProductsBottomSheet(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
    List<Product> productList,
    TextEditingController textController,
    Function(BuildContext context, Product) onClick) {
  List<Product>? _listAfterSearch;
  print("Recreated");
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
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: TextField(
                                  controller: textController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(8),
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(15.0),
                                      borderSide: new BorderSide(),
                                    ),
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _listAfterSearch =
                                          _buildSearchList(value, productList);
                                    });
                                  })),
                          IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  textController.clear();
                                  Navigator.pop(context);
                                });
                              }),
                        ],
                      ),
                    ),
                    if (_getListViewItemCount(_listAfterSearch, productList) <
                        1)
                      Text("No more products to add!"),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: _getListViewItemCount(
                            _listAfterSearch, productList),
                        separatorBuilder: (context, int) {
                          return Divider(
                            indent: 10,
                            endIndent: 10,
                          );
                        },
                        itemBuilder: (context, index) {
                          return InkWell(
                            child: _getProductListAndWidget(
                                _listAfterSearch, productList, index),
                            onTap: () {
                              setState(() {
                                Product selectedProduct = _getClickedProduct(
                                    _listAfterSearch, productList, index);
                                onClick.call(context, selectedProduct);
                                productList.remove(selectedProduct);
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8, top: 8),
                      child: CustomButton(
                        buttonText: "DONE",
                        onClick: () {
                          Navigator.of(context).pop();
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

Widget _showBottomSheetWithSearch(int index, List<Product> productList) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
          child: Container(
        padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        child: Text(productList[index].getDisplayName(),
            style: TextStyle(fontSize: 15, height: 1.3),
            textAlign: TextAlign.start),
      )),
      if (productList[index].price != 0)
        Container(
          padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
          child: Text(productList[index].price.toString(),
              style: TextStyle(fontSize: 15), textAlign: TextAlign.end),
        ),
    ],
  );
}

List<Product> _buildSearchList(
    String userSearchTerm, List<Product> productList) {
  List<Product> _searchList = [];
  for (int i = 0; i < productList.length; i++) {
    String name = productList[i].getDisplayName();
    if (name.toLowerCase().contains(userSearchTerm.toLowerCase())) {
      _searchList.add(productList[i]);
    }
  }
  return _searchList;
}

Product _getClickedProduct(
    List<Product>? _listAfterSearch, List<Product> productList, int index) {
  if ((_listAfterSearch != null && _listAfterSearch.isNotEmpty)) {
    return _listAfterSearch[index];
  } else {
    return productList[index];
  }
}

int _getListViewItemCount(
    List<Product>? _listAfterSearch, List<Product> productList) {
  if ((_listAfterSearch != null && _listAfterSearch.isNotEmpty)) {
    return _listAfterSearch.length;
  } else {
    return productList.length;
  }
}

Widget _getProductListAndWidget(
    List<Product>? _listAfterSearch, List<Product> productList, int index) {
  if ((_listAfterSearch != null && _listAfterSearch.isNotEmpty)) {
    return _showBottomSheetWithSearch(index, _listAfterSearch);
  } else {
    return _showBottomSheetWithSearch(index, productList);
  }
}
