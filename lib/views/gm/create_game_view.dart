import 'package:flutter/material.dart';

class CreateGameView extends StatelessWidget {
  const CreateGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Game')),
      body: const Center(child: Text('Yeni kampanya oluşturma formu ve davet kodları.')),
    );
  }
}