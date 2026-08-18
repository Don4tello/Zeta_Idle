import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dnd_class.dart';
import '../models/hero_model.dart' show HeroGender;

class CharacterSummary {
  const CharacterSummary({
    required this.slot,
    required this.name,
    required this.level,
    this.heroClass,
    this.prestigeLevel = 0,
    this.totalAscensionAp = 0,
    this.gender,
  });
  final int slot;
  final String name;
  final int level;
  final DndClass? heroClass;
  final int prestigeLevel;
  final int totalAscensionAp; // cumulative Ascension Points ever earned (endgame reach)
  final HeroGender? gender;
}

class SaveService {
  static const String _savePrefix        = 'zeta_idle_save_';
  static const String _extraSlotsKey     = 'zeta_idle_extra_slots';
  static const String _welcomeSeenKey    = 'zeta_idle_welcome_seen';
  static const String _prestigePrefix    = 'zeta_pl_';
  static const int maxSlots     = 12;
  static const int defaultSlots = 3;
  static const int maxExtraSlots = maxSlots - defaultSlots; // 9 purchasable

  static Future<bool> isWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeSeenKey) ?? false;
  }

  static Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeSeenKey, true);
  }

  Future<void> saveRaw(Map<String, dynamic> rawData, {int slot = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_savePrefix$slot';
    // Roll the current good save into a backup key before overwriting, so a
    // corrupt or interrupted write can never leave the player with no copy.
    final existing = prefs.getString(key);
    if (existing != null && existing.isNotEmpty) {
      await prefs.setString('${key}_bak', existing);
    }
    await prefs.setString(key, jsonEncode(rawData));
  }

  Future<Map<String, dynamic>?> loadRaw({int slot = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_savePrefix$slot';
    // Try the primary save, then the rolling backup if the primary is missing
    // or fails to parse (corruption recovery).
    for (final k in [key, '${key}_bak']) {
      final raw = prefs.getString(k);
      if (raw == null || raw.isEmpty) continue;
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        // fall through to the next candidate
      }
    }
    return null;
  }

  static Future<int> getExtraSlots() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_extraSlotsKey) ?? 0).clamp(0, maxExtraSlots);
  }

  static Future<void> setExtraSlots(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_extraSlotsKey, count.clamp(0, maxExtraSlots));
  }

  Future<List<CharacterSummary?>> listCharacters(int totalSlots) async {
    final prefs = await SharedPreferences.getInstance();
    return List.generate(totalSlots, (i) {
      final raw = prefs.getString('$_savePrefix$i');
      if (raw == null) return null;
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final hero = data['hero'] as Map<String, dynamic>;
        final jsonPl  = (data['prestigeLevel'] as int?) ?? 0;
        final directPl = prefs.getInt('$_prestigePrefix$i') ?? 0;
        return CharacterSummary(
          slot: i,
          name: hero['name'] as String,
          level: hero['level'] as int,
          heroClass: DndClass.tryParse(hero['heroClass'] as String?),
          prestigeLevel: jsonPl > directPl ? jsonPl : directPl,
          totalAscensionAp: (data['totalAscensionAp'] as int?) ?? 0,
          gender: HeroGender.tryParse(hero['gender'] as String?),
        );
      } catch (_) {
        return null;
      }
    });
  }

  Future<void> deleteSlot(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_savePrefix$slot');
    await prefs.remove('$_savePrefix${slot}_bak');
    await prefs.remove('$_prestigePrefix$slot');
  }

  /// Wipe every local save slot + backups + metadata. Used by account deletion.
  Future<void> wipeAllLocal() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(_savePrefix) || key.startsWith(_prestigePrefix)) {
        await prefs.remove(key);
      }
    }
    await prefs.remove(_welcomeSeenKey);
    await prefs.remove(_extraSlotsKey);
  }

  Future<void> savePrestigeLevel(int slot, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prestigePrefix$slot', level);
  }

  Future<int> loadPrestigeLevel(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prestigePrefix$slot') ?? 0;
  }
}
