import 'package:flutter/material.dart';
import '../../services/game_service.dart';

class CreateGameView extends StatefulWidget {
  const CreateGameView({super.key});

  @override
  State<CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<CreateGameView> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _maxPlayers = 4;
  bool _isPublic = true;
  bool _isLoading = false;

  void _submitForm() async {
    setState(() => _isLoading = true);

    final success = await GameService().createGame(
      _titleController.text,
      _descController.text,
      _maxPlayers,
      _isPublic,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Campaign Created!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Campaign')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Campaign Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Max Players:"),
                DropdownButton<int>(
                  value: _maxPlayers,
                  items: [2, 3, 4, 5, 6, 8].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                  onChanged: (val) => setState(() => _maxPlayers = val!),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text("Public Game"),
              subtitle: const Text("Visible to everyone in search results"),
              value: _isPublic,
              onChanged: (val) => setState(() => _isPublic = val),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("Create Campaign"),
            ),
          ],
        ),
      ),
    );
  }
}