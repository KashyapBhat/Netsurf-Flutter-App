import 'dart:async';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/customer.dart';
import 'package:project_netsurf/common/models/display_data.dart';
import 'package:project_netsurf/common/sp_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/product.dart';

class Preference {
  Preference._();

  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<SharedPreferences> getPref() async {
    return await _prefs;
  }

  static Future<bool> remove(String name) async {
    return (await _prefs).remove(name);
  }

  static Future<String> getItem(String name) async {
    return (await _prefs).getString(name) ?? '';
  }

  static Future<bool> setItem(String name, String value) async {
    return (await _prefs).setString(name, value);
  }

  static Future<int> getIntItem(String name) async {
    return (await _prefs).getInt(name) ?? 0;
  }

  static Future<bool> setIntItem(String name, int value) async {
    return (await _prefs).setInt(name, value);
  }

  static Future<double> getDoubleItem(String name) async {
    return (await _prefs).getDouble(name) ?? 0;
  }

  static Future<bool> setDoubleItem(String name, double value) async {
    return (await _prefs).setDouble(name, value);
  }

  static Future<bool> getBoolItem(String name) async {
    return (await _prefs).getBool(name) ?? false;
  }

  static Future<bool> setBoolItem(String name, bool value) async {
    return (await _prefs).setBool(name, value);
  }

  static Future<Set<String>> getAll() async {
    return (await _prefs).getKeys();
  }

  static Future<bool> setListData(String key, List<String> value) async {
    return (await _prefs).setStringList(key, value);
  }

  Future<List<String>?> getListData(String key) async {
    return (await _prefs).getStringList(key);
  }

  static Future<bool> contains(String name) async {
    return (await _prefs).containsKey(name);
  }

  static Future<bool> setDisplayData(DisplayData displayData) async {
    final String encodedData = DisplayData.encode(displayData);
    return (await _prefs).setString(SP_DISPLAY, encodedData);
  }

  static Future<DisplayData> getDisplayData() async {
    String displayString = (await _prefs).getString(SP_DISPLAY) ?? "";
    final DisplayData decodedData = DisplayData.decode(displayString);
    return decodedData;
  }

  static Future<bool> setProducts(List<Product> products, String name) async {
    final String encodedData = Product.encode(products);
    return await (await _prefs).setString(name, encodedData);
  }

  static Future<List<Product>> getProducts(String name) async {
    String productsEncoded = (await _prefs).getString(name) ?? "";
    final List<Product> decodedData = Product.decode(productsEncoded);
    return decodedData;
  }

  static Future<bool> setRetailer(User retailer) async {
    final String encodedData = User.encode(retailer);
    return (await _prefs).setString(SP_RETAILER, encodedData);
  }

  static Future<User?> getRetailer() async {
    String? decodedData = (await _prefs).getString(SP_RETAILER);
    if (decodedData == null) return null;
    final User decodedRetailer = User.decode(decodedData);
    return decodedRetailer;
  }

  static Future<bool> addBill(Billing billing) async {
    List<Billing> bills = [];
    if (!(await _prefs).containsKey(SP_BILLING)) {
      bills.add(billing);
    } else {
      bills = await getBills();
      bills.insert(0, billing);
    }
    final String encodedData = Billing.encodeList(bills);
    return (await _prefs).setString(SP_BILLING, encodedData);
  }

  static Future<bool> addBills(List<Billing> billing) async {
    final String encodedData = Billing.encodeList(billing);
    return (await _prefs).setString(SP_BILLING, encodedData);
  }

  static Future<List<Billing>> getBills() async {
    String decodedData = (await _prefs).getString(SP_BILLING) ?? "";
    final List<Billing> decodedRetailer = Billing.decodeList(decodedData);
    return decodedRetailer;
  }

  static Future<bool> clearAllBills() async {
    return (await _prefs).remove(SP_BILLING);
  }

  static Future<bool> setDateTime(String key) async {
    return await (await _prefs).setString(key, DateTime.now().toIso8601String());
  }

  static Future<DateTime> getDateTime(String key) async {
    String? displayString = (await _prefs).getString(key);
    if (displayString == null) {
      var done = await setDateTime(SP_DT_REFRESH);
      if (done)
        displayString = (await _prefs).getString(key);
    }
    return DateTime.parse(displayString!);
  }
}
