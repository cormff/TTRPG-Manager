import 'package:flutter/material.dart';
import '../../services/game_service.dart';
import 'package:provider/provider.dart';
import '../../providers/user_role_provider.dart';

class MyGamesGMView extends StatefulWidget {
  const MyGamesGMView({super.key});

  @override
  State<MyGamesGMView> createState() => _MyGamesGMViewState();
}

class _MyGamesGMViewState extends State<MyGamesGMView> {
  final GameService _gameService = GameService();

  Future<void> _refreshGames() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Güncel kullanıcının ID'sini çekiyoruz
    final currentUserId = context.watch<UserRoleProvider>().userId;

    return Scaffold(
      // backgroundColor: Colors.black KALDIRILDI! Artık app_theme.dart içindeki scaffoldBackgroundColor (grey[900]) geçerli.
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Oyunlarım'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGames,
        color: theme.primaryColor,
        backgroundColor: theme.scaffoldBackgroundColor,
        child: FutureBuilder<List<dynamic>>(
          future: _gameService.getMyGames(currentUserId ?? 0),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: theme.primaryColor),
              );
            } else if (snapshot.hasError) {
              return _buildErrorState(theme);
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(theme);
            }

            final games = snapshot.data!;

            return ListView.builder(
              itemCount: games.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemBuilder: (context, index) {
                final game = games[index];
                return _buildGameTile(game, theme);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/create_game').then((_) => _refreshGames());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGameTile(dynamic game, ThemeData theme) {
    final bool isGamePublic = game['isPublic'] ?? game['public'] ?? false;

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
          game['title'] ?? 'Adsız Macera',
          style: theme.textTheme.titleLarge,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game['description'] ?? 'Açıklama yok...',
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
                    "${game['maxPlayers']} Oyuncu",
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isGamePublic ? Icons.public : Icons.lock,
                    size: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isGamePublic ? 'Herkese Açık' : 'Özel',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: theme.primaryColor),
        onTap: () {
          // TODO: Oyun detay sayfasına yönlendirilecek
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
            "Henüz bir dünya oluşturmadınız.",
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Text(
        "Veriler çekilirken bir hata oluştu.\nSunucuyu kontrol edin.",
        textAlign: TextAlign.center,
        style: TextStyle(color: theme.colorScheme.error),
      ),
    );
  }
}