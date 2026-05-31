import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';
class ClassesView extends StatelessWidget {
  const ClassesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    return DynamicRuleList(
      title: isTr ? 'Sınıflar' : 'Classes',
      jsonPath: isTr ? 'assets/data/classes_tr.json' : 'assets/data/classes_en.json',
    );
  }
}