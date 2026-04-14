import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';

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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Row(
                    children: [
                      // Role göre değişen şık bir ikon
                      Icon(
                        isGameMaster ? Icons.auto_awesome : Icons.person_outline,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isGameMaster ? 'Game Master' : 'Player',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                icon: Icons.logout,
                text: 'Logout',
                onTap: () {
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

  List<Widget> _buildGMMenuItems(BuildContext context, UserRoleProvider userRoleProvider) {
    return [
      _buildDrawerItem(context: context, icon: Icons.gamepad, text: 'My Games', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/my_games');
      }),
      _buildDrawerItem(context: context, icon: Icons.add_box, text: 'Create Game', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/create_game');
      }),
      _buildDrawerItem(context: context, icon: Icons.map, text: 'My Maps', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/my_maps');
      }),
      _buildDrawerItem(context: context, icon: Icons.note, text: 'Notes', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/notes');
      }),
      _buildDrawerItem(context: context, icon: Icons.book, text: 'Rule Books', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/rule_books');
      }),
      _buildDrawerItem(
        context: context,
        icon: Icons.switch_account,
        text: 'Change to Player View',
        onTap: () {
          userRoleProvider.setUserRole(UserRole.player);
          Navigator.pop(context);
        },
      ),
    ];
  }

  List<Widget> _buildPlayerMenuItems(BuildContext context, UserRoleProvider userRoleProvider) {
    return [
      _buildDrawerItem(context: context, icon: Icons.group_add, text: 'Join Game', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/join_game');
      }),
      _buildDrawerItem(context: context, icon: Icons.gamepad, text: 'My Games', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/my_games');
      }),
      _buildDrawerItem(context: context, icon: Icons.note, text: 'Notes', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/notes');
      }),
      _buildDrawerItem(context: context, icon: Icons.book, text: 'Rule Books', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/rule_books');
      }),
      _buildDrawerItem(
        context: context,
        icon: Icons.switch_account,
        text: 'Change to GM View',
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
    required VoidCallback onTap
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(text, style: Theme.of(context).textTheme.titleLarge),
      onTap: onTap,
    );
  }
}