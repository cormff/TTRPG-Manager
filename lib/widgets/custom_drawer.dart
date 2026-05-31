import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/l10n/app_localizations.dart';
import 'package:ttrpg_manager/providers/locale_provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/providers/characters_provider.dart';
import 'package:ttrpg_manager/providers/notes_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<UserRoleProvider>(
        builder: (context, userRoleProvider, child) {
          bool isGameMaster = userRoleProvider.isGameMaster;
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SafeArea(
                bottom: false, // Alt tarafta güvenli alan bırakma
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      // Role göre değişen şık bir ikon
                      Icon(
                        isGameMaster
                            ? Icons.auto_awesome
                            : Icons.person_outline,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isGameMaster
                            ? context.tr('gameMaster')
                            : context.tr('player'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              if (isGameMaster)
                ..._buildGMMenuItems(context, userRoleProvider)
              else
                ..._buildPlayerMenuItems(context, userRoleProvider),
              const Divider(),
              _buildLanguageSelector(context),
              _buildDrawerItem(
                context: context,
                icon: Icons.logout,
                text: context.tr('logout'),
                onTap: () {
                  // 1. Önce eski kullanıcının notlarını RAM'den (hafızadan) temizliyoruz
                  Provider.of<NotesProvider>(
                    context,
                    listen: false,
                  ).clearData();
                  Provider.of<CharactersProvider>(
                    context,
                    listen: false,
                  ).clearData();

                  // 2. Rolü sıfırlayıp Login sayfasına geri dönüyoruz
                  userRoleProvider.setUserRole(UserRole.player);
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildGMMenuItems(
    BuildContext context,
    UserRoleProvider userRoleProvider,
  ) {
    return [
      _buildDrawerItem(
        context: context,
        icon: Icons.gamepad,
        text: context.tr('myGames'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my_games_gm_view');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.add_box,
        text: context.tr('createGame'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/create_game');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.map,
        text: context.tr('myMaps'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my_maps');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.groups_2,
        text: context.tr('npcs'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/characters');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.note,
        text: context.tr('notes'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/notes');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.book,
        text: context.tr('ruleBooks'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/rule_books');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.switch_account,
        text: context.tr('changeToPlayerView'),
        onTap: () {
          userRoleProvider.setUserRole(UserRole.player);
          Navigator.pop(context);
        },
      ),
    ];
  }

  List<Widget> _buildPlayerMenuItems(
    BuildContext context,
    UserRoleProvider userRoleProvider,
  ) {
    return [
      _buildDrawerItem(
        context: context,
        icon: Icons.group_add,
        text: context.tr('joinGame'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/join_game');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.gamepad,
        text: context.tr('myGames'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my_games_player_view');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.groups,
        text: context.tr('characters'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/characters');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.note,
        text: context.tr('notes'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/notes');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.book,
        text: context.tr('ruleBooks'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/rule_books');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.switch_account,
        text: context.tr('changeToGmView'),
        onTap: () {
          userRoleProvider.setUserRole(UserRole.gameMaster);
          Navigator.pop(context);
        },
      ),
    ];
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return ListTile(
      leading: Icon(
        Icons.language,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        context.tr('language'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: localeProvider.locale.languageCode,
          dropdownColor: Theme.of(context).cardColor,
          items: [
            DropdownMenuItem(
              value: 'en',
              child: Text(context.tr('language.english')),
            ),
            DropdownMenuItem(
              value: 'tr',
              child: Text(context.tr('language.turkish')),
            ),
          ],
          onChanged: (languageCode) {
            if (languageCode == null) return;
            localeProvider.setLocale(Locale(languageCode));
          },
        ),
      ),
    );
  }

  // DÜZELTİLEN METOT: BuildContext parametre olarak eklendi
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(text, style: Theme.of(context).textTheme.titleLarge),
      onTap: onTap,
    );
  }
}
