import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';
class ClassesView extends StatelessWidget {
  const ClassesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicRuleList(
      title: 'Classes',
      jsonPathEn: 'assets/data/classes.json',
      jsonPathTr: 'assets/data/classes_tr.json',
    );
  }
}