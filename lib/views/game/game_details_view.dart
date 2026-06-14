// lib/views/game/game_details_view.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/game_model.dart';
import 'package:provider/provider.dart';
import '../../providers/games_provider.dart';
import '../../providers/maps_provider.dart';
import '../../providers/notes_provider.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';

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

  // ÇÖZÜM 1: Çeviri metinlerini dışarıdan parametre olarak alıyoruz
  Future<void> _saveChanges(String successMsg, String failMsg) async {
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

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _currentTitle = _titleController.text;
      _currentDesc = _descController.text;
      _currentMaxPlayers = _maxPlayers;
      _currentIsPublic = _isPublic;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMsg), backgroundColor: Colors.green),
      );
      // Düzenleme modundan çıkıp oyun detay görünümüne geçmeyi sağlar
      setState(() => _isEditing = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failMsg), backgroundColor: Colors.red),
      );
    }
  }

  // ÇÖZÜM 2: Kopyalama bildirimini de parametreye bağladık
  void _copyInviteCode(String msgText) {
    if (widget.game.inviteCode != null) {
      Clipboard.setData(ClipboardData(text: widget.game.inviteCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$msgText ${widget.game.inviteCode}'),
          backgroundColor: Theme.of(context).primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.colorScheme.onSurface;

    // ÇÖZÜM 3: Çökme riskini ortadan kaldırmak için tüm popup, alert ve snackbar
    // çevirilerini GÜVENLİ OLAN 'build' metodu içinde bir kez hesaplıyoruz!
    final String msgUpdateSuccess = context.tr('Game successfully updated!');
    final String msgUpdateFail = context.tr('Update failed. Try again later.');
    final String msgCopyCode = context.tr('Invitation code copied:');
    final String msgFinishTitle = context.tr('Finish Campaing');
    final String msgFinishContent = context.tr('Are you sure you want to finish this campaign? This action cannot be undone!');
    final String msgCancel = context.tr('İptal');
    final String msgYesEnd = context.tr('Yes, end the game');
    final String msgFinishSuccess = context.tr('Game successfully finished!');
    final String msgMapWarn = context.tr('Firstly a map has to be added to map pool!');
    final String msgMaps = context.tr('Maps');
    final String msgMapLinked = context.tr('Map linked!');
    final String msgNoteWarn = context.tr('Firstly a note has to be added to note pool!');
    final String msgNotes = context.tr('Notes');
    final String msgNoteAdded = context.tr('Added');
    final String msgNoteError = context.tr('Error occured while adding the note.');

    return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? context.tr('Edit game') : widget.game.title),
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
                // --- DAVET KODU ALANI ---
                if (widget.game.inviteCode != null && !_isEditing)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('Game invitation code'), style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12)),
                            const SizedBox(height: 4),
                            SelectableText(
                              widget.game.inviteCode!,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: primaryColor),
                          onPressed: () => _copyInviteCode(msgCopyCode),
                          tooltip: context.tr('Copy code'),
                        ),
                      ],
                    ),
                  ),

                // --- BİLGİ / DÜZENLEME FORMU ---
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: primaryColor.withOpacity(0.2), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _titleController,
                          enabled: _isEditing,
                          style: TextStyle(color: textColor.withOpacity(0.9)),
                          decoration: InputDecoration(
                            labelText: context.tr('Game Name'),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                            border: InputBorder.none,
                          ),
                        ),
                        Divider(color: primaryColor.withOpacity(0.4), thickness: 1),

                        TextField(
                          controller: _descController,
                          enabled: _isEditing,
                          maxLines: 4,
                          style: TextStyle(color: textColor.withOpacity(0.9)),
                          decoration: InputDecoration(
                            labelText: context.tr('Story / Description'),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                            border: InputBorder.none,
                          ),
                        ),
                        Divider(color: primaryColor.withOpacity(0.4), thickness: 1),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.tr('Max Player:'), style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              _isEditing
                                  ? DropdownButton<int>(
                                value: _maxPlayers,
                                dropdownColor: theme.cardColor,
                                items: [2, 3, 4, 5, 6, 8].map((e) => DropdownMenuItem(value: e, child: Text(e.toString(), style: TextStyle(color: textColor)))).toList(),
                                onChanged: (val) => setState(() => _maxPlayers = val!),
                              )
                                  : Text('$_maxPlayers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                            ],
                          ),
                        ),
                        Divider(color: primaryColor.withOpacity(0.4), thickness: 1),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.tr('Public Game'), style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          activeColor: Colors.white,
                          activeTrackColor: primaryColor,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.withOpacity(0.3),
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
                      onPressed: () => _saveChanges(msgUpdateSuccess, msgUpdateFail),
                      icon: const Icon(Icons.save),
                      label: Text(context.tr('Save Changes')),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                // --- OYUNU BİTİR BUTONU ---
                if (!_isEditing && !widget.game.isFinished)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: theme.cardColor,
                              title: Text(msgFinishTitle, style: TextStyle(color: textColor)),
                              content: Text(msgFinishContent, style: TextStyle(color: textColor.withOpacity(0.7))),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(msgCancel, style: const TextStyle(color: Colors.grey))),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(msgYesEnd, style: const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final success = await context.read<GamesProvider>().finishGame(widget.game.id!, widget.game.gmId);
                            if (success && context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(msgFinishSuccess), backgroundColor: Colors.green));
                            }
                          }
                        },
                        icon: const Icon(Icons.archive, color: Colors.redAccent),
                        label: Text(context.tr('End Campaing'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
                      Text(context.tr('Linked Maps'), style: theme.textTheme.titleLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.add_box, color: primaryColor, size: 28),
                        onPressed: () {
                          final allMaps = context.read<MapsProvider>().allMaps;

                          if (allMaps.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msgMapWarn)),
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
                                        msgMaps,
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

// "Map linked!" mesajından hemen önceki kod
                                                final currentUserId = context.read<UserRoleProvider>().userId; // YENİ
                                                final success = await context.read<MapsProvider>().createMap(
                                                  map.name,
                                                  map.imageUrl,
                                                  currentUserId!, // <--- YENİ EKLENDİ
                                                  gameId: widget.game.id,
                                                );

                                                if (success && context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(msgMapLinked), backgroundColor: Colors.green),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                width: 160,
                                                margin: const EdgeInsets.only(right: 12),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: primaryColor.withOpacity(0.5)),
                                                  image: DecorationImage(
                                                    image: isNetwork
                                                        ? NetworkImage(map.imageUrl) as ImageProvider
                                                        : FileImage(File(map.imageUrl)),
                                                    fit: BoxFit.cover,
                                                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
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
                            border: Border.all(color: primaryColor.withOpacity(0.5), style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.map, size: 40, color: primaryColor.withOpacity(0.7)),
                              const SizedBox(height: 8),
                              Text(context.tr('No maps has been linked to this game.'), style: TextStyle(color: textColor.withOpacity(0.6))),
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
                                border: Border.all(color: primaryColor.withOpacity(0.4)),
                                image: map.imageUrl.isNotEmpty
                                    ? DecorationImage(
                                  image: map.imageUrl.startsWith('http')
                                      ? NetworkImage(map.imageUrl) as ImageProvider
                                      : FileImage(File(map.imageUrl)),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
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
                  // --- NOTLAR KISMI ---
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('Game records & Notes'), style: theme.textTheme.titleLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.add_box, color: primaryColor, size: 28),
                        onPressed: () {
                          final allNotes = context.read<NotesProvider>().gmNotes;

                          if (allNotes.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msgNoteWarn)),
                            );
                            return;
                          }

                          showModalBottomSheet(
                            context: context,
                            backgroundColor: theme.cardColor,
                            isScrollControlled: true,
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
                                        msgNotes,
                                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),

                                      Flexible(
                                        child: ListView.builder(
                                          shrinkWrap: true,
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
                                                  Navigator.pop(context);

                                                  final success = await context.read<NotesProvider>().cloneNoteToGame(
                                                    note.id!,
                                                    widget.game.id!,
                                                  );

                                                  if (success && context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text(msgNoteAdded), backgroundColor: Colors.green),
                                                    );
                                                  } else if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text(msgNoteError), backgroundColor: Colors.red),
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
                            border: Border.all(color: primaryColor.withOpacity(0.5), style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.notes, size: 40, color: primaryColor.withOpacity(0.7)),
                              const SizedBox(height: 8),
                              Text(context.tr('No notes has been added yet to this game.'), style: TextStyle(color: textColor.withOpacity(0.6))),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                child: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor.withOpacity(0.7))),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ]
              ],
            ),
          ),)
    );
  }
}