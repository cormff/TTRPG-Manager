import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_role_provider.dart';
import '../widgets/custom_drawer.dart';

// GM Ekranları
import 'gm/gm_dashboard.dart';

// Player Ekranları
import 'player/player_dashboard.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    final userRoleProvider = context.watch<UserRoleProvider>();
    final isGM = userRoleProvider.isGameMaster;

    final String username = Provider.of<UserRoleProvider>(context).username;

    final String appBarTitle = isGM
        ? '$username - GM'
        : '$username - ${context.tr('player')}';

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
