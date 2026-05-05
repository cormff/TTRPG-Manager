// lib/views/player/my_games_player_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/games_provider.dart';
import '../../providers/user_role_provider.dart';
import 'player_game_details_view.dart';

class MyGamesPlayerView extends StatefulWidget {
  const MyGamesPlayerView({super.key});

  @override
  State<MyGamesPlayerView> createState() => _MyGamesPlayerViewState();
}

class _MyGamesPlayerViewState extends State<MyGamesPlayerView> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında oyuncunun katıldığı oyunları çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserRoleProvider>().userId;
      if (userId != null) {
        context.read<GamesProvider>().fetchPlayerGames(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamesProvider = context.watch<GamesProvider>();
    final myGames = gamesProvider.playerGames.reversed.toList();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Joined Games'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: gamesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : myGames.isEmpty
          ? const Center(
        child: Text(
          'You have not joined any games yet.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myGames.length,
        itemBuilder: (context, index) {
          final game = myGames[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: theme.cardColor,
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.casino, color: theme.primaryColorLight),
              ),
              title: Text(
                game.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                "${game.joinedPlayerIds.length} / ${game.maxPlayers} Players",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
              onTap: () {
                // Oyuncuyu detay sayfasına yönlendiriyoruz
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerGameDetailsView(game: game),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}