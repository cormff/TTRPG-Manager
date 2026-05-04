import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/rule_models.dart';
import '../category_detail_view.dart';

class DynamicRuleList extends StatefulWidget {
  final String title;
  final String jsonPath;

  const DynamicRuleList({super.key, required this.title, required this.jsonPath});

  @override
  State<DynamicRuleList> createState() => _DynamicRuleListState();
}

class _DynamicRuleListState extends State<DynamicRuleList> {
  late Future<List<RuleCategory>> _futureRuleData;

  @override
  void initState() {
    super.initState();
    _futureRuleData = loadDataFromJson();
  }

  String? _getRuleImageUrl(String name) {
    final categoryTitle = widget.title.toLowerCase().trim();
    final itemName = name.trim().toLowerCase().replaceAll('-', '');

    if (categoryTitle.contains("race")) {
      return 'assets/images/races/$itemName.png';
    }

    if (categoryTitle.contains("class")) {
      return 'assets/images/classes/$itemName.png';
    }

    return null;
  }

  Future<List<RuleCategory>> loadDataFromJson() async {

    try {
      final String response = await rootBundle.loadString(widget.jsonPath);
      final data = await json.decode(response);

      List<RuleCategory> categories = [];
      final rootKey = data.keys.first;
      final rootMap = data[rootKey] as Map<String, dynamic>;

      rootMap.forEach((keyName, content) {
        List<RuleItem> items = [];
        Map<String, dynamic> traitsMap = {};

        // --- HATA GİDERİCİ MANTIK BURASI ---
        // Sadece bu özel anahtar kelimeleri içeren ve belli isimlere sahip olanları "Genel Bilgi" sayıyoruz.
        // Boylece "Acid Splash" gibi içinde 's' harfi geçen her şeyi genel bilgi sanmayacak.
        List<String> generalHeaders = ["Racial Traits", "Class Features", "Spellcasting Features", "Personal Characteristics"];
        bool isGeneral = generalHeaders.contains(keyName) ||
            (keyName.toLowerCase().contains("traits") && !keyName.contains("("));

        if (isGeneral || content is! Map) {
          traitsMap = content is Map ? Map<String, dynamic>.from(content) : {};
        } else {
          // Alt özellikleri (spelleri veya ırk özelliklerini) çekme mantığı
          String traitsKey = "$keyName Traits";
          String featuresKey = "$keyName Features";

          if (content[traitsKey] != null) {
            traitsMap = Map<String, dynamic>.from(content[traitsKey]);
            if (content['description'] != null) traitsMap['Description'] = content['description'];
          } else if (content[featuresKey] != null) {
            traitsMap = Map<String, dynamic>.from(content[featuresKey]);
            if (content['description'] != null) traitsMap['Description'] = content['description'];
          } else {
            traitsMap = Map<String, dynamic>.from(content);
          }
        }

        traitsMap.forEach((traitName, traitValue) {
          _processTrait(items, traitName, traitValue);
        });

        categories.add(RuleCategory(
          title: keyName,
          icon: isGeneral ? Icons.auto_stories : (widget.title == "Spells" ? Icons.auto_awesome : Icons.person_outline),
          items: items,
          isGeneralInfo: isGeneral,
          imageUrl: _getRuleImageUrl(keyName),
        ));
      });

      // Genel bilgileri en başa al
      categories.sort((a, b) => b.isGeneralInfo ? 1 : (a.isGeneralInfo ? -1 : 0));
      return categories;
    } catch (e) {
      return [];
    }

  }

  void _processTrait(List<RuleItem> items, String name, dynamic value, {int? parentLevel}) {
    int? currentLevel = parentLevel;
    final levelMatch = RegExp(r'Level\s+(\d+)').firstMatch(name);
    if (levelMatch != null) {
      currentLevel = int.tryParse(levelMatch.group(1) ?? '');
    }

    if (value is Map && !value.containsKey('table') && name.toLowerCase() != 'description') {
      value.forEach((subName, subValue) {
        _processTrait(items, subName, subValue, parentLevel: currentLevel);
      });
    } else {
      _addRuleItem(items, name, value, level: currentLevel);
    }
  }

  void _addRuleItem(List<RuleItem> items, String name, dynamic value, {int? level}) {
    String displayTitle = name.toLowerCase() == 'description' ? 'Overview' : name;

    int? finalLevel = level;
    if (finalLevel == null) {
      final levelMatch = RegExp(r'\(Level\s+(\d+)\)').firstMatch(name);
      if (levelMatch != null) {
        finalLevel = int.tryParse(levelMatch.group(1) ?? '');
      }
    }

    if (value is Map && value.isEmpty) return;

    items.add(RuleItem(
      title: displayTitle,
      description: _parseTraitValue(value).trim(),
      level: finalLevel,
    ));
  }

  String _parseTraitValue(dynamic value) {
    if (value is String) return value;
    if (value is List) return value.join(", ");
    if (value is Map) {
      if (value.containsKey('table')) {
        final table = value['table'] as Map<String, dynamic>;
        final description = value['description'] as String?;
        String result = description != null ? "$description\n\n" : "";

        List<String> columns = table.keys.toList();
        if (columns.isNotEmpty) {
          int rowCount = (table[columns[0]] as List).length;
          for (int i = 0; i < rowCount; i++) {
            List<String> rowValues = [];
            for (var col in columns) {
              rowValues.add("${table[col][i]}");
            }
            result += "• ${rowValues.join(' | ')}\n";
          }
        }
        return result;
      }

      String result = "";
      if (value.containsKey('description')) {
        result += "${value['description']}\n\n";
      }

      value.forEach((k, v) {
        if (k != 'description') {
          final parsedValue = _parseTraitValue(v);
          if (parsedValue.contains('\n')) {
            result += "[$k]\n$parsedValue\n\n";
          } else {
            result += "• $k: $parsedValue\n\n";
          }
        }
      });
      return result.trim();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<RuleCategory>>(
        future: _futureRuleData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No data found."));

          final ruleData = snapshot.data!;
          final generalItems = ruleData.where((c) => c.isGeneralInfo).toList();
          final raceItems = ruleData.where((c) => !c.isGeneralInfo).toList();

          return CustomScrollView(
            slivers: [
              if (generalItems.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildFeaturedGeneralInfo(context, generalItems.first),
                  ),
                ),
              if (raceItems.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final category = raceItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: category.imageUrl != null
                                  ? Image.asset(
                                category.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(category.icon, size: 20),
                              )
                                  : Icon(category.icon, size: 20),
                            ),
                            title: Text(category.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: const Icon(Icons.chevron_right, size: 18),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailView(category: category))),
                          ),
                        );
                      },
                      childCount: raceItems.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeaturedGeneralInfo(BuildContext context, RuleCategory category) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailView(category: category))),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, color: Colors.white, size: 44),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Text("CORE RULES & GUIDES", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                      const SizedBox(height: 8),
                      Text(category.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      // --- İŞTE DEĞİŞİKLİĞİ BURAYA YAPTIK ---
                      Text(
                        widget.title == "Spells"
                            ? "Everything you need to know about slots, concentration and components."
                            : "Essential mechanics and shared traits every player should know.",
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}