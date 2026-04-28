import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_role_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/games_provider.dart'; // YENİ: GamesProvider eklendi

class GMDashboard extends StatefulWidget {
  const GMDashboard({super.key});

  @override
  State<GMDashboard> createState() => _GMDashboardState();
}

class _GMDashboardState extends State<GMDashboard> {
  // ESKİ gameService ve yerel _games listesi TAMAMEN SİLİNDİ!

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userRoleProvider = context.read<UserRoleProvider>();
      final userId = userRoleProvider.userId;

      if (userId != null) {
        // Notları çek
        final notesProvider = context.read<NotesProvider>();
        if (notesProvider.gmNotes.isEmpty) {
          notesProvider.fetchAllNotes(userId);
        }

        // Oyunları çek (GamesProvider üzerinden)
        final gamesProvider = context.read<GamesProvider>();
        if (gamesProvider.gmGames.isEmpty) {
          gamesProvider.fetchGMGames(userId);
        }
      }
    });
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'NPC': return Colors.blue;
      case 'Quest': return Colors.amber;
      case 'Loot': return Colors.green;
      case 'Location': return Colors.purple;
      case 'Combat': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getTagIcon(String tag) {
    switch (tag) {
      case 'NPC': return Icons.person;
      case 'Quest': return Icons.explore;
      case 'Loot': return Icons.diamond;
      case 'Location': return Icons.location_on;
      case 'Combat': return Icons.shield;
      default: return Icons.bookmark;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildViewMoreButton(String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Notları Dinle
    final notesProvider = context.watch<NotesProvider>();
    final allGmNotes = notesProvider.gmNotes.reversed.toList();
    final displayNotes = allGmNotes.take(5).toList();

    // 2. Oyunları Dinle (YENİ)
    final gamesProvider = context.watch<GamesProvider>();
    final allGmGames = gamesProvider.gmGames.reversed.toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. OYUNLAR KISMI ---
              _buildSectionHeader("Oyunlar"),
              const SizedBox(height: 8),
              gamesProvider.isLoading
                  ? const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()))
                  : SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  // Limit 4, butonu göstermek için +1 ekliyoruz
                  itemCount: (allGmGames.length > 4 ? 4 : allGmGames.length) + 1,
                  itemBuilder: (context, index) {
                    int displayCount = allGmGames.length > 4 ? 4 : allGmGames.length;

                    if (index == displayCount) return _buildViewMoreButton("/my_games_gm_view");

                    // Artık 'game' değişkeni ham JSON değil, harika Game modelimiz!
                    final game = allGmGames[index];

                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Theme.of(context).cardColor, Theme.of(context).primaryColor.withOpacity(0.1)],
                        ),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.casino, color: Theme.of(context).primaryColor, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              game.title, // YENİ: game['title'] yerine game.title
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text("${game.maxPlayers} Oyuncu", style: TextStyle(fontSize: 11, color: Colors.grey[400])), // YENİ: game.maxPlayers
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // --- 2. KARAKTERLER KISMI ---
              _buildSectionHeader("Karakterler"),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildViewMoreButton("/characters");
                    return const SizedBox();
                  },
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. HARİTALAR KISMI ---
              _buildSectionHeader("Haritalar"),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildViewMoreButton("/my_maps");
                    return const SizedBox();
                  },
                ),
              ),

              const SizedBox(height: 24),

              // --- 4. NOTLAR KISMI ---
              _buildSectionHeader("Son Notlar"),
              const SizedBox(height: 8),

              notesProvider.isLoading
                  ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                  : displayNotes.isEmpty
                  ? const Center(child: Text("Henüz hiç not eklenmemiş.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayNotes.length,
                itemBuilder: (context, index) {
                  final note = displayNotes[index];
                  final safeTag = note.tag ?? '';
                  final String displayTag = note.tag != null
                      ? (note.subTag != null && note.subTag!.isNotEmpty ? '${note.tag} • ${note.subTag}' : note.tag!)
                      : '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getTagColor(safeTag).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getTagIcon(safeTag), color: _getTagColor(safeTag)),
                      ),
                      title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                          if (displayTag.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(displayTag, style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColorLight, fontWeight: FontWeight.bold)),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, "/notes");
                    },
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