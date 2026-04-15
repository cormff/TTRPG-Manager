// lib/views/player/my_games_player_view.dart
import 'package:flutter/material.dart';

class MyGamesPlayerView extends StatelessWidget {
  const MyGamesPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Katıldığın Oyunlar Burada Görünecek',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      ),
    );
  }
}