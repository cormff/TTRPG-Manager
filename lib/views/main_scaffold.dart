import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/l10n/app_localizations.dart';
import '../providers/user_role_provider.dart';
import '../widgets/custom_drawer.dart';

// GM Ekranları
import 'gm/gm_dashboard.dart';
import 'gm/my_games_gm_view.dart';

// Player Ekranları
import 'player/player_dashboard.dart';
import 'player/my_games_player_view.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRoleProvider = context.watch<UserRoleProvider>();
    final isGM = userRoleProvider.isGameMaster;
    final l10n = AppLocalizations.of(context)!;

    final String username = userRoleProvider.username;

    final String appBarTitle = _selectedIndex == 0
        ? (isGM ? '$username - ${l10n.gmShort}' : '$username - ${l10n.player}')
        : l10n.myGames;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: const CustomDrawer(),
      body: isGM ? const GMDashboard() : const PlayerDashboard(),
    );
  }
}

