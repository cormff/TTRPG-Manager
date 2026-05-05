import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_role_provider.dart';
import '../../providers/notes_provider.dart';
import '../../providers/games_provider.dart';
import '../game/game_details_view.dart';
import '../../providers/maps_provider.dart';
import '../../providers/characters_provider.dart';
import '../../views/gm/my_maps_view.dart';

class GMDashboard extends StatefulWidget {
  const GMDashboard({super.key});

  @override
  State<GMDashboard> createState() => _GMDashboardState();
}

class _GMDashboardState extends State<GMDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userRoleProvider = context.read<UserRoleProvider>();
      final userId = userRoleProvider.userId;

      if (userId != null) {
        final notesProvider = context.read<NotesProvider>();
        if (notesProvider.gmNotes.isEmpty) {
          notesProvider.fetchAllNotes(userId);
        }

        final gamesProvider = context.read<GamesProvider>();
        if (gamesProvider.gmGames.isEmpty) {
          gamesProvider.fetchGMGames(userId);
        }

        final mapsProvider = context.read<MapsProvider>();
        if (mapsProvider.allMaps.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<MapsProvider>().fetchAllMaps();
          });
        }

        final charactersProvider = context.read<CharactersProvider>();
        if (charactersProvider.npcCharacters.isEmpty) {
          charactersProvider.fetchNpcCharacters(userId);
        }
      }
    });
  }

  // YENİ: Ekranı aşağı kaydırınca çalışacak yenileme metodu
  Future<void> _refreshData() async {
    final userId = context.read<UserRoleProvider>().userId;
    if (userId != null) {
      // Future.wait ile tüm istekleri aynı anda (paralel) başlatıp bitmelerini bekliyoruz
      await Future.wait([
        context.read<NotesProvider>().fetchAllNotes(userId),
        context.read<GamesProvider>().fetchGMGames(userId),
        context.read<MapsProvider>().fetchAllMaps(),
        context.read<CharactersProvider>().fetchNpcCharacters(userId),
      ]);
    }
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
    final notesProvider = context.watch<NotesProvider>();
    final allGmNotes = notesProvider.gmNotes.reversed.toList();
    final displayNotes = allGmNotes.take(5).toList();

    final gamesProvider = context.watch<GamesProvider>();
    final allGmGames = gamesProvider.gmGames.reversed.toList();
    final charactersProvider = context.watch<CharactersProvider>();
    final allNpcs = charactersProvider.npcCharacters.reversed.toList();

    return Scaffold(
        body: SafeArea(
          // YENİ: RefreshIndicator eklendi
          child: RefreshIndicator(
            onRefresh: _refreshData, // Yukarıda yazdığımız metot
            color: Theme.of(context).primaryColor, // Yükleniyor ikonunun rengi
            backgroundColor: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // YENİ: Liste kısa olsa bile kaydırılıp yenilenebilmesi için
              padding: const EdgeInsets.all(16.0),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. OYUNLAR KISMI ---
              _buildSectionHeader("Games"),
              const SizedBox(height: 8),
              gamesProvider.isLoading
                  ? const SizedBox(
                      height: 110,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SizedBox(
                      height: 110,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            (allGmGames.length > 4 ? 4 : allGmGames.length) + 1,
                        itemBuilder: (context, index) {
                          int displayCount = allGmGames.length > 4
                              ? 4
                              : allGmGames.length;

                          if (index == displayCount)
                            return _buildViewMoreButton("/my_games_gm_view");

                          final game = allGmGames[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameDetailsView(game: game),
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
                                game.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text("${game.maxPlayers} Players", style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // --- 2. KARAKTERLER KISMI ---
              _buildSectionHeader("NPC's"),
              const SizedBox(height: 8),
              charactersProvider.isLoading
                  ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
                  : SizedBox(
                height: 100,
                child: allNpcs.isEmpty
                    ? ListView(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  children: [_buildViewMoreButton("/characters")],
                )
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount:
                  (allNpcs.length > 6 ? 6 : allNpcs.length) + 1,
                  itemBuilder: (context, index) {
                    final maxItems = allNpcs.length > 6
                        ? 6
                        : allNpcs.length;
                    if (index == maxItems)
                      return _buildViewMoreButton("/characters");

                    final npc = allNpcs[index];
                    return Container(
                      width: 95,
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
                          Icon(
                            Icons.smart_toy,
                            color: Colors.blue[300],
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            npc.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Lv.${npc.level}',
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

              // --- 3. HARİTALAR KISMI ---
              _buildSectionHeader("Maps"), // YENİ: Başlık diğerleriyle tam aynı hizaya alındı
              const SizedBox(height: 8),

              SizedBox(
                height: 120,
                child: Consumer<MapsProvider>(
                  builder: (context, mapsProvider, child) {
                    if (mapsProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (mapsProvider.allMaps.isEmpty) {
                      return const Text("No maps has been added yet.", style: TextStyle(color: Colors.grey));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero, // YENİ: Ekstra boşluk silindi, tam soldan başlar
                      scrollDirection: Axis.horizontal,
                      itemCount: mapsProvider.allMaps.length + 1,
                      itemBuilder: (context, index) {

                        // OK TUŞU
                        if (index == mapsProvider.allMaps.length) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MyMapsView()),
                              );
                            },
                            child: Container(
                              width: 60,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                              ),
                              child: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColorLight, size: 20),
                            ),
                          );
                        }

                        // HARİTA KARTLARI
                        final map = mapsProvider.allMaps[index];
                        final isNetwork = map.imageUrl.startsWith('http');

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(10),
                                child: InteractiveViewer(
                                  panEnabled: true,
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: isNetwork
                                        ? Image.network(map.imageUrl, fit: BoxFit.contain)
                                        : Image.file(File(map.imageUrl), fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.4)),
                              image: DecorationImage(
                                image: isNetwork
                                    ? NetworkImage(map.imageUrl) as ImageProvider
                                    : FileImage(File(map.imageUrl)),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                child: Text(
                                  map.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // --- 4. NOTLAR KISMI ---
              _buildSectionHeader("Notes"),
              const SizedBox(height: 8),

              notesProvider.isLoading
                  ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                  : displayNotes.isEmpty
                  ? const Center(child: Text("No notes has been added yet.", style: TextStyle(color: Colors.grey)))
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
                    label: const Text("See all notes"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),)
    );
  }
}
