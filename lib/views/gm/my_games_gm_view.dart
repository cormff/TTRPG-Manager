import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_role_provider.dart';
import '../../providers/games_provider.dart';
import '../../models/game_model.dart';
import '../../views/game/game_details_view.dart';
import '../../views/gm/finished_game_details_view.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';

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
        title: Text(context.tr('My Games')),
      ),
      body: gamesProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : games.isEmpty
          ? _buildEmptyState(context, theme) // Context eklendi
          : ListView.builder(
        itemCount: games.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemBuilder: (context, index) {
          final game = games[index];
          return _buildGameTile(context, game, theme); // Context eklendi
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

  // Context parametresi eklendi
  Widget _buildGameTile(BuildContext context, Game game, ThemeData theme) {
    final textColor = theme.colorScheme.onSurface;

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
          game.title,
          style: theme.textTheme.titleLarge,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.description.isEmpty ? context.tr('No description...') : game.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 14, color: textColor.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Text(
                    "${game.maxPlayers} ${context.tr('Players')}",
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: textColor.withOpacity(0.6)),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    game.isPublic ? Icons.public : Icons.lock,
                    size: 14,
                    color: textColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    game.isPublic ? context.tr('Public') : context.tr('Private'),
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, color: textColor.withOpacity(0.6)),
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

  // Context parametresi eklendi
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            context.tr('No games have been created yet.'),
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}