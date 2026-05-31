import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/providers/notes_provider.dart';
import 'package:ttrpg_manager/models/note_model.dart';
import 'package:ttrpg_manager/l10n/app_localizations.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  @override
  void initState() {
    super.initState();
    // Sayfa ilk oluşturulduğunda (Kullanıcı Notes sekmesine tıkladığında) notları çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notesProvider = context.read<NotesProvider>();
      final userRoleProvider = context.read<UserRoleProvider>();

      // 1. Güncel kullanıcının ID'sini alıyoruz
      final userId = userRoleProvider.userId;

      // 2. ID null değilse ve listeler boşsa veritabanından çekme işlemini başlatıyoruz
      if (userId != null && notesProvider.gmNotes.isEmpty && notesProvider.playerNotes.isEmpty) {
        notesProvider.fetchAllNotes(userId); // <--- Eksik olan parametreyi verdik
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRoleProvider = Provider.of<UserRoleProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    // EĞER VERİLER ÇEKİLİYORSA EKRANDA LOADING GÖSTER
    if (notesProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    final bool isGM = userRoleProvider.isGameMaster;
    final String username = userRoleProvider.username;
    final notes = isGM ? notesProvider.gmNotes : notesProvider.playerNotes;
    final String appBarTitle = '$username\'s ${isGM ? l10n.gmShort : l10n.player} ${l10n.notes}';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body: notes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              l10n.noAdventureNotes,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            Text(
              l10n.tapToRecord,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

          final String displayTag = note.tag != null
              ? (note.subTag != null && note.subTag!.isNotEmpty ? '${_getLocalizedTag(context, note.tag!)} • ${note.subTag}' : _getLocalizedTag(context, note.tag!))
              : '';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Uzun başlıklarda kutuların yukarıda kalmasını sağlar
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0), // Metin ile kutular arasına nefes payı
                      child: Text(
                        note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (note.tag != null)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end, // Kutuları sağa yaslar
                      children: [
                        // 1. ANA KATEGORİ KUTUCUĞU
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTagColor(note.tag!).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _getTagColor(note.tag!)),
                          ),
                          child: Text(
                            _getLocalizedTag(context, note.tag!),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getTagColor(note.tag!),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // 2. ALT KATEGORİ KUTUCUĞU (Eğer varsa gösterilir)
                        if (note.subTag != null && note.subTag!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0), // İki kutu arasına boşluk
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.transparent, // Ana kategoriyle karışmaması için şeffaf arka plan
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getTagColor(note.tag!).withOpacity(0.6)),
                              ),
                              child: Text(
                                note.subTag!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getTagColor(note.tag!).withOpacity(0.9),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                    onPressed: () => _navigateToNoteForm(context, isGM: isGM, note: note),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, notesProvider, note.id!),
                  ),
                ],
              ),
              onTap: () {
                _showNoteDetails(context, note, isGM);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNoteForm(context, isGM: isGM),
        icon: const Icon(Icons.add),
        label: Text(l10n.newNote),
      ),
    );
  }

  String _getLocalizedTag(BuildContext context, String tag) {
    final l10n = AppLocalizations.of(context)!;
    switch (tag) {
      case 'NPC': return l10n.npc;
      case 'Quest': return l10n.quest;
      case 'Loot': return l10n.loot;
      case 'Location': return l10n.location;
      case 'Combat': return l10n.combat;
      case 'Other': return l10n.other;
      default: return tag;
    }
  }

  void _navigateToNoteForm(BuildContext context, {required bool isGM, Note? note}) {
    final l10n = AppLocalizations.of(context)!;
    final bool isEditing = note != null;
    final titleController = TextEditingController(text: note?.title);
    final contentController = TextEditingController(text: note?.content);

    String? selectedTag = note?.tag;
    String? selectedSubTag = note?.subTag; // Yeni eklenen subTag

    final List<String> tags = ['NPC', 'Quest', 'Loot', 'Location', 'Combat', 'Other'];

    // Alt kategorilerin haritası (Map)
    final Map<String, List<String>> subCategories = {
      'NPC': ['Villager', 'Merchant', 'Guard', 'Noble', 'Wizard', 'Monster'],
      'Quest': ['Main Story', 'Side Quest', 'Bounty', 'Escort', 'Gathering'],
      'Loot': ['Weapon', 'Armor', 'Consumable', 'Gold/Valuables', 'Artifact'],
      'Location': ['Village', 'City', 'Cave', 'Dungeon', 'Forest', 'Tavern'],
      'Combat': ['Encounter', 'Boss Fight', 'Trap', 'Ambush'],
      'Other': ['Lore', 'Rumor', 'Puzzle', 'Misc'],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => Scaffold(
            appBar: AppBar(
              title: Text(isEditing ? l10n.editNote : (isGM ? l10n.newGMEntry : l10n.newPlayerLog)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final provider = Provider.of<NotesProvider>(context, listen: false);
                      final currentUserId = Provider.of<UserRoleProvider>(context, listen: false).userId;
                      if (isEditing) {
                        provider.updateNote(
                          note.id!,
                          titleController.text,
                          contentController.text,
                          tag: selectedTag,
                          subTag: selectedSubTag, // Provider'a subTag gönderiliyor
                        );
                      } else {
                        provider.addNote(
                          titleController.text,
                          contentController.text,
                          isGM ? NoteType.gm : NoteType.player,
                          currentUserId!,
                          tag: selectedTag,
                          subTag: selectedSubTag, // Provider'a subTag gönderiliyor
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: l10n.title,
                      hintText: l10n.titleExample,
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ANA KATEGORİ
                  DropdownButtonFormField<String>(
                    value: selectedTag,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.category,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: tags.map((t) => DropdownMenuItem(
                      value: t,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_getLocalizedTag(context, t)),
                          Icon(
                            _getTagIcon(t),
                            color: _getTagColor(t),
                            size: 20,
                          ),
                        ],
                      ),
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedTag = val;
                        selectedSubTag = null; // Ana kategori değiştiğinde alt kategoriyi sıfırla!
                      });
                    },
                  ),

                  // ALT KATEGORİ (Sadece ana kategori seçiliyse ve alt kategorisi varsa görünür)
                  if (selectedTag != null && subCategories[selectedTag]!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedSubTag,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.subCategoryOptional,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                      ),
                      items: subCategories[selectedTag]!.map((sub) => DropdownMenuItem(
                        value: sub,
                        child: Text(sub),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedSubTag = val),
                    ),
                  ],

                  const SizedBox(height: 24),
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      labelText: l10n.details,
                      hintText: l10n.writeWhatHappened,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  void _confirmDelete(BuildContext context, NotesProvider provider, int id) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.areYouSureDeleteNote),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              provider.deleteNote(id);
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNoteDetails(BuildContext context, Note note, bool isGM) {
    final l10n = AppLocalizations.of(context)!;
    final String displayTag = note.tag != null
        ? (note.subTag != null ? '${_getLocalizedTag(context, note.tag!)} • ${note.subTag}' : _getLocalizedTag(context, note.tag!))
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.tag != null)
              Chip(
                label: Text(displayTag, style: const TextStyle(fontSize: 12)),
                backgroundColor: _getTagColor(note.tag!).withOpacity(0.2),
              ),
            Text(note.title),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(note.content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.back),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _navigateToNoteForm(context, isGM: isGM, note: note);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: Text(l10n.edit),
          ),
        ],
      ),
    );
  }
}
