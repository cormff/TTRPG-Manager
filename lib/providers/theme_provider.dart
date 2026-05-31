import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // FRP uygulaması olduğu için varsayılan olarak Karanlık (true) başlatmak mantıklı
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme(); // Sınıf çağırıldığında kayıtlı temayı yükle
  }

  // Hafızadan okuma
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Hafızada 'isDarkMode' yoksa varsayılan olarak true döner
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  // Temayı değiştirme ve hafızaya kaydetme
  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    notifyListeners(); // Tüm uygulamayı anında yeniler
  }
}