import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/providers/characters_provider.dart';
import 'package:ttrpg_manager/providers/notes_provider.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _selectedLanguage = 'TR';
  bool _isDarkMode = true; // Uygulamanın default temasına göre değiştirebilirsin

  // Önbellek temizleme simülasyonu
  void _clearCache() async {
    // Yükleniyor animasyonu
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Gerçek bir önbellek temizleme işlemi burada yapılabilir (örn: shared_preferences)
    // Şimdilik 1 saniyelik bir bekleme ile siliyormuş gibi yapıyoruz
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context); // Animasyonu kapat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(context.tr('Önbellek başarıyla temizlendi!')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Çıkış yapma fonksiyonu (Çekmece ile birebir aynı mantık)
  void _logout() {
    final userRoleProvider = context.read<UserRoleProvider>();

    // 1. Verileri temizle
    context.read<NotesProvider>().clearData();
    context.read<CharactersProvider>().clearData();

    // 2. Rolü sıfırla ve Login sayfasına dön.
    // pushNamedAndRemoveUntil kullanıyoruz ki geri tuşuna basınca ayarlara geri dönemesin.
    userRoleProvider.setUserRole(UserRole.player);
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // YENİ: Dil yöneticisini dinliyoruz
    final lang = context.watch<LanguageManager>();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('settings')), // YENİ: Çeviri kullanıldı
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
                  Text(
                    lang.translate('language'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    // Mevcut dili provider'dan okuyoruz
                    value: lang.currentLocale.languageCode,
                    underline: const SizedBox(),
                    dropdownColor: theme.cardColor,
                    items: const [
                      DropdownMenuItem(value: LanguageManager.TR, child: Text(context.tr('Türkçe'))),
                      DropdownMenuItem(value: LanguageManager.EN, child: Text(context.tr('English'))),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // Seçilen dili provider üzerinden değiştiriyoruz (Ekran anında güncellenir)
                        context.read<LanguageManager>().changeLanguage(newValue);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- 2. TEMA AYARI ---
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text(
                "Karanlık Tema",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(context.tr('Aydınlık veya karanlık mod')),
              value: _isDarkMode,
              activeColor: theme.primaryColor,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
                // NOT: Gelecekte ThemeProvider eklersen tetikleyiciyi buraya koyacaksın.
              },
            ),
          ),
          const SizedBox(height: 12),

          // --- 3. ÖNBELLEK TEMİZLEME ---
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.orange),
              title: const Text(
                "Önbelleği Temizle",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(context.tr('Geçici verileri siler')),
              onTap: _clearCache,
            ),
          ),

          const SizedBox(height: 40), // Çıkış butonu için biraz boşluk

          // --- 4. ÇIKIŞ YAP (LOGOUT) BUTONU ---
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              "Çıkış Yap",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              // Pat diye çıkmasın, emin misin diye soralım
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: theme.cardColor,
                  title: const Text(context.tr('Çıkış Yap'), style: TextStyle(color: Colors.white)),
                  content: const Text(context.tr('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'), style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(context.tr('İptal'), style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(context.tr('Çıkış Yap'), style: TextStyle(color: Colors.white)),
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