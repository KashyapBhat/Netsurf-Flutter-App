import 'package:intl/intl.dart';

formatPrice(double price) => '\$ ${price.toStringAsFixed(2)}';
formatDate(DateTime date) => DateFormat.yMd().format(date);