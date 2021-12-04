import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/billing_info.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/utils/common_utils.dart';
import 'package:project_netsurf/common/utils/pdf_api.dart';

class PdfInvoiceApi {
  static Future<File> generate(Billing invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        buildHeader(invoice),
        Divider(),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
      footer: (context) => buildFooter(invoice),
    ));

    String billNumber = invoice.billingInfo?.number ?? "";
    String fileName = invoice.customer?.mobileNo ?? "" + billNumber + ".pdf";
    return PdfApi.saveDocument(name: fileName, pdf: pdf);
  }

  static Widget buildHeader(Billing invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.mm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (invoice.customer != null)
                buildCustomerAddress(invoice.customer!),
              if (invoice.billingInfo != null)
                buildInvoiceInfo(invoice.billingInfo!),
            ],
          ),
          SizedBox(height: 0.8 * PdfPageFormat.mm),
        ],
      );

  static Widget buildCustomerAddress(User customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: " + customer.name,
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text("Phone: " + customer.mobileNo),
          SizedBox(height: 2),
          Text(customer.email),
          if (customer.cRefId.isNotEmpty)
            SizedBox(height: 2),
          if (customer.cRefId.isNotEmpty)
            Text("Ref: " + customer.cRefId,
                style: TextStyle(fontWeight: FontWeight.bold)),
        ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(User retailer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Distributor", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(retailer.name),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(retailer.mobileNo),
        ],
      );

  static Widget buildTitle(Billing invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 0.8 * PdfPageFormat.mm),
          pw.Center(
            child: Text(
              'ESTIMATE',
              textAlign: pw.TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (invoice.billingInfo != null &&
              invoice.billingInfo!.description.isNotEmpty)
            SizedBox(height: 0.8 * PdfPageFormat.cm),
          if (invoice.billingInfo != null &&
              invoice.billingInfo!.description.isNotEmpty)
            Text(invoice.billingInfo!.description),
          SizedBox(height: 0.8 * PdfPageFormat.mm),
        ],
      );

  static Widget buildInvoice(Billing invoice) {
    final headers = ['Title', 'Qty', 'MRP', 'Total'];
    final data = invoice.selectedProducts?.map((item) {
      return [
        item?.name,
        '${item?.quantity}',
        ' ${item?.getDispPrice()}',
        ' ${item?.getDispTotal()}',
      ];
    }).toList();
    if (data != null) return Text("NA");
    return Table.fromTextArray(
      headers: headers,
      headerAlignment: Alignment.centerRight,
      data: data!,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Billing invoice) {
    final netTotal = invoice.price?.dispTotal() ?? "NA";
    final discount = invoice.price?.dispDiscAmt() ?? "NA";
    final total = invoice.price?.dispFinalAmt() ?? "NA";

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
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
                Divider(),
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
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
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
          SizedBox(height: 1.3 * PdfPageFormat.mm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (invoice.retailer != null)
                buildSupplierAddress(invoice.retailer!),
              // Barcode Removed for now
              // Container(
              //   height: 50,
              //   width: 50,
              //   child: BarcodeWidget(
              //     barcode: Barcode.qrCode(),
              //     data: invoice.info.number,
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 2 * PdfPageFormat.mm)
          // TODO: Payment info
          // SizedBox(height: 1 * PdfPageFormat.mm),
          // buildSimpleText(title: 'Paypal', value: invoice.retailer.paymentInfo),
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return pw.Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
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
      child: Expanded(
        child: Row(
          mainAxisAlignment: unite
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: style),
            Text(" " + value, style: unite ? style : null),
          ],
        ),
      ),
    );
  }
}
