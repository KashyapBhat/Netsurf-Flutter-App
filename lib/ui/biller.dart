import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/billing_info.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/retailer.dart';
import 'package:project_netsurf/common/ui/edittext.dart';
import 'package:project_netsurf/common/utils/billing_pdf.dart';
import 'package:project_netsurf/common/utils/common_utils.dart';
import 'package:project_netsurf/common/utils/pdf_api.dart';

class BillerPage extends StatefulWidget {
  final Billing billing;

  BillerPage({Key key, this.billing}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<BillerPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Net Surf", textAlign: TextAlign.center),
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.all(1),
          child: Card(
            child: Container(
              child: Column(
                children: [
                  buildHeader(widget.billing),
                  SizedBox(height: 16),
                  buildTitle(widget.billing),
                  SizedBox(height: 5),
                  buildInvoice(widget.billing),
                  Divider(),
                  buildTotal(widget.billing),
                ],
              ),
            ),
          ),
        ));
  }

  static Widget buildHeader(Billing invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: buildCustomerAddress(invoice.customer)),
              Expanded(child: buildInvoiceInfo(invoice.billingInfo)),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(Customer customer) => Container(
        padding: EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text(customer.mobileNo),
            SizedBox(height: 2),
            Text(customer.email),
            SizedBox(height: 2),
            Text("Ref No: " + customer.cRefId,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  static Widget buildInvoiceInfo(BillingInfo info) {
    // final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Serial No:',
      'Date:',
      // 'Payment Terms:',
      // 'Due Date:'
    ];
    final data = <String>[
      info.number,
      formatDate(info.date),
      // paymentTerms,
      // formatDate(info.dueDate),
    ];

    return Container(
      padding: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(titles.length, (index) {
          final title = titles[index];
          final value = data[index];

          return buildText(title: title, value: value, width: 200);
        }),
      ),
    );
  }

  static Widget buildTitle(Billing invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTIMATE',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      );

  static Widget buildInvoice(Billing invoice) {
    final headers = ['TITLE', 'QTY', 'MRP', 'TOTAL'];
    final data = invoice.selectedProducts.map((item) {
      return [
        item.name,
        '${item.quantity}',
        ' ${item.getDispPrice()}',
        ' ${item.getDispTotal()}',
      ];
    }).toList();
    data.insert(0, headers);

    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: ListView.separated(
            shrinkWrap: true,
            itemCount: data.length ?? 0,
            separatorBuilder: (context, int) {
              return Container(
                padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
                child: Divider(
                  thickness: 1,
                  height: 6,
                ),
              );
            },
            itemBuilder: (context, index) {
              return Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    child: Center(
                      child: Text(index > 0 ? (index).toString() : "",
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          textAlign: TextAlign.left),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.only(left: 0, top: 8, right: 5, bottom: 8),
                      child: Text(data[index][0],
                          style: TextStyle(
                              color: Colors.black, fontSize: 14, height: 1.3),
                          textAlign: TextAlign.start),
                    ),
                  ),
                  Container(
                    width: 45,
                    child: Center(
                      child: Text(data[index][1],
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          textAlign: TextAlign.left),
                    ),
                  ),
                  Container(
                    width: 50,
                    child: Center(
                      child: Text(data[index][2],
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          textAlign: TextAlign.left),
                    ),
                  ),
                  Container(
                    width: 65,
                    child: Center(
                      child: Text(data[index][3],
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          textAlign: TextAlign.left),
                    ),
                  ),
                ],
              ));
            }),
      ),
    );
  }

  static Widget buildTotal(Billing invoice) {
    final netTotal = invoice.price.dispTotal();
    final discount = invoice.price.dispDiscAmt();
    final total = invoice.price.dispFinalAmt();

    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 5, right: 5, bottom: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildText(
                    title: 'Total',
                    // TODO: price
                    value: netTotal,
                    unite: true,
                  ),
                  buildText(
                    title: 'Discount',
                    // TODO: price
                    // value: Utils.formatPrice(discount),
                    value: discount,
                    unite: true,
                  ),
                  Divider(height: 5),
                  buildText(
                    title: 'Total amount',
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    // TODO: price
                    // value: Utils.formatPrice(total),
                    value: total,
                    unite: true,
                  ),
                  SizedBox(height: 3),
                  Container(height: 1, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
          Expanded(
              child: CustomButton(
                  buttonText: "Save PDF",
                  onClick: () async {
                    File pdf = await PdfInvoiceApi.generate(invoice);
                    PdfApi.openFile(pdf);
                  })),
        ],
      ),
    );
  }

  static Widget buildFooter(Billing invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSupplierAddress(invoice.retailer),
            ],
          ),
          SizedBox(height: 6),
          if (invoice.retailer.address != null &&
              invoice.retailer.address.isNotEmpty)
            buildSimpleText(title: 'Address', value: invoice.retailer.address),
        ],
      );

  static buildSimpleText({
    String title,
    String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 6),
        Text(value),
      ],
    );
  }

  static buildText({
    String title,
    String value,
    double width = double.infinity,
    TextStyle titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        mainAxisAlignment: unite
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(" " + value, style: unite ? style : null),
        ],
      ),
    );
  }

  static Widget buildSupplierAddress(Retailer retailer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Distributor:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 3),
          Text(retailer.name),
          SizedBox(height: 3),
          Text(retailer.mobileNo),
          SizedBox(height: 3),
          Text(retailer.address),
        ],
      );

  @override
  void dispose() {
    super.dispose();
  }
}
