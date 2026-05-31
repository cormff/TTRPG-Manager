import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';
class EquipmentView extends StatelessWidget {
  const EquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicRuleList(
      title: 'Equipment',
      jsonPathEn: 'assets/data/equipment.json',
      jsonPathTr: 'assets/data/equipment_tr.json',
    );
  }
}