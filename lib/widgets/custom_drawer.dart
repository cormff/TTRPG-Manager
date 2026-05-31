import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/providers/characters_provider.dart';
import 'package:ttrpg_manager/providers/notes_provider.dart';
import 'package:ttrpg_manager/providers/language_provider.dart';
import 'package:ttrpg_manager/l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                        isGameMaster ? l10n.gameMaster : l10n.player,
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
              _buildDrawerItem(
                context: context,
                icon: Icons.language,
                text: l10n.language,
                trailing: Consumer<LanguageProvider>(
                  builder: (context, langProvider, child) {
                    return Text(
                      langProvider.locale.languageCode.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
                onTap: () {
                  Provider.of<LanguageProvider>(context, listen: false).toggleLanguage();
                },
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.logout,
                text: l10n.logout,
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
    final l10n = AppLocalizations.of(context)!;
    return [
      _buildDrawerItem(
        context: context,
        icon: Icons.gamepad,
        text: l10n.myGames,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my_games_gm_view');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.add_box,
        text: l10n.createGame,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/create_game');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.map,
        text: l10n.myMaps,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my_maps');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.groups_2,
        text: l10n.npcs,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/characters');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.note,
        text: l10n.notes,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/notes');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.book,
        text: l10n.ruleBooks,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/rule_books');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.switch_account,
        text: l10n.changeToPlayerView,
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
    final l10n = AppLocalizations.of(context)!;
    return [
      _buildDrawerItem(
        context: context,
        icon: Icons.group_add,
        text: l10n.joinGame,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/join_game');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.gamepad,
        text: l10n.myGames,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my_games_player_view');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.groups,
        text: l10n.characters,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/characters');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.note,
        text: l10n.notes,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/notes');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.book,
        text: l10n.ruleBooks,
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/rule_books');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.switch_account,
        text: l10n.changeToGMView,
        onTap: () {
          userRoleProvider.setUserRole(UserRole.gameMaster);
          Navigator.pop(context);
        },
      ),
    ];
  }

  // DÜZELTİLEN METOT: BuildContext parametre olarak eklendi
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(text, style: Theme.of(context).textTheme.titleLarge),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

