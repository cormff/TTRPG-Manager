import 'package:flutter/material.dart';

class JoinGameView extends StatelessWidget {
  const JoinGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join a Game')),
      body: const Center(child: Text('Açık oyunları arama ve davet kodu giriş alanı.')),
    );
  }
}