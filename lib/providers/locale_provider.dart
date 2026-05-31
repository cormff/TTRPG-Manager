import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttrpg_manager/l10n/app_localizations.dart';

class LocaleProvider with ChangeNotifier {
  LocaleProvider() {
    _loadSavedLocale();
  }

  static const _localeKey = 'selected_language_code';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale)) return;

    _locale = Locale(locale.languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localeKey);
    final platformCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final languageCode =
        savedCode ?? (_isSupported(Locale(platformCode)) ? platformCode : 'en');

    _locale = Locale(languageCode);
    notifyListeners();
  }

  bool _isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }
}
