import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';
class RacesView extends StatelessWidget {
  const RacesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    return DynamicRuleList(
      title: isTr ? 'Irklar' : 'Races',
      jsonPath: isTr ? 'assets/data/races_tr.json' : 'assets/data/races_en.json',
    );
  }
}