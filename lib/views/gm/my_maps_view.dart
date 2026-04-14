import 'package:flutter/material.dart';

class MyMapsView extends StatelessWidget {
  const MyMapsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Maps')),
      body: const Center(child: Text('Dünya haritaları ve savaş alanları deposu.')),
    );
  }
}