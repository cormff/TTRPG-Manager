import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_role_provider.dart';
import '../../providers/games_provider.dart';
import '../../models/game_model.dart';
import '../../views/game/game_details_view.dart';
import '../../views/gm/finished_game_details_view.dart';

class MyGamesGMView extends StatefulWidget {
  const MyGamesGMView({super.key});

  @override
  State<MyGamesGMView> createState() => _MyGamesGMViewState();
}

class _MyGamesGMViewState extends State<MyGamesGMView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserRoleProvider>().userId;
      if (userId != null) {
        // Sayfa açıldığında oyunları çek
        context.read<GamesProvider>().fetchGMGames(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Provider'ı dinliyoruz
    final gamesProvider = context.watch<GamesProvider>();
    // Oyunları en yeniden en eskiye sıralıyoruz
    final games = gamesProvider.gmGames.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Games'),
      ),
      body: gamesProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : games.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
        itemCount: games.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemBuilder: (context, index) {
          final game = games[index];
          return _buildGameTile(game, theme);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () {
          // Geri dönüldüğünde zaten provider kendi kendini güncelliyor
          Navigator.pushNamed(context, '/create_game');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Artık dynamic yerine oluşturduğumuz Game modelini bekliyoruz
  Widget _buildGameTile(Game game, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.casino, color: theme.primaryColor, size: 30),
        ),
        title: Text(
          game.title, // game['title'] yerine game.title
          style: theme.textTheme.titleLarge,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.description.isEmpty ? 'No description...' : game.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: theme.textTheme.bodyMedium?.color),
                  const SizedBox(width: 4),
                  Text(
                    "${game.maxPlayers} Players",
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    game.isPublic ? Icons.public : Icons.lock,
                    size: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    game.isPublic ? 'Public' : 'Private',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: theme.primaryColor),
        onTap: () {
          if (game.isFinished) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FinishedGameDetailsView(game: game)));
          } else {
          // Oyuna tıklandığında GameDetailsView sayfasına yönlendirip, Game objesini yolluyoruz
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailsView(game: game),
            ),
          ); }
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 80, color: theme.hintColor),
          const SizedBox(height: 16),
          Text(
            "No games have been created yet.",
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}