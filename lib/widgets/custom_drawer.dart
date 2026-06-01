import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/providers/characters_provider.dart';
import 'package:ttrpg_manager/providers/notes_provider.dart';
import 'package:ttrpg_manager/providers/language_manager.dart'; // YENİ: Dil yöneticisi eklendi

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
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isGameMaster
                            ? Icons.auto_awesome
                            : Icons.person_outline,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        // YENİ: Başlıklar çeviriye bağlandı
                        isGameMaster ? context.tr('Game Master') : context.tr('Player'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(1),
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
              const Divider(),

              _buildDrawerItem(
                context: context,
                icon: Icons.settings,
                text: context.tr('Settings'), // YENİ: Çeviri
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),

              _buildDrawerItem(
                context: context,
                icon: Icons.logout,
                text: context.tr('Logout'), // YENİ: Çeviri
                onTap: () {
                  Provider.of<NotesProvider>(context, listen: false).clearData();
                  Provider.of<CharactersProvider>(context, listen: false).clearData();
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
        text: context.tr('My Games'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my_games_gm_view');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.add_box,
        text: context.tr('Create Game'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/create_game');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.map,
        text: context.tr('My Maps'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my_maps');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.groups_2,
        text: context.tr("NPCs"), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/characters');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.note,
        text: context.tr('Notes'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/notes');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.book,
        text: context.tr('Rule Books'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/rule_books');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.switch_account,
        text: context.tr('Change to Player View'), // YENİ: Çeviri
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
        text: context.tr('Join Game'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/join_game');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.gamepad,
        text: context.tr('My Games'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my_games_player_view');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.groups,
        text: context.tr('Characters'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/characters');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.note,
        text: context.tr('Notes'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/notes');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.book,
        text: context.tr('Rule Books'), // YENİ: Çeviri
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/rule_books');
        },
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.switch_account,
        text: context.tr('Change to GM View'), // YENİ: Çeviri
        onTap: () {
          userRoleProvider.setUserRole(UserRole.gameMaster);
          Navigator.pop(context);
        },
      ),
    ];
  }

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