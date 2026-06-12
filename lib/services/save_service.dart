import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dnd_class.dart';

class CharacterSummary {
  const CharacterSummary({
    required this.slot,
    required this.name,
    required this.level,
    this.heroClass,
    this.prestigeLevel = 0,
  });
  final int slot;
  final String name;
  final int level;
  final DndClass? heroClass;
  final int prestigeLevel;
}

class SaveService {
  static const String _savePrefix        = 'zeta_idle_save_';
  static const String _extraSlotsKey     = 'zeta_idle_extra_slots';
  static const String _welcomeSeenKey    = 'zeta_idle_welcome_seen';
  static const int maxSlots     = 5;
  static const int defaultSlots = 3;

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
    await prefs.setString('$_savePrefix$slot', jsonEncode(rawData));
  }

  Future<Map<String, dynamic>?> loadRaw({int slot = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_savePrefix$slot');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<int> getExtraSlots() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_extraSlotsKey) ?? 0).clamp(0, 2);
  }

  static Future<void> setExtraSlots(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_extraSlotsKey, count.clamp(0, 2));
  }

  Future<List<CharacterSummary?>> listCharacters(int totalSlots) async {
    final prefs = await SharedPreferences.getInstance();
    return List.generate(totalSlots, (i) {
      final raw = prefs.getString('$_savePrefix$i');
      if (raw == null) return null;
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final hero = data['hero'] as Map<String, dynamic>;
        return CharacterSummary(
          slot: i,
          name: hero['name'] as String,
          level: hero['level'] as int,
          heroClass: DndClass.tryParse(hero['heroClass'] as String?),
          prestigeLevel: (data['prestigeLevel'] as int?) ?? 0,
        );
      } catch (_) {
        return null;
      }
    });
  }

  Future<void> deleteSlot(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_savePrefix$slot');
  }
}
