import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';

class MonstersView extends StatelessWidget {
  const MonstersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    return DynamicRuleList(
      title: isTr ? 'Canavarlar' : 'Monsters', // JSON'daki anahtar kelime ile aynı olmalı
      jsonPath: isTr ? 'assets/data/monsters_tr.json' : 'assets/data/monsters_en.json',
    );
  }
}