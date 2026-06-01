import 'package:flutter/material.dart';

class RuleCategory {
  final String title;
  final IconData icon;
  final List<RuleItem> items;
  final bool isGeneralInfo;
  final String? imageUrl;

  RuleCategory({
    required this.title,
    required this.icon,
    required this.items,
    this.isGeneralInfo = false,
    this.imageUrl,
  });
}

class RuleItem {
  final String title;
  final String description;
  final int? level;

  RuleItem({required this.title, required this.description, this.level});
}