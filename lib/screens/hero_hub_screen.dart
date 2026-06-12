import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'ability_upgrade_screen.dart';
import 'hero_stats_screen.dart';
import 'passive_tree_screen.dart';
import 'prestige_screen.dart';
import 'ascension_screen.dart';

class HeroHubScreen extends StatelessWidget {
  const HeroHubScreen({super.key, this.onBackToSelect});

  final VoidCallback? onBackToSelect;

  static const _tabs = [
    Tab(text: 'SHEET'),
    Tab(text: 'ABILITIES'),
    Tab(text: 'PASSIVES'),
    Tab(text: 'BONUSES'),
    Tab(text: 'REBIRTH'),
    Tab(text: 'ASCEND'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          title: Text(
            'HERO',
            style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 3),
          ),
          actions: [
            if (onBackToSelect != null)
              TextButton(
                onPressed: onBackToSelect,
                child: Text(
                  'CHANGE',
                  style: AppTheme.pixelHeading(
                      fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1),
                ),
              ),
            const SizedBox(width: 4),
          ],
          bottom: TabBar(
            tabs: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: GoogleFonts.pixelifySans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            unselectedLabelStyle:
                GoogleFonts.pixelifySans(fontSize: 10, letterSpacing: 1),
            labelColor: AppTheme.accentGold,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.accentGold,
            indicatorWeight: 2,
          ),
        ),
        body: const TabBarView(
          children: [
            DashboardScreen(embedded: true),
            AbilityUpgradeScreen(embedded: true),
            PassiveTreeScreen(embedded: true),
            HeroStatsScreen(embedded: true),
            PrestigeScreen(embedded: true),
            AscensionScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}
