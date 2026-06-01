import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';
class RacesView extends StatelessWidget {
  const RacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicRuleList(
      title: 'Races',
      jsonPath: 'assets/data/races.json',
    );
  }
}