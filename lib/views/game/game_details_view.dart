import 'package:flutter/material.dart';
import '../../models/game_model.dart';
import 'package:provider/provider.dart';
import '../../providers/games_provider.dart';

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

  // İptal edilirse geri dönülecek "son kaydedilmiş" verileri tutuyoruz
  late String _currentTitle;
  late String _currentDesc;
  late int _currentMaxPlayers;
  late bool _currentIsPublic;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // İlk açılışta widget'tan gelen verileri alıyoruz
    _currentTitle = widget.game.title;
    _currentDesc = widget.game.description;
    _currentMaxPlayers = widget.game.maxPlayers;
    _currentIsPublic = widget.game.isPublic;

    _titleController = TextEditingController(text: _currentTitle);
    _descController = TextEditingController(text: _currentDesc);
    _maxPlayers = _currentMaxPlayers;
    _isPublic = _currentIsPublic;
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
        // Düzenlemekten vazgeçilirse son kaydedilmiş (current) verilere geri dön
        _titleController.text = _currentTitle;
        _descController.text = _currentDesc;
        _maxPlayers = _currentMaxPlayers;
        _isPublic = _currentIsPublic;
      }
    });
  }

  Future<void> _saveChanges() async {
    if (widget.game.id == null) return; // ID yoksa kaydetme (Güvenlik)

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
      // Başarılı olursa "son kaydedilmiş" verileri yeni değerlerle güncelle
      _currentTitle = _titleController.text;
      _currentDesc = _descController.text;
      _currentMaxPlayers = _maxPlayers;
      _currentIsPublic = _isPublic;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Oyun başarıyla güncellendi!"), backgroundColor: Colors.green),
        );
        setState(() => _isEditing = false); // Düzenleme modundan çık
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Güncelleme başarısız oldu. Sunucuyu kontrol edin."), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final primaryLight = theme.primaryColorLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Oyunu Düzenle' : widget.game.title),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                // Düzenlemeden vazgeçilirse eski verilere dön
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BİLGİ / DÜZENLEME FORMU ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                // Karta çok hafif mor bir dış çerçeve ekliyoruz
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
                      style: const TextStyle(color: Colors.white70),
                      decoration: InputDecoration(
                        labelText: 'Oyun Adı',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // Mor Etiket
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(color: primaryColor.withOpacity(0.4), thickness: 1), // Yarı saydam mor çizgi

                    TextField(
                      controller: _descController,
                      enabled: _isEditing,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white70),
                      decoration: InputDecoration(
                        labelText: 'Hikaye / Açıklama',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), // Mor Etiket
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(color: primaryColor.withOpacity(0.4), thickness: 1), // Yarı saydam mor çizgi

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Maksimum Oyuncu:", style: TextStyle(color: primaryLight, fontSize: 16)), // Mor Etiket
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
                    Divider(color: primaryColor.withOpacity(0.4), thickness: 1), // Yarı saydam mor çizgi

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Herkese Açık (Public)", style: TextStyle(color: primaryLight, fontSize: 16)),

                      // Yuvarlak kısım (thumb) açıkken beyaz olsun
                      activeColor: Colors.white,
                      // Arka plan (track) açıkken mor olsun
                      activeTrackColor: primaryColor,

                      // İstersen kapalıykenki renkleri de özelleştirebilirsin:
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
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text("Değişiklikleri Kaydet"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            // --- HARİTA KISMI ---
            if (!_isEditing) ...[
              const SizedBox(height: 24),
              Text("Bağlı Haritalar", style: theme.textTheme.titleLarge?.copyWith(color: primaryLight)), // Mor Başlık
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  // Harita kutucuğunun dış çizgisi mor yapıldı
                  border: Border.all(color: primaryColor.withOpacity(0.5), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(Icons.map, size: 40, color: primaryColor.withOpacity(0.7)), // İkon morlaştırıldı
                    const SizedBox(height: 8),
                    Text("Henüz bu oyuna harita bağlanmamış.", style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}