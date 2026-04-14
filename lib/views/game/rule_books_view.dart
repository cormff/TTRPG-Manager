import 'package:flutter/material.dart';

class RuleBooksView extends StatelessWidget {
  const RuleBooksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rule Books')),
      body: const Center(child: Text('Mechanics and reference documents.')),
    );
  }
}