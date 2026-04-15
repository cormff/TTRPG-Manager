import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/user_role_provider.dart';
import 'package:ttrpg_manager/providers/notes_provider.dart';
import 'package:ttrpg_manager/models/note_model.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final userRoleProvider = Provider.of<UserRoleProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    
    final bool isGM = userRoleProvider.isGameMaster;
    final String username = userRoleProvider.username;
    final notes = isGM ? notesProvider.gmNotes : notesProvider.playerNotes;
    final String appBarTitle = '$username ${isGM ? 'GM' : 'Player'} Notes';

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
                    'No adventure notes yet.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    'Tap + to record your journey!',
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
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (note.tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getTagColor(note.tag!).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _getTagColor(note.tag!)),
                            ),
                            child: Text(
                              note.tag!,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getTagColor(note.tag!),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                          onPressed: () => _confirmDelete(context, notesProvider, note.id),
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
        label: const Text('New Note'),
      ),
    );
  }

  void _navigateToNoteForm(BuildContext context, {required bool isGM, Note? note}) {
    final bool isEditing = note != null;
    final titleController = TextEditingController(text: note?.title);
    final contentController = TextEditingController(text: note?.content);
    String? selectedTag = note?.tag;
    final List<String> tags = ['NPC', 'Quest', 'Loot', 'Location', 'Combat', 'Other'];

    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => Scaffold(
            appBar: AppBar(
              title: Text(isEditing ? 'Edit Note' : (isGM ? 'New GM Entry' : 'New Player Log')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final provider = Provider.of<NotesProvider>(context, listen: false);
                      if (isEditing) {
                        provider.updateNote(
                          note.id,
                          titleController.text,
                          contentController.text,
                          tag: selectedTag,
                        );
                      } else {
                        provider.addNote(
                          titleController.text,
                          contentController.text,
                          isGM ? NoteType.gm : NoteType.player,
                          tag: selectedTag,
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
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. The Mysterious Stranger',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: selectedTag,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: tags.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => selectedTag = val),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Details',
                      hintText: 'Write down what happened...',
                      border: OutlineInputBorder(),
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

  void _confirmDelete(BuildContext context, NotesProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteNote(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                label: Text(note.tag!, style: const TextStyle(fontSize: 12)),
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
            child: const Text('Back'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _navigateToNoteForm(context, isGM: isGM, note: note);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}
