import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class LanguageManager with ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  Locale _currentLocale = const Locale('tr', 'TR');
  Locale get currentLocale => _currentLocale;

  static const String TR = 'tr';
  static const String EN = 'en';

  // --- TTRPG UYGULAMASI İÇİN ÇEVİRİ SÖZLÜĞÜ ---
  final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      'settings': 'Ayarlar',
      'language': 'Dil',
      'dark_mode': 'Tema',
      'dark_mode_desc': 'Aydınlık veya karanlık mod',
      'clear_cache': 'Önbelleği Temizle',
      'clear_cache_desc': 'Geçici verileri siler',
      'logout': 'Çıkış Yap',
      'logout_confirm_title': 'Çıkış Yap',
      'logout_confirm_msg': 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
      'cancel': 'İptal',
      'yes_logout': 'Evet, Çıkış Yap',
      'cache_cleared': 'Önbellek başarıyla temizlendi!',
      // İleride buraya oyunlar, notlar vb. eklenecek
      'my_games': 'Oyunlarım',
      'notes': 'Notlar',
      'characters': 'Karakterler',
      'rule_books': 'Kurallı Kitaplar',
      'join_game': 'Oyuna Katıl',
      'create_game': 'Oyun Oluştur',
      'my_maps': 'Haritalarım',
      'my_characters': 'Karakterlerim',
      'my_notes': 'Notlarım',

    },
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'dark_mode_desc': 'Light or dark mode',
      'clear_cache': 'Clear Cache',
      'clear_cache_desc': 'Deletes temporary data',
      'logout': 'Logout',
      'logout_confirm_title': 'Logout',
      'logout_confirm_msg': 'Are you sure you want to logout from your account?',
      'cancel': 'Cancel',
      'yes_logout': 'Yes, Logout',
      'cache_cleared': 'Cache successfully cleared!',
      // İleride buraya oyunlar, notlar vb. eklenecek
      'my_games': 'My Games',
      'notes': 'Notes',
      'characters': 'Characters',
      'rule_books': 'Rule Books',
      'join_game': 'Join Game',
      'create_game': 'Create Game',
      'my_maps': 'My Maps',
      'my_characters': 'My Characters',
      'my_notes': 'My Notes',
    },
  };

  String translate(String key) {
    return _localizedValues[_currentLocale.languageCode]?[key] ?? key;
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? TR;
    _currentLocale = Locale(langCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String langCode) async {
    _currentLocale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    notifyListeners();
  }
}

extension LocalizationExtension on BuildContext {
  // context.tr('key') yazarak çeviriyi anında almamızı sağlar
  String tr(String key) => watch<LanguageManager>().translate(key);
}