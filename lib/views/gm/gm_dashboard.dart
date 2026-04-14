import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';

class GMDashboard extends StatelessWidget {
  const GMDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userRoleProvider = Provider.of<UserRoleProvider>(context);

    // Scaffold ve AppBar KALDARILDI, sadece içerik (body) döndürülüyor
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, Game Master!',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              userRoleProvider.setUserRole(UserRole.player);
            },
            child: const Text('Switch to Player View'),
          ),
        ],
      ),
    );
  }
}