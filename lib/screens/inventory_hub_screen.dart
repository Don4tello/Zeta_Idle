import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'inventory_screen.dart';
import 'forge_screen.dart';
import 'rune_screen.dart';
import 'artifact_screen.dart';

class InventoryHubScreen extends StatelessWidget {
  const InventoryHubScreen({super.key});

  static const _tabs = [
    Tab(text: 'GEAR'),
    Tab(text: 'FORGE'),
    Tab(text: 'RUNES'),
    Tab(text: 'ARTIFACTS'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          title: Text(
            'INVENTORY',
            style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 3),
          ),
          bottom: TabBar(
            tabs: _tabs,
            labelStyle: GoogleFonts.pixelifySans(
                fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
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
            InventoryScreen(embedded: true),
            ForgeScreen(embedded: true),
            RuneScreen(embedded: true),
            ArtifactScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}
