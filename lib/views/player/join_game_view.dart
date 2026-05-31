// lib/views/player/join_game_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.joinedSuccess), backgroundColor: Colors.green),
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
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.joinedSuccess), backgroundColor: Colors.green),
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
    final l10n = AppLocalizations.of(context)!;
    final gamesProvider = context.watch<GamesProvider>();
    final publicGames = gamesProvider.publicGames.reversed.toList();
    final theme = Theme.of(context);
    final currentUserId = context.read<UserRoleProvider>().userId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.findGames),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. DAVET KODU KISMI (PRIVATE OYUNLAR İÇİN) ---
            Text(
              l10n.joinPrivateGame,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                      hintText: l10n.inviteCodeHint,
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
                  child: Text(l10n.join, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- 2. HALKA AÇIK OYUNLAR LİSTESİ ---
            Text(
              l10n.publicGames,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: gamesProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : publicGames.isEmpty
                  ? Center(child: Text(l10n.noPublicGames, style: const TextStyle(color: Colors.grey)))
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
                            game.description.isEmpty ? l10n.noDescriptionYet : game.description,
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
                                isMyCreatedGame ? l10n.yourGame :
                                isAlreadyJoined ? l10n.alreadyJoined :
                                isFull ? l10n.worldIsFull : l10n.joinGame,
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
