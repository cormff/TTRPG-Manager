import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_model.dart';
import '../../services/game_service.dart';
import '../../providers/maps_provider.dart';

class FinishedGameDetailsView extends StatefulWidget {
  final Game game;

  const FinishedGameDetailsView({super.key, required this.game});

  @override
  State<FinishedGameDetailsView> createState() => _FinishedGameDetailsViewState();
}

class _FinishedGameDetailsViewState extends State<FinishedGameDetailsView> {
  bool _isLoading = true;
  Map<int, String> _playerNames = {};
  List<dynamic> _gameNotes = [];

  @override
  void initState() {
    super.initState();
    _loadArchiveData();
  }

  Future<void> _loadArchiveData() async {
    // Haritaları provider üzerinden çek
    if (widget.game.id != null) {
      context.read<MapsProvider>().fetchMapsForGame(widget.game.id!);
    }

    // İsimleri ve notları servis üzerinden paralel olarak çek
    final gameService = GameService();

    final futures = await Future.wait([
      gameService.getUsernames(widget.game.joinedPlayerIds),
      if (widget.game.id != null) gameService.getGameNotes(widget.game.id!) else Future.value([]),
    ]);

    if (mounted) {
      setState(() {
        _playerNames = futures[0] as Map<int, String>;
        _gameNotes = futures.length > 1 ? futures[1] as List<dynamic> : [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(context.tr('Game Archive')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.inventory_2, color: Colors.amber), // Arşiv ikonu
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HİKAYE VE BAŞLIK ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2), // Altın sarısı arşiv çerçevesi
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.game.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.game.description.isEmpty ? "Story has not been told..." : widget.game.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 2. OYUNCULAR (İSİMLERİYLE BERABER) ---
            Text(context.tr('Adventurers'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            if (widget.game.joinedPlayerIds.isEmpty)
              const Text(context.tr('No players have joined this game.'), style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.game.joinedPlayerIds.map((id) {
                  final playerName = _playerNames[id] ?? "Unkown Hero";
                  return Chip(
                    avatar: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.person, color: Colors.black, size: 16)),
                    label: Text(playerName, style: const TextStyle(color: Colors.white)),
                    backgroundColor: theme.primaryColor.withOpacity(0.3),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // --- 3. HARİTALAR ---
            Text(context.tr('Discovered Realms'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Consumer<MapsProvider>(
              builder: (context, mapsProvider, child) {
                if (mapsProvider.currentGameMaps.isEmpty) {
                  return const Text(context.tr('No maps have been added for this game.'), style: TextStyle(color: Colors.grey));
                }
                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mapsProvider.currentGameMaps.length,
                    itemBuilder: (context, index) {
                      final map = mapsProvider.currentGameMaps[index];
                      final isNetwork = map.imageUrl.startsWith('http');
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.4)),
                          image: DecorationImage(
                            image: isNetwork ? NetworkImage(map.imageUrl) as ImageProvider : FileImage(File(map.imageUrl)),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                          ),
                        ),
                        child: Center(
                          child: Text(map.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // --- 4. OYUN NOTLARI ---
            Text(context.tr('Game Records & Notes'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            if (_gameNotes.isEmpty)
              const Text(context.tr('No note added for this campaign!'), style: TextStyle(color: Colors.grey))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _gameNotes.length,
                itemBuilder: (context, index) {
                  final note = _gameNotes[index];
                  return Card(
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.bookmark, color: Colors.amber),
                      title: Text(note['title'] ?? 'Nameless Note', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Text(note['content'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}