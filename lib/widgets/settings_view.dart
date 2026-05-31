import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/providers/characters_provider.dart';
import 'package:ttrpg_manager/providers/notes_provider.dart';
import 'package:ttrpg_manager/providers/language_manager.dart'; // Bu import çok önemli
import 'package:ttrpg_manager/providers/theme_provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // YENİ: _selectedLanguage değişkenini sildik çünkü veriyi direkt Provider'dan alacağız
  bool _isDarkMode = true;

  void _clearCache() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Önbellek başarıyla temizlendi!')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _logout() {
    final userRoleProvider = context.read<UserRoleProvider>();
    context.read<NotesProvider>().clearData();
    context.read<CharactersProvider>().clearData();
    userRoleProvider.setUserRole(UserRole.player);
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ÇÖZÜM BURASI: Provider'ı dinlemeye başlıyoruz
    final langManager = context.watch<LanguageManager>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Ayarlar')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- 1. DİL AYARI ---
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.tr("Dil / Language"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    // O anki dili Provider'dan çekiyoruz ('tr' ise 'TR', değilse 'EN' göster)
                    value: langManager.currentLocale.languageCode == 'tr' ? 'TR' : 'EN',
                    underline: const SizedBox(),
                    dropdownColor: theme.cardColor,
                    items: [
                      DropdownMenuItem(value: 'TR', child: Text(context.tr('Türkçe'))),
                      DropdownMenuItem(value: 'EN', child: Text(context.tr('English'))),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // Yeni dili Provider'a ve hafızaya kaydediyoruz (Anında tüm UI değişir)
                        String langCode = newValue == 'TR' ? LanguageManager.TR : LanguageManager.EN;
                        context.read<LanguageManager>().changeLanguage(langCode);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- 2. TEMA AYARI ---
// --- 2. TEMA AYARI ---
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: Text(
                context.tr("Karanlık Tema"), // Çevirimizi de unutmadık
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(context.tr('Aydınlık veya karanlık mod')),

              // Değeri artık kendi yazdığımız provider'dan okuyor
              value: context.watch<ThemeProvider>().isDarkMode,

              activeColor: theme.primaryColor,
              onChanged: (bool value) {
                // Düğmeye basıldığında Provider'a 'değiştir ve kaydet' komutu yolluyor
                context.read<ThemeProvider>().toggleTheme(value);
              },
            ),
          ),
          const SizedBox(height: 12),

          // --- 3. ÖNBELLEK TEMİZLEME ---
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading:  Icon(Icons.delete_sweep, color: Colors.orange),
              title: Text(context.tr(
                "Önbelleği Temizle"), // İstersen burayı da çeviriye dahil et
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(context.tr('Geçici verileri siler')),
              onTap: _clearCache,
            ),
          ),

          const SizedBox(height: 40),

          // --- 4. ÇIKIŞ YAP (LOGOUT) BUTONU ---
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout),
            label: Text(
              context.tr('Çıkış Yap'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: theme.cardColor,
                  title: Text(context.tr('Çıkış Yap'), style: const TextStyle(color: Colors.white)),
                  content: Text(context.tr('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'), style: const TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.tr('İptal'), style: const TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(context.tr('Çıkış Yap'), style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                _logout();
              }
            },
          ),
        ],
      ),
    );
  }
}