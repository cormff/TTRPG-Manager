import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_role_provider.dart';
import '../../providers/notes_provider.dart';

class GMDashboard extends StatefulWidget {
  const GMDashboard({super.key});

  @override
  State<GMDashboard> createState() => _GMDashboardState();
}

class _GMDashboardState extends State<GMDashboard> {
  @override
  void initState() {
    super.initState();
    // Dashboard açıldığında notları çekelim (eğer boşsa)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notesProvider = context.read<NotesProvider>();
      final userRoleProvider = context.read<UserRoleProvider>();
      final userId = userRoleProvider.userId;

      if (userId != null && notesProvider.gmNotes.isEmpty) {
        notesProvider.fetchAllNotes(userId);
      }
    });
  }

  // --- Kategori Renk ve İkon Metodları ---
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
      default: return Icons.bookmark; // Tag yoksa çıkacak varsayılan ikon
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verileri anlık olarak dinliyoruz
    final userRoleProvider = context.watch<UserRoleProvider>();
    final notesProvider = context.watch<NotesProvider>();

    // En yeni notların en üstte olması için listeyi tersine çeviriyoruz
    final recentNotes = notesProvider.gmNotes.reversed.toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KARAKTERLER KISMI ---
            Text(
              "Karakterler",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                    ),
                    child: Center(
                      child: Icon(Icons.person_outline, color: Colors.grey[500], size: 40),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // --- NOTLAR KISMI ---
            Text(
              "Son Notlar",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: notesProvider.isLoading
                  ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                  : recentNotes.isEmpty
                  ? const Center(
                child: Text(
                  "Henüz hiç not eklenmemiş.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: recentNotes.length,
                itemBuilder: (context, index) {
                  final note = recentNotes[index];

                  final String displayTag = note.tag != null
                      ? (note.subTag != null && note.subTag!.isNotEmpty
                      ? '${note.tag} • ${note.subTag}'
                      : note.tag!)
                      : '';

                  // Güvenlik için null kontrolü (Tag yoksa boş string gönderip varsayılanı alıyoruz)
                  final safeTag = note.tag ?? '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // Arka plan rengi artık kategoriye göre değişiyor
                          color: _getTagColor(safeTag).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          // İkon ve ikon rengi artık kategoriye göre değişiyor
                            _getTagIcon(safeTag),
                            color: _getTagColor(safeTag)
                        ),
                      ),
                      title: Text(
                        note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          if (displayTag.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              displayTag,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).primaryColorLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]
                        ],
                      ),
                      onTap: () {
                        // İleride buraya tıklanınca notun detayını açacak bir Dialog ekleyebiliriz
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}