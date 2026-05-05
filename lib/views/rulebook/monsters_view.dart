import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';

class MonstersView extends StatelessWidget {
  const MonstersView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicRuleList(
      title: 'Monsters', // JSON'daki anahtar kelime ile aynı olmalı
      jsonPath: 'assets/data/monsters.json',
    );
  }
}