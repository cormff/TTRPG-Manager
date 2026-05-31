import 'equipment_view.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'races_view.dart';
import 'classes_view.dart';
import 'spells_view.dart';
import 'monsters_view.dart';

class RuleBooksView extends StatelessWidget {
  const RuleBooksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('ruleBooks')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildMenuCard(
            context,
            title: context.tr('rulebook.races'),
            subtitle: context.tr('rulebook.races.subtitle'),
            icon: Icons.groups_outlined,
            destination: const RacesView(),
          ),
          _buildMenuCard(
            context,
            title: context.tr('rulebook.classes'),
            subtitle: context.tr('rulebook.classes.subtitle'),
            icon: Icons.shield_outlined,
            destination: const ClassesView(),
          ),
          _buildMenuCard(
            context,
            title: context.tr('rulebook.equipment'),
            subtitle: context.tr('rulebook.equipment.subtitle'),
            icon: Icons
                .shopping_bag_outlined, // Ekipmanlar için güzel bir çanta ikonu
            destination: const EquipmentView(),
          ),
          _buildMenuCard(
            context,
            title: context.tr('rulebook.monsters'),
            subtitle: context.tr('rulebook.monsters.subtitle'),
            icon: Icons.adb_rounded, // Veya Icons.pets olabilir
            destination: const MonstersView(),
          ),
          _buildMenuCard(
            context,
            title: context.tr('rulebook.spells'),
            subtitle: context.tr('rulebook.spells.subtitle'),
            icon: Icons.auto_awesome_outlined,
            destination: const SpellsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget destination,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Tıklanıldığında hedef (destination) widget'ına (örn. RacesView) gidiyor.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
