import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';

class SpellsView extends StatelessWidget {
  const SpellsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    return DynamicRuleList(
      title: isTr ? 'Büyüler' : 'Spells',
      jsonPath: isTr ? 'assets/data/spell_tr.json' : 'assets/data/spell_en.json',
    );
  }
}