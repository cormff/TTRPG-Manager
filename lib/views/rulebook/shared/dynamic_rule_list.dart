import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/rule_models.dart';
import '../category_detail_view.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';

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
    final lowerName = name.toLowerCase();
    // Genel başlıklar veya açıklama içeren alt başlıklar için resim arama
    if (lowerName.contains('traits') || lowerName.contains('features') || lowerName.contains('overview')) return null;

    final categoryTitle = widget.title.toLowerCase().trim();
    final itemName = name.trim().toLowerCase().replaceAll('-', '').replaceAll(' ', '');

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
        List<String> generalHeaders = ["Racial Traits", "Class Features", "Spellcasting Features", "Personal Characteristics", "Equipment Rules", "Monster Rules"];
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
          icon: isGeneral ? Icons.auto_stories : (widget.title == "Spells" ? Icons.auto_awesome : (widget.title == "Monsters" ? Icons.pets : Icons.bookmark_border)),
          items: items,
          isGeneralInfo: isGeneral,
          imageUrl: isGeneral ? null : _getRuleImageUrl(keyName),
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

    if (value is! Map) {
      _addRuleItem(items, name, value, level: currentLevel);
      return;
    }

    // 1. Tablo objesi ise (Expansion happens in _addRuleItem)
    if (value.containsKey('table')) {
      _addRuleItem(items, name, value, level: currentLevel);
      return;
    }

    // 2. Equipment için: Eğer bir açıklama varsa bunu ekle ve alt öğelere devam et (Konteyner mantığı)
    if (widget.title == "Equipment" && value.containsKey('description') && name.toLowerCase() != 'description') {
      final String overviewTitle = name.toLowerCase() == 'description' ? 'Overview' : "$name (Overview)";
      _addRuleItem(items, overviewTitle, value['description'], level: currentLevel);
      
      value.forEach((subName, subValue) {
        if (subName != 'description') {
          _processTrait(items, subName, subValue, parentLevel: currentLevel);
        }
      });
      return;
    }

    // 3. Spells veya diğerleri için LeafObject kontrolü
    bool isLeafObject = value.containsKey('description');

    if (!isLeafObject && name.toLowerCase() != 'description') {
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

    // --- EQUIPMENT TABLO GENİŞLETME ---
    if (widget.title == "Equipment" && value is Map && value.containsKey('table')) {
      final table = value['table'] as Map<String, dynamic>;
      final String? tableDescription = value['description'];
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

  // Eski _parseTraitValue fonksiyonunu tamamen silip bunu yapıştırın:

  String _parseTraitValue(dynamic value, {int depth = 0}) {
    // Sonsuz döngüyü engellemek için maksimum derinlik
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
      if (value.containsKey('table')) {
        final table = value['table'] as Map<String, dynamic>;
        final description = value['description'] as String?;
        String result = description != null ? "$indent$description\n\n" : "";

        List<String> columns = table.keys.toList();
        if (columns.isNotEmpty) {
          int maxRows = 0;
          // Güvenli satır sayma
          for (var col in columns) {
            if (table[col] is List) {
              int colLen = (table[col] as List).length;
              if (colLen > maxRows) maxRows = colLen;
            }
          }

          result += "$indent${columns.join(' | ')}\n";
          result += "$indent${List.filled(columns.length * 5, '-').join()}\n";

          // Güvenli içerik okuma (Satır 274'teki sorunu çözen kısım)
          for (int i = 0; i < maxRows; i++) {
            List<String> rowValues = [];
            for (var col in columns) {
              if (table[col] is List) {
                final List colList = table[col] as List; // as List olarak zorluyoruz
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
      // Eğer description varsa önce onu bas (Spells vb. için)
      if (value.containsKey('description')) {
        final desc = value['description'];
        if (desc is String) {
          result += "$indent$desc\n\n";
        } else {
          result += _parseTraitValue(desc, depth: depth) + "\n\n";
        }
      }

      // SADECE content varsa önce onu bas.
      if (value.containsKey('content')) {
        result += _parseTraitValue(value['content'], depth: depth) + "\n\n";
      }

      value.forEach((k, v) {
        if (k != 'content' && k != 'description' && k != 'table') {
          // Alt başlıkları göster
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
      appBar: AppBar(title: Text(widget.title)),
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
                        child: Text(context.tr('CORE RULES & GUIDES'), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                      const SizedBox(height: 8),
                      Text(category.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      // --- İŞTE DEĞİŞİKLİĞİ BURAYA YAPTIK ---
                      Text(
                        widget.title == "Spells"
                            ? "Everything you need to know about slots, concentration and components."
                            : widget.title == "Equipment"
                            ? "Core rules for armor, weapons, wealth, and item management."
                            : widget.title == "Monsters" // <-- Yeni Eklenti
                            ? "Rules for creature stats, sizes, challenge ratings, and actions."
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