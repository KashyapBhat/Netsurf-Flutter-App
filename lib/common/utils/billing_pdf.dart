import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:project_netsurf/common/contants.dart';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/retailer.dart';
import 'package:project_netsurf/common/utils/common_utils.dart';
import 'package:project_netsurf/common/utils/pdf_api.dart';

class PdfInvoiceApi {
  static Future<File> generate(Billing invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        buildHeader(invoice),
        SizedBox(height: 3 * PdfPageFormat.cm),
        buildTitle(invoice),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
      footer: (context) => buildFooter(invoice),
    ));

    return PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }

  static Widget buildHeader(Billing invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(invoice.customerData),
              buildInvoiceInfo(invoice.billingInfo),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(CustomerData customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text(customer.mobileNo),
          SizedBox(height: 2),
          Text(customer.email),
          SizedBox(height: 5),
          Text("Ref ID: " + customer.cRefId,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      );

  static Widget buildInvoiceInfo(BillingInfo info) {
    // final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      // 'Payment Terms:',
      // 'Due Date:'
    ];
    final data = <String>[
      info.number,
      formatDate(info.date),
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

  static Widget buildSupplierAddress(Retailer retailer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Distributor:", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(retailer.name),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(retailer.mobileNo),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(retailer.address),
        ],
      );

  static Widget buildTitle(Billing invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVOICE',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          Text(invoice.billingInfo.description),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Billing invoice) {
    final headers = ['Title', 'Qty.', 'Unit Cost', 'Total'];
    final data = invoice.productsSelected.map((item) {
      final total = item.price * item.quantity;

      return [
        item.name,
        '${item.quantity}',
        ' ${item.price}',
        ' $total',
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Billing invoice) {
    final netTotal = invoice.price.total;
    final discount = invoice.price.discountAmt;
    final total = invoice.price.finalAmt;

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
                  // value: Utils.formatPrice(netTotal),
                  value: netTotal.ceil().toString(),
                  unite: true,
                ),
                buildText(
                  title: 'Discount',
                  // TODO: price
                  // value: Utils.formatPrice(discount),
                  value: discount.ceil().toString(),
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
                  value: total.toString(),
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
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSupplierAddress(invoice.retailer),
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
          SizedBox(height: 2 * PdfPageFormat.mm),
          if (invoice.retailer.address != null &&
              invoice.retailer.address.isNotEmpty)
            buildSimpleText(title: 'Address', value: invoice.retailer.address),
          // TODO: Payment info
          // SizedBox(height: 1 * PdfPageFormat.mm),
          // buildSimpleText(title: 'Paypal', value: invoice.retailer.paymentInfo),
        ],
      );

  static buildSimpleText({
    String title,
    String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
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
    String title,
    String value,
    double width = double.infinity,
    TextStyle titleStyle,
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
