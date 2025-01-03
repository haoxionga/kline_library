// Copyright 2024 Andy.Zhao
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class CacheUtil {
  CacheUtil._internal();
  factory CacheUtil() => _instance;
  static final CacheUtil _instance = CacheUtil._internal();
  static CacheUtil get instance => _instance;

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> clear() {
    return _prefs.clear();
  }

  bool contains(String key) {
    return _prefs.containsKey(key);
  }

  Future<bool> remove(String key) {
    return _prefs.remove(key);
  }

  T? get<T>(String key, {T? def}) {
    return _prefs.get(key) as T? ?? def;
  }

  Future<bool> set<T>(String key, T value) {
    if (value is String) {
      return setString(key, value);
    } else if (value is double) {
      return setDouble(key, value);
    } else if (value is int) {
      return setInt(key, value);
    } else if (value is bool) {
      return setBool(key, value);
    } else if (value is List<String>) {
      return setStringList(key, value);
    } else {
      return setModel(key, value);
    }
  }

  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  Future<bool> setDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }

  Future<bool> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  Future<bool> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  List<String> getStringList(
    String key, {
    List<String> def = const [],
  }) {
    return _prefs.getStringList(key) ?? def;
  }


  Future<bool> setModel<T>(String key, T data) {
    final jsonSrc = jsonEncode(data);
    return setString(key, jsonSrc);
  }


}
