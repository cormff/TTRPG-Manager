import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';
class EquipmentView extends StatelessWidget {
  const EquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DynamicRuleList(
      title: 'Equipment', // Buradaki isim JSON'daki en üstteki key ile aynı olmalı
      jsonPath: 'assets/data/equipment.json',
    );
  }
}