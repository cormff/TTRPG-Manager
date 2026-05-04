import 'package:flutter/material.dart';
import '../../models/rule_models.dart';

class CategoryDetailView extends StatelessWidget {
  final RuleCategory category;
  const CategoryDetailView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // 1. DEĞİŞİKLİK: Kategori "Genel Bilgi" ise resim alanını tamamen iptal et.
    final bool hasImage = category.imageUrl != null && !category.isGeneralInfo;

    final coreItems = category.items.where((i) => i.level == null).toList();
    final levelItems = category.items.where((i) => i.level != null).toList();

    levelItems.sort((a, b) => (a.level ?? 0).compareTo(b.level ?? 0));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 240 : null,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // Başlığı ortalamak daha şık durur
              title: Text(
                category.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: hasImage ? [const Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 2))] : null,
                ),
              ),
              background: hasImage
                  ? Image.asset(
                category.imageUrl!,
                fit: BoxFit.contain,
                // 2. DEĞİŞİKLİK: "Image not found" yazısını kaldırıp sade bir kitap ikonu koyduk
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.auto_stories, color: Colors.white, size: 48),
                ),
              )
                  : null,
            ),
          ),
          if (coreItems.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text("CORE FEATURES", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12, color: Colors.grey)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildItemCard(context, coreItems[index]),
                  childCount: coreItems.length,
                ),
              ),
            ),
          ],
          if (levelItems.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text("CLASS PROGRESSION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12, color: Colors.grey)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildItemCard(context, levelItems[index]),
                  childCount: levelItems.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, RuleItem rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(
          rule.level != null ? Icons.trending_up : (category.isGeneralInfo ? Icons.bookmark_added_outlined : Icons.star_border_rounded),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(rule.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(rule.description, style: const TextStyle(fontSize: 15, height: 1.6)),
          ),
        ],
      ),
    );
  }
}