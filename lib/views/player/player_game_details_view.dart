import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/game_model.dart';

class PlayerGameDetailsView extends StatelessWidget {
  final Game game;

  const PlayerGameDetailsView({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Eğer oyuna bağlı bir harita varsa ilkini alalım
    final hasMap = game.maps != null && game.maps!.isNotEmpty;
    final mapUrl = hasMap ? game.maps!.first['imageUrl'] : null;
    final mapName = hasMap ? game.maps!.first['name'] : null;
    final isNetworkImage = hasMap && mapUrl.toString().startsWith('http');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(context.tr('Game Details')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- OYUN BAŞLIĞI VE AÇIKLAMASI ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.description.isEmpty ? "GM has not added a description yet..." : game.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.people, color: theme.primaryColorLight, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "${game.joinedPlayerIds.length} / ${game.maxPlayers} Players Joined",
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- AKTİF HARİTA KISMI ---
            const Text(
              "Active Map",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            if (hasMap)
              GestureDetector(
                onTap: () {
                  // Haritaya tıklanınca büyütme (Zoom)
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
                          child: isNetworkImage
                              ? Image.network(mapUrl, fit: BoxFit.contain)
                              : Image.file(File(mapUrl), fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                    image: DecorationImage(
                      image: isNetworkImage
                          ? NetworkImage(mapUrl) as ImageProvider
                          : FileImage(File(mapUrl)),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Text(
                        mapName ?? "Nameless Map",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(context.tr('GM has not added a map to this game yet.'), style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}