import 'package:flutter/material.dart';
import 'package:project_netsurf/product.dart';

void showModelBottomSheet(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
    List<Product> productList,
    TextEditingController textController,
    Function(Product) onClick) {
  List<Product> _listAfterSearch;

  Product _getClickedProduct(int index) {
    if ((_listAfterSearch != null && _listAfterSearch.length > 0)) {
      return _listAfterSearch[index];
    } else {
      return productList[index];
    }
  }

  int _getListViewItemCount() {
    if ((_listAfterSearch != null && _listAfterSearch.length > 0)) {
      return _listAfterSearch.length;
    } else {
      return productList.length;
    }
  }

  Widget _getProductListAndWidget(int index) {
    if ((_listAfterSearch != null && _listAfterSearch.length > 0)) {
      return _showBottomSheetWithSearch(index, _listAfterSearch);
    } else {
      return _showBottomSheetWithSearch(index, productList);
    }
  }

  showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      context: context,
      builder: (context) {
        //3
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableActuator(
              child: DraggableScrollableSheet(
                  expand: false,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Column(children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(children: <Widget>[
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
                                        _listAfterSearch = _buildSearchList(
                                            value, productList);
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
                          ])),
                      Expanded(
                        child: ListView.separated(
                            controller: scrollController,
                            itemCount: _getListViewItemCount(),
                            separatorBuilder: (context, int) {
                              return Divider(
                                indent: 10,
                                endIndent: 10,
                              );
                            },
                            itemBuilder: (context, index) {
                              return InkWell(
                                  child: _getProductListAndWidget(index),
                                  onTap: () {
                                    onClick.call(_getClickedProduct(index));
                                    Navigator.of(context).pop();
                                  });
                            }),
                      )
                    ]);
                  }));
        });
      });
}

//8
Widget _showBottomSheetWithSearch(int index, List<Product> productList) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
          child: Container(
        child: Text(productList[index].getDisplayName(),
            style: TextStyle(color: Colors.black, fontSize: 16, height: 1.3),
            textAlign: TextAlign.start),
        padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
      )),
      if (productList[index].price != 0)
        Expanded(
            child: Container(
          child: Text(productList[index].price.toString(),
              style: TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.end),
          padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        )),
    ],
  );
}

//9
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
