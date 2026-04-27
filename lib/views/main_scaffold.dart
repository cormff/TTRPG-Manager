import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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


    final List<Widget> gmScreens = [
      const GMDashboard(),
      const MyGamesGMView(),
    ];


    final List<Widget> playerScreens = [
      const PlayerDashboard(),
      const MyGamesPlayerView(),
    ];


    final String username = Provider.of<UserRoleProvider>(context).username;

    final String appBarTitle = _selectedIndex == 0
        ? (isGM ? '$username - GM' : '$username - Player')
        : 'My Games';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: const CustomDrawer(),

      body: isGM ? gmScreens[_selectedIndex] : playerScreens[_selectedIndex],


      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'My Games',
          ),
        ],
      ),
    );
  }
}