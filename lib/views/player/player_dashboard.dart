import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_role_provider.dart';
import '../../providers/notes_provider.dart';

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
      final userRoleProvider = context.read<UserRoleProvider>();
      final userId = userRoleProvider.userId;

      if (userId != null && notesProvider.playerNotes.isEmpty) {
        notesProvider.fetchAllNotes(userId);
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
        // Navigator.pushNamed(context, route);
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
    final notesProvider = context.watch<NotesProvider>();
    final allPlayerNotes = notesProvider.playerNotes.reversed.toList();
    final displayNotes = allPlayerNotes.take(5).toList();

    final int dummyGamesCount = 2;
    final int dummyCharactersCount = 8;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Son Oyunlar"),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (dummyGamesCount > 4 ? 4 : dummyGamesCount) + 1,
                  itemBuilder: (context, index) {
                    int maxItems = dummyGamesCount > 4 ? 4 : dummyGamesCount;
                    if (index == maxItems) return _buildViewMoreButton("/my_games_player_view");

                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.casino, color: Theme.of(context).primaryColor, size: 32),
                          const SizedBox(height: 8),
                          Text("Oyun ${dummyGamesCount - index}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionHeader("Karakterlerim"),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (dummyCharactersCount > 6 ? 6 : dummyCharactersCount) + 1,
                  itemBuilder: (context, index) {
                    int maxItems = dummyCharactersCount > 6 ? 6 : dummyCharactersCount;
                    if (index == maxItems) return _buildViewMoreButton("/characters");

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                      ),
                      child: Center(child: Icon(Icons.person_outline, color: Colors.grey[500], size: 40)),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

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
                    margin: const EdgeInsets.only(bottom: 10), // Boşluğu kıstık
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      // GM ekranındaki gibi kompakt hale getirdik
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: _getTagColor(safeTag).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Icon(_getTagIcon(safeTag), color: _getTagColor(safeTag)),
                      ),
                      title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2), // Başlık ile metin arası
                          Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                          if (displayTag.isNotEmpty) ...[
                            const SizedBox(height: 4), // Metin ile tag arası
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