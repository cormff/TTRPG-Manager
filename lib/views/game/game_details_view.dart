// lib/views/game/game_details_view.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // YENİ: Kopyalama işlemi (Clipboard) için eklendi
import 'package:ttrpg_manager/l10n/app_localizations.dart';
import '../../models/game_model.dart';
import 'package:provider/provider.dart';
import '../../providers/games_provider.dart';
import '../../providers/maps_provider.dart';
import '../../providers/notes_provider.dart';

class GameDetailsView extends StatefulWidget {
  final Game game;

  const GameDetailsView({super.key, required this.game});

  @override
  State<GameDetailsView> createState() => _GameDetailsViewState();
}

class _GameDetailsViewState extends State<GameDetailsView> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late int _maxPlayers;
  late bool _isPublic;

  late String _currentTitle;
  late String _currentDesc;
  late int _currentMaxPlayers;
  late bool _currentIsPublic;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.game.title;
    _currentDesc = widget.game.description;
    _currentMaxPlayers = widget.game.maxPlayers;
    _currentIsPublic = widget.game.isPublic;

    _titleController = TextEditingController(text: _currentTitle);
    _descController = TextEditingController(text: _currentDesc);
    _maxPlayers = _currentMaxPlayers;
    _isPublic = _currentIsPublic;

    if (widget.game.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MapsProvider>().fetchMapsForGame(widget.game.id!);
        // YENİ: Oyunun kendi klonlanmış notlarını çek
        context.read<NotesProvider>().fetchGameNotes(widget.game.id!);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _titleController.text = _currentTitle;
        _descController.text = _currentDesc;
        _maxPlayers = _currentMaxPlayers;
        _isPublic = _currentIsPublic;
      }
    });
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.id == null) return;

    setState(() => _isLoading = true);

    final success = await Provider.of<GamesProvider>(context, listen: false).updateGame(
      widget.game.id!,
      _titleController.text,
      _descController.text,
      _maxPlayers,
      _isPublic,
      widget.game.gmId,
    );

    setState(() => _isLoading = false);

    if (success) {
      _currentTitle = _titleController.text;
      _currentDesc = _descController.text;
      _currentMaxPlayers = _maxPlayers;
      _currentIsPublic = _isPublic;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.gameUpdatedSuccess), backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updateFailed), backgroundColor: Colors.red),
        );
      }
    }
  }

  // YENİ EKLENEN METOT: Davet Kodunu Panoya Kopyalar
  void _copyInviteCode() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.game.inviteCode != null) {
      Clipboard.setData(ClipboardData(text: widget.game.inviteCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invitationCodeCopied(widget.game.inviteCode!)),
          backgroundColor: Theme.of(context).primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final primaryLight = theme.primaryColorLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editGame : widget.game.title),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _titleController.text = widget.game.title;
                _descController.text = widget.game.description;
                _maxPlayers = widget.game.maxPlayers;
                _isPublic = widget.game.isPublic;
              }
              _toggleEdit();
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- YENİ EKLENEN: DAVET KODU ALANI ---
              if (widget.game.inviteCode != null && !_isEditing)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.invitationCode, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          const SizedBox(height: 4),
                          SelectableText(
                            widget.game.inviteCode!,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0, // Harfler arası boşluk
                              color: primaryLight,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: primaryLight),
                        onPressed: _copyInviteCode,
                        tooltip: l10n.copyCode,
                      ),
                    ],
                  ),
                ),

              // --- BİLGİ / DÜZENLEME FORMU ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: primaryColor.withValues(alpha: 0.2), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        enabled: _isEditing,
                        style: const TextStyle(color: Colors.white70),
                        decoration: InputDecoration(
                          labelText: l10n.gameName,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          border: InputBorder.none,
                        ),
                      ),
                      Divider(color: primaryColor.withValues(alpha: 0.4), thickness: 1),

                      TextField(
                        controller: _descController,
                        enabled: _isEditing,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white70),
                        decoration: InputDecoration(
                          labelText: l10n.storyDescription,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          border: InputBorder.none,
                        ),
                      ),
                      Divider(color: primaryColor.withValues(alpha: 0.4), thickness: 1),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.maxPlayersLabel, style: TextStyle(color: primaryLight, fontSize: 16)),
                            _isEditing
                                ? DropdownButton<int>(
                              value: _maxPlayers,
                              dropdownColor: theme.cardColor,
                              items: [2, 3, 4, 5, 6, 8].map((e) => DropdownMenuItem(value: e, child: Text(e.toString(), style: const TextStyle(color: Colors.white)))).toList(),
                              onChanged: (val) => setState(() => _maxPlayers = val!),
                            )
                                : Text("$_maxPlayers", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                      Divider(color: primaryColor.withValues(alpha: 0.4), thickness: 1),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.publicGame, style: TextStyle(color: primaryLight, fontSize: 16)),
                        activeThumbColor: Colors.white,
                        activeTrackColor: primaryColor,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                        value: _isPublic,
                        onChanged: _isEditing ? (val) => setState(() => _isPublic = val) : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: Text(l10n.save),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              // --- OYUNU BİTİR BUTONU (SADECE DÜZENLEME MODUNDA DEĞİLKEN GÖRÜNÜR) ---
              if (!_isEditing && !widget.game.isFinished)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Onay Penceresi Göster
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: theme.cardColor,
                            title: Text(l10n.finishCampaign, style: const TextStyle(color: Colors.white)),
                            content: Text(l10n.finishCampaignConfirm, style: const TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.yesEndGame, style: const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Provider üzerinden oyunu bitir
                          final success = await context.read<GamesProvider>().finishGame(widget.game.id!, widget.game.gmId);
                          if (success && context.mounted) {
                            Navigator.pop(context); // Detay sayfasını kapatıp listeye dön
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.gameFinishedSuccess), backgroundColor: Colors.green));
                          }
                        }
                      },
                      icon: const Icon(Icons.archive, color: Colors.redAccent),
                      label: Text(l10n.finishCampaign, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                  ),
                ),

              // --- HARİTA KISMI ---
              if (!_isEditing) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.linkedMaps, style: theme.textTheme.titleLarge?.copyWith(color: primaryLight)),
                    IconButton(
                      icon: Icon(Icons.add_box, color: primaryColor, size: 28),
                      onPressed: () {
                        final allMaps = context.read<MapsProvider>().allMaps;

                        if (allMaps.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.firstlyAddMapPool)),
                          );
                          return;
                        }

                        showModalBottomSheet(
                          context: context,
                          backgroundColor: theme.cardColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.maps,
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: allMaps.length,
                                        itemBuilder: (context, index) {
                                          final map = allMaps[index];
                                          final isNetwork = map.imageUrl.startsWith('http');

                                          return GestureDetector(
                                            onTap: () async {
                                              Navigator.pop(context);

                                              final success = await context.read<MapsProvider>().createMap(
                                                map.name,
                                                map.imageUrl,
                                                gameId: widget.game.id,
                                              );

                                              if (success && context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(l10n.mapLinked), backgroundColor: Colors.green),
                                                );
                                              }
                                            },
                                            child: Container(
                                              width: 160,
                                              margin: const EdgeInsets.only(right: 12),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                                                image: DecorationImage(
                                                  image: isNetwork
                                                      ? NetworkImage(map.imageUrl) as ImageProvider
                                                      : FileImage(File(map.imageUrl)),
                                                  fit: BoxFit.cover,
                                                  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  map.name,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                                ),
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
                          },
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(height: 8),

                Consumer<MapsProvider>(
                  builder: (context, mapsProvider, child) {
                    if (mapsProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (mapsProvider.currentGameMaps.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.5), style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.map, size: 40, color: primaryColor.withValues(alpha: 0.7)),
                            const SizedBox(height: 8),
                            Text(l10n.noMapsLinked, style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                      );
                    }

                    return SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: mapsProvider.currentGameMaps.length,
                        itemBuilder: (context, index) {
                          final map = mapsProvider.currentGameMaps[index];
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                              image: map.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                // YENİ: HTTP ise NetworkImage, değilse FileImage kullan
                                image: map.imageUrl.startsWith('http')
                                    ? NetworkImage(map.imageUrl) as ImageProvider
                                    : FileImage(File(map.imageUrl)),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken),
                              )
                                  : null,
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  map.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },

                ),
                // ============================================
                // --- YENİ: NOTLAR KISMI BURADAN BAŞLIYOR ---
                // ============================================
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.gameRecordsNotes, style: theme.textTheme.titleLarge?.copyWith(color: primaryLight)),
                    IconButton(
                      icon: Icon(Icons.add_box, color: primaryColor, size: 28),
                      onPressed: () {
                        // Havuzdaki (gameId = null) şablon notlar
                        final allNotes = context.read<NotesProvider>().gmNotes;

                        if (allNotes.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.firstlyAddNotePool)),
                          );
                          return;
                        }

                        showModalBottomSheet(
                          context: context,
                          backgroundColor: theme.cardColor,
                          isScrollControlled: true, // YENİ: Listenin ekrana sığması için kontrolü ele alır
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // İçerik ne kadarsa o kadar uzar
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.notes,
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),

                                    // ÇÖZÜM BURASI: Sabit SizedBox(height: 300) yerine Flexible kullanıyoruz
                                    Flexible(
                                      child: ListView.builder(
                                        shrinkWrap: true, // YENİ: Listeyi sadece içindeki elemanlar kadar yer kaplamaya zorlar
                                        itemCount: allNotes.length,
                                        itemBuilder: (context, index) {
                                          final note = allNotes[index];
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            child: ListTile(
                                              title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              subtitle: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                                              trailing: Icon(Icons.add_circle_outline, color: primaryColor),
                                              onTap: () async {
                                                Navigator.pop(context); // Menüyü kapat

                                                // Klonlama (Kopya oluşturma) işlemini tetikle
                                                final success = await context.read<NotesProvider>().cloneNoteToGame(
                                                  note.id!, // Hangi not
                                                  widget.game.id!, // Hangi oyuna
                                                );

                                                if (success && context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(l10n.added), backgroundColor: Colors.green),
                                                  );
                                                } else if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(l10n.errorOccurred), backgroundColor: Colors.red),
                                                  );
                                                }
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
                          },
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(height: 8),

                // Oyuna Bağlı Notları Listeleme Alanı
                Consumer<NotesProvider>(
                  builder: (context, notesProvider, child) {
                    if (notesProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (notesProvider.currentGameNotes.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.5), style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.notes, size: 40, color: primaryColor.withValues(alpha: 0.7)),
                            const SizedBox(height: 8),
                            Text(l10n.noNotesLinked, style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                      );
                    }

                    // Notlar kart şeklinde dikey listelenir
                    return ListView.builder(
                      shrinkWrap: true, // Scrollable (SingleChildScrollView) içinde olduğu için zorunlu
                      physics: const NeverScrollableScrollPhysics(), // Kaydırma işlemini ana ekrana bırak
                      itemCount: notesProvider.currentGameNotes.length,
                      itemBuilder: (context, index) {
                        final note = notesProvider.currentGameNotes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                            // Notun detayına gitmek istersen buraya onTap ekleyebilirsin
                          ),
                        );
                      },
                    );
                  },
                ),
                // --- NOTLAR KISMI BİTİŞ ---
              ]
            ],
          ),
        ),
      ),
    );
  }
}
