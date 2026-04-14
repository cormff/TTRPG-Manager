import 'package:flutter/material.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campaign Notes')),
      body: const Center(child: Text('Kişisel notlar ve kampanya günlüğü.')),
    );
  }
}