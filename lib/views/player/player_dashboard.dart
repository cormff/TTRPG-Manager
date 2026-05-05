import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_role_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/games_provider.dart'; // YENİ: GamesProvider eklendi
import '../../providers/characters_provider.dart';
import 'player_game_details_view.dart'; // YENİ: Oyuna tıklayınca detaylara gitmesi için (Dosya yolunu gerekirse kendi yapına göre ayarla)

class PlayerDashboard extends StatefulWidget {
  const PlayerDashboard({super.key});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notesProvider = context.read<NotesProvider>();
      final gamesProvider = context.read<GamesProvider>(); // YENİ
      final charactersProvider = context.read<CharactersProvider>();
      final userRoleProvider = context.read<UserRoleProvider>();
      final userId = userRoleProvider.userId;

      if (userId != null) {
        if (notesProvider.playerNotes.isEmpty) {
          notesProvider.fetchAllNotes(userId);
        }
        // YENİ: Oyuncunun katıldığı oyunları çek
        if (gamesProvider.playerGames.isEmpty) {
          gamesProvider.fetchPlayerGames(userId);
        }
        if (charactersProvider.playerCharacters.isEmpty) {
          charactersProvider.fetchPlayerCharacters(userId);
        }
      }
    });
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'NPC':
        return Colors.blue;
      case 'Quest':
        return Colors.amber;
      case 'Loot':
        return Colors.green;
      case 'Location':
        return Colors.purple;
      case 'Combat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTagIcon(String tag) {
    switch (tag) {
      case 'NPC':
        return Icons.person;
      case 'Quest':
        return Icons.explore;
      case 'Loot':
        return Icons.diamond;
      case 'Location':
        return Icons.location_on;
      case 'Combat':
        return Icons.shield;
      default:
        return Icons.bookmark;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildViewMoreButton(String route) {
    return GestureDetector(
      onTap: () {
        // YENİ: Yorum satırı açıldı, artık yönlendirme çalışacak
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final allPlayerNotes = notesProvider.playerNotes.reversed.toList();
    final displayNotes = allPlayerNotes.take(5).toList();

    // YENİ: Oyunları Dinle
    final gamesProvider = context.watch<GamesProvider>();
    final allPlayerGames = gamesProvider.playerGames.reversed.toList();

    final charactersProvider = context.watch<CharactersProvider>();
    final allCharacters = charactersProvider.playerCharacters.reversed.toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. OYUNLAR KISMI ---
              _buildSectionHeader("Son Oyunlar"),
              const SizedBox(height: 8),

              gamesProvider.isLoading
                  ? const SizedBox(
                      height: 110,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SizedBox(
                      height: 110,
                      child: allPlayerGames.isEmpty
                          ? const Center(
                              child: Text(
                                "Henüz bir oyuna katılmadın.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  (allPlayerGames.length > 4
                                      ? 4
                                      : allPlayerGames.length) +
                                  1,
                              itemBuilder: (context, index) {
                                int displayCount = allPlayerGames.length > 4
                                    ? 4
                                    : allPlayerGames.length;

                                // Listenin sonuna gelindiyse ok tuşunu göster
                                if (index == displayCount)
                                  return _buildViewMoreButton(
                                    "/my_games_player_view",
                                  );

                                final game = allPlayerGames[index];

                                return GestureDetector(
                                  onTap: () {
                                    // Oyuna tıklanınca detay sayfasına gönder (Harita, hikaye vs.)
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlayerGameDetailsView(game: game),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 150,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context).cardColor,
                                          Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.casino,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            game.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${game.joinedPlayerIds.length} / ${game.maxPlayers} Oyuncu",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

              const SizedBox(height: 24),

              _buildSectionHeader("Karakterlerim"),
              const SizedBox(height: 8),
              charactersProvider.isLoading
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SizedBox(
                      height: 100,
                      child: allCharacters.isEmpty
                          ? const Center(
                              child: Text(
                                "Henüz karakter eklenmemiş.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  (allCharacters.length > 6
                                      ? 6
                                      : allCharacters.length) +
                                  1,
                              itemBuilder: (context, index) {
                                int maxItems = allCharacters.length > 6
                                    ? 6
                                    : allCharacters.length;
                                if (index == maxItems)
                                  return _buildViewMoreButton("/characters");

                                final character = allCharacters[index];
                                return Container(
                                  width: 90,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (character.avatarUrl.isNotEmpty)
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundImage: AssetImage(character.avatarUrl),
                                        )
                                      else
                                        Icon(
                                          Icons.person_outline,
                                          color: Colors.grey[400],
                                          size: 30,
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        character.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Lv.${character.level}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

              const SizedBox(height: 24),

              _buildSectionHeader("Son Notlar"),
              const SizedBox(height: 8),

              notesProvider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : displayNotes.isEmpty
                  ? const Center(
                      child: Text(
                        "Henüz hiç not eklenmemiş.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayNotes.length,
                      itemBuilder: (context, index) {
                        final note = displayNotes[index];
                        final safeTag = note.tag ?? '';
                        final String displayTag = note.tag != null
                            ? (note.subTag != null && note.subTag!.isNotEmpty
                                  ? '${note.tag} • ${note.subTag}'
                                  : note.tag!)
                            : '';

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ), // Boşluğu kıstık
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            // GM ekranındaki gibi kompakt hale getirdik
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getTagColor(safeTag).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getTagIcon(safeTag),
                                color: _getTagColor(safeTag),
                              ),
                            ),
                            title: Text(
                              note.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 2,
                                ), // Başlık ile metin arası
                                Text(
                                  note.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13,
                                  ),
                                ),
                                if (displayTag.isNotEmpty) ...[
                                  const SizedBox(
                                    height: 4,
                                  ), // Metin ile tag arası
                                  Text(
                                    displayTag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(
                                        context,
                                      ).primaryColorLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, "/notes"),
                    icon: const Icon(Icons.arrow_circle_right_outlined),
                    label: const Text("Tüm Notları Gör"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
