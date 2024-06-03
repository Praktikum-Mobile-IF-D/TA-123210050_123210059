import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wizardingworld/models/user_model.dart';

class HiveDatabase {
  static late Box<User> _userBox;
  static late Box<String> _favoriteBox; // Menggunakan Box<String> untuk menyimpan ID favorit

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    _userBox = await Hive.openBox<User>('users');
    _favoriteBox = await Hive.openBox<String>('favorites'); // Menggunakan Box<String> untuk menyimpan ID favorit
  }

  static Future<void> addUser(User user) async {
    await _userBox.put(user.email, user);
  }

  static User? getUser(String email) {
    return _userBox.get(email);
  }

  static Future<String?> getCurrentUserEmail() async {
    var users = await _userBox.values.toList();
    if (users.isNotEmpty) {
      return users[0].email;
    } else {
      return null;
    }
  }

  static Future<void> addFavorite(String email, String potionId) async {
    await _favoriteBox.put(email, potionId); // Menyimpan ID favorit menggunakan email sebagai kunci
  }

  static Future<void> removeFavorite(String email, String potionId) async {
    await _favoriteBox.delete(email); // Menghapus ID favorit menggunakan email sebagai kunci
  }

  static Future<List<String>> getFavorites(String email) async {
    List<String> favorites = _favoriteBox.values.where((id) => id == email).toList();
    return favorites; // Mengambil daftar ID potion favorit
  }

  static Future<dynamic> getPotionById(String id) async {
    // Implementasi untuk mendapatkan data potion dari Hive berdasarkan ID
    // Di sini kita akan menggunakan Hive untuk mendapatkan data potion dari box yang sesuai
    var box = await Hive.openBox('potions'); // Misalkan box untuk menyimpan data potion bernama 'potions'
    return box.get(id); // Mengambil data potion dari box berdasarkan ID
  }
}