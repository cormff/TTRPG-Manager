import 'equipment_view.dart';
import 'package:flutter/material.dart';
import 'races_view.dart';
import 'classes_view.dart';
import 'spells_view.dart';
import 'monsters_view.dart';
import 'package:ttrpg_manager/providers/language_manager.dart';

class RuleBooksView extends StatelessWidget {
  const RuleBooksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Rule Books')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildMenuCard(
            context,
            title: context.tr('Races'),
            subtitle: context.tr('Explore the diverse peoples of the world'),
            icon: Icons.groups_outlined,
            destination: const RacesView(),
          ),
          _buildMenuCard(
            context,
            title: context.tr('Classes'),
            subtitle: context.tr('Choose your path and abilities'),
            icon: Icons.shield_outlined,
            destination: const ClassesView(),
          ),
          _buildMenuCard(
            context,
            title: context.tr('Equipment'),
            subtitle: context.tr('Weapons, armor, tools, and adventuring gear'),
            icon: Icons.shopping_bag_outlined,
            destination: const EquipmentView(),
          ),
          _buildMenuCard(
            context,
            title: context.tr('Monsters'),
            subtitle: context.tr('Creatures, stats, legendary actions, and beasts'),
            icon: Icons.adb_rounded,
            destination: const MonstersView(),
          ),
          _buildMenuCard(
            context,
            title: context.tr('Spells'),
            subtitle: context.tr('Master the arcane and divine arts'),
            icon: Icons.auto_awesome_outlined,
            destination: const SpellsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Widget destination}) {
    // ÇÖZÜM: Aydınlık/Karanlık temaya göre dinamik renk
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
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
                child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    // ÇÖZÜM: Renk dinamiğe bağlandı
                    Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: textColor.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}