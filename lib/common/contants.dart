import 'package:flutter/material.dart';

const String APP_NAME = "Netsurfs Calci";
const String SAVED = "Saved bills";
const String RUPEE_SYMBOL = "\u20B9";
const String TOTAL_AMOUNT = "Total amount (" + RUPEE_SYMBOL +") ";
const String DISCOUNT = "Discount (" + RUPEE_SYMBOL +") ";
const String FINAL_AMOUNT = "Final Amount (" + RUPEE_SYMBOL +") ";

const int PRIMARY_COLOR = 0xFF333366;
const int SECONDARY_COLOR = 0xFF5555aa;
const int LOADER_COLOR = 0x445555aa;
const int LOADER_BASE_COLOR = 0x115555aa;

Map<int, Color> THEME_COLOR = {
  50: Color.fromRGBO(51, 51, 102, .1),
  100: Color.fromRGBO(51, 51, 102, .2),
  200: Color.fromRGBO(51, 51, 102, .3),
  300: Color.fromRGBO(51, 51, 102, .4),
  400: Color.fromRGBO(51, 51, 102, .5),
  500: Color.fromRGBO(51, 51, 102, .6),
  600: Color.fromRGBO(51, 51, 102, .7),
  700: Color.fromRGBO(51, 51, 102, .8),
  800: Color.fromRGBO(51, 51, 102, .9),
  900: Color.fromRGBO(51, 51, 102, 1),
};
