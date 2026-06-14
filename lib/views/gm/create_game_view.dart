import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/games_provider.dart';
import '../../providers/user_role_provider.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';

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

  void _submitForm(String successMsg, String errorMsg) async {
    final currentUserId = Provider.of<UserRoleProvider>(context, listen: false).userId;
    if (currentUserId == null) return;

    setState(() => _isLoading = true);

    final success = await Provider.of<GamesProvider>(context, listen: false).createGame(
      _titleController.text,
      _descController.text,
      _maxPlayers,
      _isPublic,
      currentUserId,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: Colors.green,
        ),
      );

      // ÇÖZÜM BURADA: Sayfaların üst üste binmesini kesin olarak engelliyoruz!
      // 1. Önce "Ana Menü" (Dashboard) hariç açık olan tüm sayfaları (eski Oyunlarım sayfası dahil) kapatır.
      Navigator.of(context).popUntil((route) => route.isFirst);
      // 2. Ardından tek ve taptaze bir "Oyunlarım" sayfası açar.
      Navigator.of(context).pushNamed('/my_games_gm_view');

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final successMsg = context.tr('Oyun Başarıyla Oluşturuldu!');
    final errorMsg = context.tr('Oyun oluşturulurken hata oluştu!');

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Create New Campaign'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  labelText: context.tr('Campaign Title'),
                  border: const OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                  labelText: context.tr('Description'),
                  border: const OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('Max Players:')),
                DropdownButton<int>(
                  value: _maxPlayers,
                  items: [2, 3, 4, 5, 6, 8].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                  onChanged: (val) => setState(() => _maxPlayers = val!),
                ),
              ],
            ),
            SwitchListTile(
              title: Text(context.tr('Public Game')),
              subtitle: Text(context.tr('Visible to everyone in search results')),
              value: _isPublic,
              onChanged: (val) => setState(() => _isPublic = val),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () => _submitForm(successMsg, errorMsg),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text(context.tr('Create Campaign')),
            ),
          ],
        ),
      ),
    );
  }
}