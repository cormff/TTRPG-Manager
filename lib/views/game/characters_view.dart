import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/character_model.dart';
import '../../providers/characters_provider.dart';
import '../../providers/user_role_provider.dart';
import '../../providers/games_provider.dart';

class CharactersView extends StatefulWidget {
  const CharactersView({super.key});

  @override
  State<CharactersView> createState() => _CharactersViewState();
}



class _CharactersViewState extends State<CharactersView> {
  static const List<String> availableAvatars = [
    'assets/images/avatars/human_fighter.png',
    'assets/images/avatars/elf_ranger.png',
    'assets/images/avatars/dwarf_cleric.png',
    'assets/images/avatars/orc_barbarian.png',
    'assets/images/avatars/tiefling_warlock.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCharacters());
  }

  Future<void> _fetchCharacters() async {
    final userRoleProvider = context.read<UserRoleProvider>();
    final userId = userRoleProvider.userId;
    if (userId == null) return;

    final charactersProvider = context.read<CharactersProvider>();
    if (userRoleProvider.isGameMaster) {
      await charactersProvider.fetchNpcCharacters(userId);
    } else {
      await charactersProvider.fetchPlayerCharacters(userId);
    }
  }

  // ==================== KARAKTER EKLEME FORMU ====================

  Future<void> _showAddCharacterDialog(bool isGM) async {
    final nameController = TextEditingController();
    final backstoryController = TextEditingController();
    final hpController = TextEditingController(text: '10');
    final acController = TextEditingController(text: '10');

    String? selectedAvatarUrl;
    String? selectedRace;
    String? selectedClass;
    String? selectedBackground;
    int? selectedGameId;
    int selectedLevel = 1;
    int selectedSpeed = 30;
    CharacterAlignment selectedAlignment = CharacterAlignment.trueNeutral;

    // Ability Scores
    int str = 10, dex = 10, con = 10, intl = 10, wis = 10, cha = 10;

    // Kullanıcının oyunlarını çek (Game ID dropdown için)
    final gamesProvider = context.read<GamesProvider>();
    final userRoleProvider = context.read<UserRoleProvider>();
    final userId = userRoleProvider.userId;
    if (userId != null && isGM && gamesProvider.gmGames.isEmpty) {
      await gamesProvider.fetchGMGames(userId);
    } else if (userId != null && !isGM && gamesProvider.playerGames.isEmpty) {
      await gamesProvider.fetchPlayerGames(userId);
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final games = isGM
                ? gamesProvider.gmGames
                : gamesProvider.playerGames;

            // Ability score satırı oluşturan yardımcı widget
            Widget buildAbilityRow(
              String label,
              int value,
              ValueChanged<int> onChanged,
            ) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: value > 1
                          ? () => onChanged(value - 1)
                          : null,
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$value',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: value < 20
                          ? () => onChanged(value + 1)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    // Modifier gösterimi
                    Text(
                      _getModifier(value),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: Text(isGM ? 'NPC Ekle' : 'Karakter Ekle'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── AVATAR SEÇİMİ ───
                      const Text(
                        'Karakter Resmi (Opsiyonel)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: availableAvatars.length,
                          itemBuilder: (context, index) {
                            final avatarPath = availableAvatars[index];
                            final isSelected = selectedAvatarUrl == avatarPath;
                            return GestureDetector(
                              onTap: () => setDialogState(
                                  () => selectedAvatarUrl = avatarPath),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(dialogContext).primaryColor
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(avatarPath),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ─── İSİM ───
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'İsim *',
                          hintText: 'Örn: Gandalf, Aragorn',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ─── IRK (RACE) ───
                      DropdownButtonFormField<String>(
                        value: selectedRace,
                        decoration: const InputDecoration(
                          labelText: 'Irk (Race) *',
                          prefixIcon: Icon(Icons.groups_outlined),
                        ),
                        items: DndRaces.all
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedRace = val),
                      ),
                      const SizedBox(height: 14),

                      // ─── SINIF (CLASS) ───
                      DropdownButtonFormField<String>(
                        value: selectedClass,
                        decoration: const InputDecoration(
                          labelText: 'Sınıf (Class) *',
                          prefixIcon: Icon(Icons.shield_outlined),
                        ),
                        items: DndClasses.all
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedClass = val),
                      ),
                      const SizedBox(height: 14),

                      // ─── SEVİYE (LEVEL) — Slider ───
                      Row(
                        children: [
                          const Icon(Icons.trending_up, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Seviye: $selectedLevel',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Slider(
                        value: selectedLevel.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: selectedLevel.toString(),
                        activeColor: Theme.of(dialogContext).primaryColor,
                        onChanged: (val) =>
                            setDialogState(() => selectedLevel = val.round()),
                      ),
                      const SizedBox(height: 6),

                      // ─── BACKGROUND ───
                      DropdownButtonFormField<String>(
                        value: selectedBackground,
                        decoration: const InputDecoration(
                          labelText: 'Background',
                          prefixIcon: Icon(Icons.history_edu_outlined),
                        ),
                        items: DndBackgrounds.all
                            .map((b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(b),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedBackground = val),
                      ),
                      const SizedBox(height: 14),

                      // ─── ALIGNMENT ───
                      DropdownButtonFormField<CharacterAlignment>(
                        value: selectedAlignment,
                        decoration: const InputDecoration(
                          labelText: 'Alignment',
                          prefixIcon: Icon(Icons.balance_outlined),
                        ),
                        items: DndAlignments.labels.entries
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.key,
                                child: Text(item.value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedAlignment = value);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // ─── OYUN SEÇİMİ ───
                      DropdownButtonFormField<int?>(
                        value: selectedGameId,
                        decoration: const InputDecoration(
                          labelText: 'Oyun (opsiyonel)',
                          prefixIcon: Icon(Icons.casino_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Oyuna bağlama'),
                          ),
                          ...games.map((g) => DropdownMenuItem<int?>(
                                value: g.id,
                                child: Text(g.title),
                              )),
                        ],
                        onChanged: (val) =>
                            setDialogState(() => selectedGameId = val),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),

                      // ─── ABILITY SCORES ───
                      const Text(
                        '⚔️ Ability Scores',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Standart: 10 | Modifier otomatik hesaplanır',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildAbilityRow(
                          'STR', str, (v) => setDialogState(() => str = v)),
                      buildAbilityRow(
                          'DEX', dex, (v) => setDialogState(() => dex = v)),
                      buildAbilityRow(
                          'CON', con, (v) => setDialogState(() => con = v)),
                      buildAbilityRow(
                          'INT', intl, (v) => setDialogState(() => intl = v)),
                      buildAbilityRow(
                          'WIS', wis, (v) => setDialogState(() => wis = v)),
                      buildAbilityRow(
                          'CHA', cha, (v) => setDialogState(() => cha = v)),

                      const SizedBox(height: 16),
                      const Divider(),

                      // ─── COMBAT STATS ───
                      const Text(
                        '🛡️ Combat Stats',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: hpController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'HP',
                                prefixIcon: Icon(Icons.favorite_outline),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: acController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'AC',
                                prefixIcon: Icon(Icons.shield),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.speed, size: 20),
                          const SizedBox(width: 8),
                          Text('Speed: $selectedSpeed ft'),
                        ],
                      ),
                      Slider(
                        value: selectedSpeed.toDouble(),
                        min: 20,
                        max: 50,
                        divisions: 6,
                        label: '$selectedSpeed ft',
                        activeColor: Colors.teal,
                        onChanged: (val) =>
                            setDialogState(() => selectedSpeed = val.round()),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // ─── BACKSTORY ───
                      TextField(
                        controller: backstoryController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Backstory (hikaye)',
                          hintText: 'Karakterin geçmişi, motivasyonu...',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 60),
                            child: Icon(Icons.auto_stories_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: () async {
                    // Validasyon
                    if (nameController.text.trim().isEmpty ||
                        selectedRace == null ||
                        selectedClass == null) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('İsim, Irk ve Sınıf alanları zorunludur.'),
                        ),
                      );
                      return;
                    }

                    final currentUserId =
                        this.context.read<UserRoleProvider>().userId;
                    if (currentUserId == null) return;

                    final provider = this.context.read<CharactersProvider>();
                    final hp = int.tryParse(hpController.text.trim()) ?? 10;
                    final ac = int.tryParse(acController.text.trim()) ?? 10;

                    final success = isGM
                        ? await provider.addNpcCharacter(
                            gmId: currentUserId,
                            name: nameController.text.trim(),
                            race: selectedRace!,
                            charClass: selectedClass!,
                            level: selectedLevel,
                            background: selectedBackground ?? '',
                            alignment: selectedAlignment,
                            gameId: selectedGameId,
                            strength: str,
                            dexterity: dex,
                            constitution: con,
                            intelligence: intl,
                            wisdom: wis,
                            charisma: cha,
                            hitPoints: hp,
                            armorClass: ac,
                            speed: selectedSpeed,
                            backstory: backstoryController.text.trim(),
                            avatarUrl: selectedAvatarUrl ?? '',
                          )
                        : await provider.addPlayerCharacter(
                            userId: currentUserId,
                            name: nameController.text.trim(),
                            race: selectedRace!,
                            charClass: selectedClass!,
                            level: selectedLevel,
                            background: selectedBackground ?? '',
                            alignment: selectedAlignment,
                            gameId: selectedGameId,
                            strength: str,
                            dexterity: dex,
                            constitution: con,
                            intelligence: intl,
                            wisdom: wis,
                            charisma: cha,
                            hitPoints: hp,
                            armorClass: ac,
                            speed: selectedSpeed,
                            backstory: backstoryController.text.trim(),
                            avatarUrl: selectedAvatarUrl ?? '',
                          );

                    if (!mounted) return;
                    Navigator.of(this.context).pop();
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? (isGM ? 'NPC eklendi!' : 'Karakter eklendi!')
                              : 'Kayıt sırasında hata oluştu.',
                        ),
                        backgroundColor:
                            success ? Colors.green : Colors.redAccent,
                      ),
                    );
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // D&D 5e ability modifier hesaplama
  String _getModifier(int score) {
    final mod = ((score - 10) / 2).floor();
    return mod >= 0 ? '(+$mod)' : '($mod)';
  }

  // ==================== KARAKTER LİSTESİ ====================

  @override
  Widget build(BuildContext context) {
    final roleProvider = context.watch<UserRoleProvider>();
    final charactersProvider = context.watch<CharactersProvider>();
    final isGM = roleProvider.isGameMaster;
    final characters = isGM
        ? charactersProvider.npcCharacters.reversed.toList()
        : charactersProvider.playerCharacters.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isGM ? "NPC'ler" : 'Karakterlerim'),
        actions: [
          IconButton(
            onPressed: _fetchCharacters,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCharacterDialog(isGM),
        child: const Icon(Icons.add),
      ),
      body: charactersProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : characters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isGM ? Icons.smart_toy_outlined : Icons.person_outline,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isGM
                            ? 'Henüz NPC eklenmemiş.'
                            : 'Henüz karakter eklenmemiş.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+ butonuna basarak oluşturabilirsin!',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return _buildCharacterCard(character, isGM);
                  },
                ),
    );
  }

  // ==================== KARAKTER KART GÖRÜNÜMÜ ====================

  Widget _buildCharacterCard(CharacterModel character, bool isGM) {
    final alignmentText =
        DndAlignments.labels[character.alignment] ?? 'True Neutral';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCharacterDetails(character, isGM),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır: İsim + Level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (character.avatarUrl.isNotEmpty)
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: AssetImage(character.avatarUrl),
                        )
                      else
                        Icon(
                          isGM ? Icons.smart_toy : Icons.person_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        character.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Lv.${character.level}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Orta satır: Race • Class • Alignment
              Text(
                '${character.race} • ${character.charClass}',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                alignmentText,
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),

              // Alt satır: HP / AC / Speed chip'leri
              Row(
                children: [
                  _buildStatChip(
                      Icons.favorite, '${character.hitPoints}', Colors.red),
                  const SizedBox(width: 8),
                  _buildStatChip(
                      Icons.shield, '${character.armorClass}', Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatChip(
                      Icons.speed, '${character.speed} ft', Colors.teal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== KARAKTER DETAY POPUP ====================

  void _showCharacterDetails(CharacterModel character, bool isGM) {
    final alignmentText =
        DndAlignments.labels[character.alignment] ?? 'True Neutral';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (character.avatarUrl.isNotEmpty)
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(character.avatarUrl),
              )
            else
              Icon(
                isGM ? Icons.smart_toy : Icons.person_outline,
                color: Theme.of(context).primaryColor,
              ),
            const SizedBox(width: 8),
            Expanded(child: Text(character.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Irk', character.race),
              _buildDetailRow('Sınıf', character.charClass),
              _buildDetailRow('Seviye', '${character.level}'),
              _buildDetailRow('Alignment', alignmentText),
              if (character.background.isNotEmpty)
                _buildDetailRow('Background', character.background),
              const Divider(),
              const Text(
                'Ability Scores',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildAbilityChip(
                      'STR', character.strength),
                  _buildAbilityChip(
                      'DEX', character.dexterity),
                  _buildAbilityChip(
                      'CON', character.constitution),
                  _buildAbilityChip(
                      'INT', character.intelligence),
                  _buildAbilityChip(
                      'WIS', character.wisdom),
                  _buildAbilityChip(
                      'CHA', character.charisma),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCombatStat('HP', '${character.hitPoints}', Colors.red),
                  _buildCombatStat('AC', '${character.armorClass}', Colors.blue),
                  _buildCombatStat(
                      'SPD', '${character.speed}ft', Colors.teal),
                ],
              ),
              if (character.backstory.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const Text(
                  'Backstory',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  character.backstory,
                  style: TextStyle(color: Colors.grey[400], height: 1.5),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAbilityChip(String label, int score) {
    final mod = ((score - 10) / 2).floor();
    final modStr = mod >= 0 ? '+$mod' : '$mod';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          Text(
            '$score',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            modStr,
            style: TextStyle(
              fontSize: 11,
              color: mod >= 0 ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombatStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
