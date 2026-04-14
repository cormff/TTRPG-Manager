import 'package:flutter/material.dart';

class MyGamesView extends StatelessWidget {
  const MyGamesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Games')),
      body: const Center(child: Text('Aktif ve arşivlenmiş kampanyalar burada listelenecek.')),
    );
  }
}