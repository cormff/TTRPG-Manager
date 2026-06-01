import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/rule_models.dart';
import '../category_detail_view.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';

class DynamicRuleList extends StatefulWidget {
  final String title;
  final String jsonPath;

  const DynamicRuleList({super.key, required this.title, required this.jsonPath});

  @override
  State<DynamicRuleList> createState() => _DynamicRuleListState();
}

class _DynamicRuleListState extends State<DynamicRuleList> {
  Future<List<RuleCategory>>? _futureRuleData;
  String? _currentLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dil değiştiği an JSON dosyasını yeniden yükleyen sihirli yapı!
    final lang = Provider.of<LanguageManager>(context).currentLocale.languageCode;
    if (_currentLang != lang || _futureRuleData == null) {
      _currentLang = lang;
      _futureRuleData = loadDataFromJson(lang);
    }
  }

  String? _getRuleImageUrl(String name) {
    final lowerName = name.toLowerCase();
    // Resim aranmayacak anahtar kelimeler (TR + EN)
    if (lowerName.contains('traits') || lowerName.contains('features') || lowerName.contains('overview') ||
        lowerName.contains('özellikleri') || lowerName.contains('açıklama') || lowerName.contains('kuralları')) {
      return null;
    }

    final categoryTitle = widget.title.toLowerCase().trim();
    String itemName = name.trim().toLowerCase().replaceAll('-', '').replaceAll(' ', '');

    // ÇÖZÜM: Türkçe kategori isimlerini resim dosyalarının İngilizce isimleriyle eşleştiriyoruz!
    final Map<String, String> trToEn = {
      'cüce': 'dwarf', 'elf': 'elf', 'buçukluk': 'halfling', 'i̇nsan': 'human', 'insan': 'human',
      'ejderdoğan': 'dragonborn', 'gnom': 'gnome', 'yarıelf': 'halfelf', 'yarıork': 'halforc', 'tiefling': 'tiefling',
      'barbar': 'barbarian', 'ozan': 'bard', 'ruhban': 'cleric', 'druid': 'druid', 'savaşçı': 'fighter',
      'keşiş': 'monk', 'paladin': 'paladin', 'kolcu': 'ranger', 'düzenbaz': 'rogue', 'büyücü': 'sorcerer',
      'warlock': 'warlock', 'sihirbaz': 'wizard'
    };

    if (trToEn.containsKey(itemName)) {
      itemName = trToEn[itemName]!;
    }

    if (categoryTitle.contains("race")) {
      return 'assets/images/races/$itemName.png';
    }

    if (categoryTitle.contains("class")) {
      return 'assets/images/classes/$itemName.png';
    }

    return null;
  }

  Future<List<RuleCategory>> loadDataFromJson(String lang) async {
    // ÇÖZÜM: Seçili dile göre _tr.json dosyasını yükleme mantığı
    String finalPath = widget.jsonPath;
    if (lang == 'tr') {
      if (widget.jsonPath.contains('spell.json')) {
        finalPath = widget.jsonPath.replaceAll('spell.json', 'spell_tr.json');
      } else {
        finalPath = widget.jsonPath.replaceAll('.json', '_tr.json');
      }
    }

    try {
      final String response = await rootBundle.loadString(finalPath);
      final data = await json.decode(response);

      List<RuleCategory> categories = [];
      final rootKey = data.keys.first;
      final rootMap = data[rootKey] as Map<String, dynamic>;

      rootMap.forEach((keyName, content) {
        List<RuleItem> items = [];
        Map<String, dynamic> traitsMap = {};

        // TR ve EN Genel Başlıklar
        List<String> generalHeaders = [
          "Racial Traits", "Class Features", "Spellcasting Features", "Personal Characteristics", "Equipment Rules", "Monster Rules",
          "Irk Özellikleri", "Sınıf Özellikleri", "Büyü Yapma Özellikleri", "Kişisel Özellikler", "Ekipman Kuralları", "Canavar Kuralları"
        ];

        bool isGeneral = generalHeaders.contains(keyName) ||
            (keyName.toLowerCase().contains("traits") && !keyName.contains("(")) ||
            (keyName.toLowerCase().contains("özellikleri") && !keyName.contains("("));

        if (isGeneral || content is! Map) {
          traitsMap = content is Map ? Map<String, dynamic>.from(content) : {};
        } else {
          String traitsKey = "$keyName Traits";
          String featuresKey = "$keyName Features";
          String trOzelliklerKey = "$keyName Özellikleri";

          if (content[traitsKey] != null) {
            traitsMap = Map<String, dynamic>.from(content[traitsKey]);
            if (content['description'] != null) traitsMap['description'] = content['description'];
            if (content['açıklama'] != null) traitsMap['açıklama'] = content['açıklama'];
          } else if (content[featuresKey] != null) {
            traitsMap = Map<String, dynamic>.from(content[featuresKey]);
            if (content['description'] != null) traitsMap['description'] = content['description'];
            if (content['açıklama'] != null) traitsMap['açıklama'] = content['açıklama'];
          } else if (content[trOzelliklerKey] != null) {
            traitsMap = Map<String, dynamic>.from(content[trOzelliklerKey]);
            if (content['description'] != null) traitsMap['description'] = content['description'];
            if (content['açıklama'] != null) traitsMap['açıklama'] = content['açıklama'];
          } else {
            traitsMap = Map<String, dynamic>.from(content);
          }
        }

        traitsMap.forEach((traitName, traitValue) {
          _processTrait(items, traitName, traitValue, lang: lang);
        });

        categories.add(RuleCategory(
          title: keyName,
          icon: isGeneral ? Icons.auto_stories : (widget.title == "Spells" ? Icons.auto_awesome : (widget.title == "Monsters" ? Icons.pets : Icons.bookmark_border)),
          items: items,
          isGeneralInfo: isGeneral,
          imageUrl: isGeneral ? null : _getRuleImageUrl(keyName),
        ));
      });

      categories.sort((a, b) => b.isGeneralInfo ? 1 : (a.isGeneralInfo ? -1 : 0));
      return categories;
    } catch (e) {
      return [];
    }
  }

  void _processTrait(List<RuleItem> items, String name, dynamic value, {int? parentLevel, required String lang}) {
    int? currentLevel = parentLevel;
    // ÇÖZÜM: Hem "Level 1" hem "Seviye 1" okuyabilen Regex
    final levelMatch = RegExp(r'(?:Level|Seviye)\s+(\d+)').firstMatch(name);
    if (levelMatch != null) {
      currentLevel = int.tryParse(levelMatch.group(1) ?? '');
    }

    if (value is! Map) {
      _addRuleItem(items, name, value, level: currentLevel, lang: lang);
      return;
    }

    if (value.containsKey('table') || value.containsKey('tablo')) {
      _addRuleItem(items, name, value, level: currentLevel, lang: lang);
      return;
    }

    if (widget.title == "Equipment" && (value.containsKey('description') || value.containsKey('açıklama')) && (name.toLowerCase() != 'description' && name.toLowerCase() != 'açıklama')) {
      final String overviewTitle = (name.toLowerCase() == 'description' || name.toLowerCase() == 'açıklama')
          ? (lang == 'tr' ? 'Genel Bakış' : 'Overview')
          : "$name (${lang == 'tr' ? 'Genel Bakış' : 'Overview'})";

      _addRuleItem(items, overviewTitle, value['description'] ?? value['açıklama'], level: currentLevel, lang: lang);

      value.forEach((subName, subValue) {
        if (subName != 'description' && subName != 'açıklama') {
          _processTrait(items, subName, subValue, parentLevel: currentLevel, lang: lang);
        }
      });
      return;
    }

    bool isLeafObject = value.containsKey('description') || value.containsKey('açıklama');

    if (!isLeafObject && name.toLowerCase() != 'description' && name.toLowerCase() != 'açıklama') {
      value.forEach((subName, subValue) {
        _processTrait(items, subName, subValue, parentLevel: currentLevel, lang: lang);
      });
    } else {
      _addRuleItem(items, name, value, level: currentLevel, lang: lang);
    }
  }

  void _addRuleItem(List<RuleItem> items, String name, dynamic value, {int? level, required String lang}) {
    String displayTitle = (name.toLowerCase() == 'description' || name.toLowerCase() == 'açıklama')
        ? (lang == 'tr' ? 'Genel Bakış' : 'Overview')
        : name;

    int? finalLevel = level;
    if (finalLevel == null) {
      final levelMatch = RegExp(r'\((?:Level|Seviye)\s+(\d+)\)').firstMatch(name);
      if (levelMatch != null) {
        finalLevel = int.tryParse(levelMatch.group(1) ?? '');
      }
    }

    if (value is Map && value.isEmpty) return;

    if (widget.title == "Equipment" && value is Map && (value.containsKey('table') || value.containsKey('tablo'))) {
      final table = (value['table'] ?? value['tablo']) as Map<String, dynamic>;
      final String? tableDescription = value['description'] ?? value['açıklama'];
      final columns = table.keys.toList();

      if (columns.isNotEmpty) {
        int rowCount = 0;
        for (var col in columns) {
          if (table[col] is List && (table[col] as List).length > rowCount) {
            rowCount = (table[col] as List).length;
          }
        }

        for (int i = 0; i < rowCount; i++) {
          final idCol = columns[0];
          final colList = table[idCol] as List;
          final itemName = i < colList.length ? colList[i].toString() : "Item ${i + 1}";

          String itemDetails = "";
          if (tableDescription != null) itemDetails += "$tableDescription\n\n";

          for (int j = 1; j < columns.length; j++) {
            final colName = columns[j];
            final dataList = table[colName] as List;
            final val = i < dataList.length ? dataList[i].toString() : "—";
            itemDetails += "• $colName: $val\n";
          }

          items.add(RuleItem(
            title: itemName,
            description: itemDetails.trim(),
            level: finalLevel,
          ));
        }
        return;
      }
    }

    items.add(RuleItem(
      title: displayTitle,
      description: _parseTraitValue(value).trim(),
      level: finalLevel,
    ));
  }

  String _parseTraitValue(dynamic value, {int depth = 0}) {
    if (depth > 5) return "...";

    String indent = List.filled(depth * 2, ' ').join();

    if (value is String) return value;

    if (value is List) {
      if (value.every((element) => element is String)) {
        return value.map((e) => "$indent• $e").join('\n');
      }
      return value.map((e) => _parseTraitValue(e, depth: depth + 1)).join('\n');
    }

    if (value is Map) {
      if (value.containsKey('table') || value.containsKey('tablo')) {
        final table = (value['table'] ?? value['tablo']) as Map<String, dynamic>;
        final description = (value['description'] ?? value['açıklama']) as String?;
        String result = description != null ? "$indent$description\n\n" : "";

        List<String> columns = table.keys.toList();
        if (columns.isNotEmpty) {
          int maxRows = 0;
          for (var col in columns) {
            if (table[col] is List) {
              int colLen = (table[col] as List).length;
              if (colLen > maxRows) maxRows = colLen;
            }
          }

          result += "$indent${columns.join(' | ')}\n";
          result += "$indent${List.filled(columns.length * 5, '-').join()}\n";

          for (int i = 0; i < maxRows; i++) {
            List<String> rowValues = [];
            for (var col in columns) {
              if (table[col] is List) {
                final List colList = table[col] as List;
                rowValues.add(i < colList.length ? "${colList[i]}" : "—");
              } else {
                rowValues.add("—");
              }
            }
            result += "$indent${rowValues.join(' | ')}\n";
          }
        }
        return result;
      }

      String result = "";
      if (value.containsKey('description') || value.containsKey('açıklama')) {
        final desc = value['description'] ?? value['açıklama'];
        if (desc is String) {
          result += "$indent$desc\n\n";
        } else {
          result += _parseTraitValue(desc, depth: depth) + "\n\n";
        }
      }

      if (value.containsKey('content') || value.containsKey('içerik')) {
        final cont = value['content'] ?? value['içerik'];
        result += _parseTraitValue(cont, depth: depth) + "\n\n";
      }

      value.forEach((k, v) {
        if (k != 'content' && k != 'description' && k != 'table' && k != 'açıklama' && k != 'tablo' && k != 'içerik') {
          result += "$indent[$k]\n";
          result += _parseTraitValue(v, depth: depth + 1) + "\n\n";
        }
      });
      return result.trimRight();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(widget.title))),
      body: FutureBuilder<List<RuleCategory>>(
        future: _futureRuleData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(context.tr('No data found.')));

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
                        child: Text(context.tr('CORE RULES & GUIDES'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                      const SizedBox(height: 8),
                      Text(category.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        widget.title == "Spells"
                            ? context.tr("Everything you need to know about slots, concentration and components.")
                            : widget.title == "Equipment"
                            ? context.tr("Core rules for armor, weapons, wealth, and item management.")
                            : widget.title == "Monsters"
                            ? context.tr("Rules for creature stats, sizes, challenge ratings, and actions.")
                            : context.tr("Essential mechanics and shared traits every player should know."),
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