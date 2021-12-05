import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/intl.dart';
import 'package:project_netsurf/common/analytics.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/billing_info.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:project_netsurf/common/sp_utils.dart';
import 'package:project_netsurf/common/ui/edittext.dart';
import 'package:project_netsurf/common/utils/billing_pdf.dart';
import 'package:project_netsurf/common/utils/common_utils.dart';
import 'package:project_netsurf/common/utils/pdf_api.dart';
import 'package:project_netsurf/main.dart';

class BillerPage extends StatefulWidget {
  final bool isAlreadySaved;
  final Billing billing;

  BillerPage({Key? key, required this.billing, this.isAlreadySaved = true})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<BillerPage> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    analytics.setCurrentScreen(screenName: CT_BILLING);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(APP_NAME, textAlign: TextAlign.center),
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.all(1),
          child: Card(
            child: Container(
              child: Column(
                children: [
                  buildHeader(widget.billing),
                  buildTitle(widget.billing),
                  SizedBox(height: 5),
                  buildInvoice(widget.billing),
                  Divider(),
                  buildTotal(context, widget.billing, widget.isAlreadySaved),
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
              if (invoice.customer != null)
                Expanded(child: buildCustomerAddress(invoice.customer!)),
              if (invoice.billingInfo != null)
                Expanded(child: buildInvoiceInfo(invoice.billingInfo!)),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(User customer) => Container(
        padding: EdgeInsets.only(left: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("" + customer.name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text("" + customer.mobileNo),
            if (customer.email.isNotEmpty) SizedBox(height: 2),
            if (customer.email.isNotEmpty) Text("" + customer.email),
            SizedBox(height: 2),
            Text("" + customer.cRefId),
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
      if (info.date != null) formatDate(info.date!),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      );

  static Widget buildInvoice(Billing invoice) {
    final headers = ['TITLE', 'QTY', 'MRP', 'TOTAL'];
    final data = invoice.selectedProducts?.map((item) {
      return [
        item?.name,
        '${item?.quantity}',
        ' ${item?.getDispPrice()}',
        ' ${item?.getDispTotal()}',
      ];
    }).toList();
    if (data == null) return Text("NA");
    data.insert(0, headers);

    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5),
        child: ListView.separated(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length,
            separatorBuilder: (context, int) {
              return Container(
                padding: EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
                child: Divider(
                  thickness: 1,
                  height: 4,
                ),
              );
            },
            itemBuilder: (context, index) {
              if (data == null) {
                return Container(child: Center(child: Text("NA")));
              }
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
                      child: Text(data[index][0] ?? "NA",
                          style: TextStyle(
                              color: Colors.black, fontSize: 14, height: 1.3),
                          textAlign: TextAlign.start),
                    ),
                  ),
                  Container(
                    width: 45,
                    child: Center(
                      child: Text(data[index][1] ?? "NA",
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          textAlign: TextAlign.left),
                    ),
                  ),
                  Container(
                    width: 50,
                    child: Center(
                      child: Text(data[index][2] ?? "NA",
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          textAlign: TextAlign.left),
                    ),
                  ),
                  Container(
                    width: 65,
                    child: Center(
                      child: Text(data[index][3] ?? "NA",
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

  static Widget buildTotal(
      BuildContext context, Billing invoice, bool isAlreadySaved) {
    final netTotal = invoice.price?.dispTotal() ?? "NA";
    final discount = invoice.price?.dispDiscAmt() ?? "NA";
    final total = invoice.price?.dispFinalAmt() ?? "NA";

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
                    title: TOTAL_AMOUNT,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    // TODO: price
                    value: netTotal,
                    unite: true,
                  ),
                  buildText(
                    title: DISCOUNT,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    // TODO: price
                    // value: Utils.formatPrice(discount),
                    value: discount,
                    unite: true,
                  ),
                  Divider(height: 5),
                  buildText(
                    title: FINAL_AMOUNT,
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
                ],
              ),
            ),
          ),
          Expanded(
            child: CustomButton(
              buttonText: isAlreadySaved ? "Share PDF" : "SAVE",
              onClick: () async {
                DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
                var formatter = new DateFormat('dd/MM/yyyy – HH:mm');
                String formattedDate = "";
                if (invoice.billingInfo != null &&
                    invoice.billingInfo!.date != null) {
                  formattedDate = formatter.format(invoice.billingInfo!.date!);
                  print("Formated Date" + formattedDate);
                }
                analytics.setCurrentScreen(screenName: CT_PDF_CREATION);
                analytics.logEvent(
                  name: CT_SAVE_BILL,
                  parameters: <String, dynamic>{
                    CT_DISTRIBUTOR_NAME: invoice.retailer?.name,
                    CT_DISTRIBUTOR_PH_NO: invoice.retailer?.mobileNo,
                    CT_CUSTOMER_NAME: invoice.customer?.name,
                    CT_CUSTOMER_PH_NO: invoice.customer?.mobileNo,
                    CT_BILLING_NO: invoice.billingInfo?.number,
                    CT_BILLING_DATE: formattedDate,
                    CT_MODEL_NAME: androidInfo.model,
                    CT_MANUFACTURER_NAME: androidInfo.manufacturer,
                    CT_ANDROID_ID: androidInfo.androidId,
                    CT_ANDROID_VERSION_STRING: androidInfo.version.release,
                    CT_ANDROID_VERSION: androidInfo.version.baseOS
                  },
                );
                if (!isAlreadySaved)
                  await Preference.setItem(
                      SP_BILLING_ID, invoice.billingInfo?.number ?? "");
                if (!isAlreadySaved) await Preference.addBill(invoice);
                final billings = await Preference.getBills();
                billings.forEach((element) {
                  if (element.price != null)
                    print("BILLS" + element.price!.dispFinalAmt());
                });
                File pdf = await PdfInvoiceApi.generate(invoice);
                PdfApi.openFile(pdf);
                Phoenix.rebirth(context);
              },
            ),
          ),
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
              if (invoice.retailer != null)
                buildSupplierAddress(invoice.retailer!),
            ],
          ),
          SizedBox(height: 6),
          if (invoice.retailer != null && invoice.retailer!.address.isNotEmpty)
            buildSimpleText(title: 'Address', value: invoice.retailer!.address),
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
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
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
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
          Text("" + title, style: style),
          Text(" " + value, style: unite ? style : null),
        ],
      ),
    );
  }

  static Widget buildSupplierAddress(User retailer) => Column(
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
