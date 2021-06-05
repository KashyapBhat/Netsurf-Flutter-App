import 'dart:async';
import 'package:project_netsurf/common/models/billing.dart';
import 'package:project_netsurf/common/models/customer.dart';
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
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(name);
  }

  static Future<String> getItem(String name) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(name) ?? '';
  }

  static Future<bool> setItem(String name, String value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString(name, value);
  }

  static Future<int> getIntItem(String name) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt(name) ?? '';
  }

  static Future<bool> setIntItem(String name, int value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setInt(name, value);
  }

  static Future<double> getDoubleItem(String name) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getDouble(name) ?? '';
  }

  static Future<bool> setDoubleItem(String name, double value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setDouble(name, value);
  }

  static Future<bool> getBoolItem(String name) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(name) ?? '';
  }

  static Future<bool> setBoolItem(String name, bool value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setBool(name, value);
  }

  static Future<Set<String>> getAll() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getKeys();
  }

  static Future<bool> setListData(String key, List<String> value) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setStringList(key, value);
  }

  Future<List<String>> getListData(String key) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getStringList(key);
  }

  static Future<bool> setProducts(List<Product> products, String name) async {
    final SharedPreferences prefs = await _prefs;
    final String encodedData = Product.encode(products);
    return await prefs.setString(name, encodedData);
  }

  static Future<List<Product>> getProducts(String name) async {
    final SharedPreferences prefs = await _prefs;
    String productsEncoded = prefs.getString(name);
    final List<Product> decodedData = Product.decode(productsEncoded);
    return decodedData;
  }

  static Future<bool> setRetailer(User retailer) async {
    final SharedPreferences prefs = await _prefs;
    final String encodedData = User.encode(retailer);
    return await prefs.setString(SP_RETAILER, encodedData);
  }

  static Future<User> getRetailer() async {
    final SharedPreferences prefs = await _prefs;
    String decodedData = prefs.getString(SP_RETAILER);
    final User decodedRetailer = User.decode(decodedData);
    return decodedRetailer;
  }

  static Future<bool> addBill(Billing billing) async {
    final SharedPreferences prefs = await _prefs;
    List<Billing> bills = [];
    if (!prefs.containsKey(SP_BILLING)) {
      bills.add(billing);
    } else {
      bills = await getBills();
      bills.insert(0, billing);
    }
    final String encodedData = Billing.encodeList(bills);
    return await prefs.setString(SP_BILLING, encodedData);
  }

  static Future<bool> addBills(List<Billing> billing) async {
    final SharedPreferences prefs = await _prefs;
    final String encodedData = Billing.encodeList(billing);
    return await prefs.setString(SP_BILLING, encodedData);
  }

  static Future<List<Billing>> getBills() async {
    final SharedPreferences prefs = await _prefs;
    String decodedData = prefs.getString(SP_BILLING);
    final List<Billing> decodedRetailer = Billing.decodeList(decodedData);
    return decodedRetailer;
  }

  static Future<bool> clearAllBills() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(SP_BILLING);
  }
}
