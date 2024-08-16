import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';

class PasswordProvider with ChangeNotifier {
  List<String> _passwords = [];
  Database? _database;

  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSpecial = true;

  PasswordProvider() {
    _initDatabase();
  }

  List<String> get passwords => _passwords;

  bool get includeUppercase => _includeUppercase;
  bool get includeLowercase => _includeLowercase;
  bool get includeNumbers => _includeNumbers;
  bool get includeSpecial => _includeSpecial;

  void setIncludeUppercase(bool value) {
    _includeUppercase = value;
    notifyListeners();
  }

  void setIncludeLowercase(bool value) {
    _includeLowercase = value;
    notifyListeners();
  }

  void setIncludeNumbers(bool value) {
    _includeNumbers = value;
    notifyListeners();
  }

  void setIncludeSpecial(bool value) {
    _includeSpecial = value;
    notifyListeners();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'passwords.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE passwords(id INTEGER PRIMARY KEY, password TEXT)",
        );
      },
      version: 1,
    );
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final List<Map<String, dynamic>> maps = await _database!.query('passwords');
    _passwords = List.generate(maps.length, (i) {
      return maps[i]['password'];
    });
    notifyListeners();
  }

  Future<void> addPassword(String password) async {
    await _database!.insert(
      'passwords',
      {'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _passwords.add(password);
    notifyListeners();
  }

  Future<void> deletePassword(int index) async {
    String password = _passwords[index];
    await _database!.delete(
      'passwords',
      where: "password = ?",
      whereArgs: [password],
    );
    _passwords.removeAt(index);
    notifyListeners();
  }

  String generatePassword(int length, {bool includeUppercase = true, bool includeLowercase = true, bool includeNumbers = true, bool includeSpecial = true}) {
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String special = '!@#\$%^&*()-_=+[]{}|;:,.<>?';
    String chars = '';
    if (includeUppercase) chars += uppercase;
    if (includeLowercase) chars += lowercase;
    if (includeNumbers) chars += numbers;
    if (includeSpecial) chars += special;
    if (chars.isEmpty) chars = lowercase;
    Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
