import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/widgets/custom_drawer.dart';
import 'package:ttrpg_manager/views/gm/gm_dashboard.dart';
import 'package:ttrpg_manager/views/player/player_dashboard.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserRoleProvider>(
      builder: (context, userRoleProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(userRoleProvider.isGameMaster ? 'GM Dashboard' : 'Player Dashboard'),
          ),
          drawer: const CustomDrawer(),
          body: userRoleProvider.isGameMaster ? const GMDashboard() : const PlayerDashboard(),
        );
      },
    );
  }
}