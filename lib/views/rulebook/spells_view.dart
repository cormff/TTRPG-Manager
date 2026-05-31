import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';

class SpellsView extends StatelessWidget {
  const SpellsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicRuleList(
      title: 'Spells',
      jsonPathEn: 'assets/data/spell.json',
      jsonPathTr: 'assets/data/spell_tr.json',
    );
  }
}