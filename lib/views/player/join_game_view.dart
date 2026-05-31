// lib/views/player/join_game_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/games_provider.dart';
import '../../providers/user_role_provider.dart';

class JoinGameView extends StatefulWidget {
  const JoinGameView({super.key});

  @override
  State<JoinGameView> createState() => _JoinGameViewState();
}

class _JoinGameViewState extends State<JoinGameView> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında halka açık (public) oyunları çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamesProvider>().fetchPublicGames();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // Ortak Katılma Fonksiyonu (Hem kodla hem de listeden katılmak için)
  Future<void> _handleJoinGame(int gameId) async {
    final userId = context.read<UserRoleProvider>().userId;
    if (userId == null) return;

    // Yükleniyor animasyonu göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final errorMsg = await context.read<GamesProvider>().joinGame(gameId, userId);

    // Animasyonu kapat
    if (mounted) Navigator.pop(context);
    if (!mounted) return;

    if (errorMsg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(context.tr('You have successfully joined the game!')), backgroundColor: Colors.green),
      );
      _codeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  // Kutuya girilen ID ile katılma
// Kutuya girilen Davet Kodu (Invite Code) ile katılma
  void _joinByCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final userId = context.read<UserRoleProvider>().userId;
    if (userId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // YENİ: ID yerine kodu gönderiyoruz
    final errorMsg = await context.read<GamesProvider>().joinGameByCode(code, userId);

    if (mounted) Navigator.pop(context);
    if (!mounted) return;

    if (errorMsg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(context.tr('You have successfully joined the game!')), backgroundColor: Colors.green),
      );
      _codeController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamesProvider = context.watch<GamesProvider>();
    final publicGames = gamesProvider.publicGames.reversed.toList();
    final theme = Theme.of(context);
    final currentUserId = context.read<UserRoleProvider>().userId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(context.tr('Find Games')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. DAVET KODU KISMI (PRIVATE OYUNLAR İÇİN) ---
            const Text(
              "Join to a Private Game",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.text, // YENİ: Artık harf de girebilirler
                    textCapitalization: TextCapitalization.characters, // Otomatik büyük harf
                    decoration: InputDecoration(
                      hintText: "Ex: A7X9BQ",
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _joinByCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(context.tr('Join'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- 2. HALKA AÇIK OYUNLAR LİSTESİ ---
            const Text(
              "Public Games",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: gamesProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : publicGames.isEmpty
                  ? const Center(child: Text(context.tr('No public games have been created yet.'), style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                itemCount: publicGames.length,
                itemBuilder: (context, index) {
                  final game = publicGames[index];
                  final isFull = game.joinedPlayerIds.length >= game.maxPlayers;
                  final isAlreadyJoined = currentUserId != null && game.joinedPlayerIds.contains(currentUserId);
                  final isMyCreatedGame = currentUserId != null && game.gmId == currentUserId;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: theme.cardColor,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  game.title,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              Text(
                                "${game.joinedPlayerIds.length} / ${game.maxPlayers}",
                                style: TextStyle(
                                  color: isFull ? Colors.redAccent : Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            game.description.isEmpty ? "No description..." : game.description,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (isFull || isAlreadyJoined || isMyCreatedGame)
                                  ? null
                                  : () => _handleJoinGame(game.id!),
                              style: ElevatedButton.styleFrom(
                                // Aktif olduğunda (Oyuna Katıl) görünecek renk
                                backgroundColor: theme.primaryColor.withOpacity(0.8),

                                // ÇÖZÜM BURASI: Tıklanabilir olmadığında (null iken) alacağı renkler
                                disabledBackgroundColor: isMyCreatedGame ? Colors.black26 :
                                isAlreadyJoined ? Colors.deepPurple :
                                Colors.grey.withOpacity(0.5), // "Oda Dolu" durumu için

                                // Devre dışı kalsa bile yazının beyaz ve okunaklı kalmasını sağlar
                                disabledForegroundColor: Colors.white,

                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                isMyCreatedGame ? "Your Game" :
                                isAlreadyJoined ? "Already Joined" :
                                isFull ? "World is full" : "Join Game",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
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