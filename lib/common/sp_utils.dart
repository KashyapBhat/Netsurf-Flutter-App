import 'dart:async';
import 'dart:convert';

import 'package:project_netsurf/common/sp_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/product.dart';

class Preference {
  Preference._();

  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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

  static Future<bool> setProducts(List<Product> products) async {
    final SharedPreferences prefs = await _prefs;
    final String encodedData = Product.encode(products);
    return await prefs.setString(SP_PRODUCTS, encodedData);
  }

  static Future<List<Product>> getProducts() async {
    final SharedPreferences prefs = await _prefs;
    String productsEncoded = prefs.getString(SP_PRODUCTS);
    final List<Product> decodedData = Product.decode(productsEncoded);
    return decodedData;
  }
}
