import 'package:flutter/material.dart';
import 'shared/dynamic_rule_list.dart';
class EquipmentView extends StatelessWidget {
  const EquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    return DynamicRuleList(
      title: isTr ? 'Ekipman' : 'Equipment', // Buradaki isim JSON'daki en üstteki key ile aynı olmalı
      jsonPath: isTr ? 'assets/data/equipment_tr.json' : 'assets/data/equipment_en.json',
    );
  }
}