import 'package:flutter/material.dart';
import '../data/patch_notes.dart';
import '../theme/app_theme.dart';

/// Scrollable "What's New" / patch-notes sheet. Latest build pinned at the top,
/// scroll down for the full history.
void showWhatsNew(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1B1A17),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (_) => const FractionallySizedBox(
      heightFactor: 0.85,
      child: _WhatsNewSheet(),
    ),
  );
}

class _WhatsNewSheet extends StatelessWidget {
  const _WhatsNewSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(children: [
              const Text('📣', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text("WHAT'S NEW",
                  style: AppTheme.pixelHeading(
                      fontSize: 14, letterSpacing: 2, color: AppTheme.accentGold)),
              const Spacer(),
              Text('Build $kLatestPatchBuild',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ]),
          ),
          const Divider(color: AppTheme.cardBorder, height: 14),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: kPatchNotes.length,
              itemBuilder: (_, i) => _PatchCard(note: kPatchNotes[i], latest: i == 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatchCard extends StatelessWidget {
  const _PatchCard({required this.note, required this.latest});
  final PatchNote note;
  final bool latest;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(
            color: latest
                ? AppTheme.accentGold.withValues(alpha: 0.5)
                : AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (latest)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text('LATEST',
                    style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            Expanded(
              child: Text(note.title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Text('#${note.build}',
                style: const TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 2),
          Text(note.date,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
          const SizedBox(height: 8),
          ...note.changes.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(color: AppTheme.accentGold, fontSize: 13, height: 1.35)),
                    Expanded(
                      child: Text(c,
                          style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.35)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
