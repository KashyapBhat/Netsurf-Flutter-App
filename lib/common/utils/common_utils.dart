import 'package:intl/intl.dart';

formatPrice(double price) => '\$ ${price.toStringAsFixed(2)}';
formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);


dynamic myDateSerializer(dynamic object) {
  if (object is DateTime) {
    return object.toIso8601String();
  }
  return object;
}