import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/providers/notes_provider.dart';
import 'package:ttrpg_manager/models/note_model.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notesProvider = context.read<NotesProvider>();
      final userRoleProvider = context.read<UserRoleProvider>();

      final userId = userRoleProvider.userId;

      if (userId != null && notesProvider.gmNotes.isEmpty && notesProvider.playerNotes.isEmpty) {
        notesProvider.fetchAllNotes(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRoleProvider = Provider.of<UserRoleProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);

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

    // ÇÖZÜM: İsim ve Notlar kısmı dinamik çeviriye bağlandı
    final String appBarTitle = '$username - ${isGM ? context.tr('GM Notes') : context.tr('Player Notes')}';

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
            Icon(Icons.note_alt_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              context.tr('No adventure notes yet.'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
            Text(
              context.tr('Tap + to record your journey!'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        note.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (note.tag != null)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTagColor(note.tag!).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _getTagColor(note.tag!)),
                          ),
                          child: Text(
                            context.tr(note.tag!), // Kategori ismi çevirildi
                            style: TextStyle(
                              fontSize: 10,
                              color: _getTagColor(note.tag!),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (note.subTag != null && note.subTag!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getTagColor(note.tag!).withOpacity(0.6)),
                              ),
                              child: Text(
                                context.tr(note.subTag!), // Alt kategori ismi çevirildi
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
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), // Tema ile dinamik renk
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
        label: Text(context.tr('New Note')),
      ),
    );
  }

  void _navigateToNoteForm(BuildContext context, {required bool isGM, Note? note}) {
    final bool isEditing = note != null;
    final titleController = TextEditingController(text: note?.title);
    final contentController = TextEditingController(text: note?.content);

    String? selectedTag = note?.tag;
    String? selectedSubTag = note?.subTag;

    final List<String> tags = ['NPC', 'Quest', 'Loot', 'Location', 'Combat', 'Other'];

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
              title: Text(isEditing ? context.tr('Edit Note') : (isGM ? context.tr('New GM Entry') : context.tr('New Player Log'))),
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
                          subTag: selectedSubTag,
                        );
                      } else {
                        provider.addNote(
                          titleController.text,
                          contentController.text,
                          isGM ? NoteType.gm : NoteType.player,
                          currentUserId!,
                          tag: selectedTag,
                          subTag: selectedSubTag,
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
                      labelText: context.tr('Title'),
                      hintText: context.tr('e.g. The Mysterious Stranger'),
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    value: selectedTag,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.tr('Category'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: tags.map((t) => DropdownMenuItem(
                      value: t, // Value İngilizce kalıyor (DB için)
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.tr(t)), // Ekranda Çevirisi görünüyor
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
                        selectedSubTag = null;
                      });
                    },
                  ),

                  if (selectedTag != null && subCategories[selectedTag]!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedSubTag,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: context.tr('Sub-Category (Optional)'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                      ),
                      items: subCategories[selectedTag]!.map((sub) => DropdownMenuItem(
                        value: sub, // DB için İngilizce kalıyor
                        child: Text(context.tr(sub)), // Ekranda çevirisi görünüyor
                      )).toList(),
                      onChanged: (val) => setState(() => selectedSubTag = val),
                    ),
                  ],

                  const SizedBox(height: 24),
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      labelText: context.tr('Details'),
                      hintText: context.tr('Write down what happened...'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Delete Note?')),
        content: Text(context.tr('Are you sure you want to delete this note?')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('Cancel'))),
          TextButton(
            onPressed: () {
              provider.deleteNote(id);
              Navigator.pop(context);
            },
            child: Text(context.tr('Delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNoteDetails(BuildContext context, Note note, bool isGM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.tag != null)
              Chip(
                // Detay popup'ında da çevrilmiş halleri görünür
                label: Text(note.subTag != null ? '${context.tr(note.tag!)} • ${context.tr(note.subTag!)}' : context.tr(note.tag!), style: const TextStyle(fontSize: 12)),
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
            child: Text(context.tr('Back')),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _navigateToNoteForm(context, isGM: isGM, note: note);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: Text(context.tr('Edit')),
          ),
        ],
      ),
    );
  }
}