import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/damage_type.dart';
import '../models/endless_upgrades.dart';
import '../models/equipment.dart';
import '../models/npc_ally.dart';
import '../models/passive_tree.dart';
import '../models/pet.dart';
import '../models/subclass.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart' show TutorialTip;

// ─────────────────────────────────────────────────────────────────────────────
// HeroStatsScreen — full breakdown of every bonus source on the hero.
// Used embedded inside HeroHubScreen's STATS tab.
// ─────────────────────────────────────────────────────────────────────────────

class HeroStatsScreen extends StatelessWidget {
  const HeroStatsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final body = _StatsBody(game: game);
    if (embedded) return body;
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text('ALL BONUSES',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: body,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 24),
      children: [
        TutorialTip(
          tutorialKey: 'bonus',
          game: game,
          text: 'Curious where your stats come from? 📊 The Bonuses sheet breaks '
              'down every source — gear, passives, pets, artifacts and more. '
              'Track what\'s boosting your power here.',
        ),
        _currenciesSection(),
        if (game.prestigeLevel > 0) _prestigeSection(),
        _section('DAMAGE TYPES',  _damageTypeRows()),
        if (game.endlessUpgrades.levelOf(EndlessNode.str) > 0 ||
            game.endlessUpgrades.levelOf(EndlessNode.dex) > 0)
          _section('UPGRADES', _upgradeRows()),
        _section('DAMAGE BREAKDOWN', _damageBreakdownRows()),
        _section('COMBAT',      _combatRows()),
        _section('RESISTANCES', _resistanceRows()),
        _section('ECONOMY',     _economyRows()),
        _section('MASTERY',     _masteryRows()),
        _section('SURVIVAL',    _survivalRows()),
        if (game.unlockedAllies.isNotEmpty) _mercenariesSection(),
      ],
    );
  }


  int _evoBonus(PetDefinition p) {
    final evo = game.petEvolutionLevel(p.id);
    if (evo == 0) return p.bonusValue;
    if (evo == 1) return (p.bonusValue * 1.5).round();
    return p.bonusValue * 2;
  }

  // Returns individual pet sources if any pets contribute; otherwise a single "+0" fallback.
  List<_Source> _petSourcesOrZero(PetBonusType type, String Function(int v) fmt) {
    final sources = game.ownedPetIds
        .map((id) => kPetCatalog.where((p) => p.id == id).firstOrNull)
        .where((p) => p?.bonusType == type)
        .cast<PetDefinition>()
        .map((p) => _Source('${p.emoji} ${p.name}', fmt(_evoBonus(p))))
        .toList();
    return sources.isNotEmpty ? sources : [_Source('Pets', fmt(0))];
  }

  // ── Currencies ───────────────────────────────────────────────────────────────

  Widget _currenciesSection() {
    const purple = Color(0xFF9966ff);

    final rows = <_StatRow>[
      _StatRow(
        label: 'Gold',
        icon: Icons.monetization_on_outlined,
        color: AppTheme.accentGold,
        total: AppTheme.fmtNumber(game.gold),
        sources: [
          _Source('Campaign', 'per enemy kill'),
          _Source('Idle income', 'passive / per tick'),
          _Source('Daily Challenges', 'chest reward'),
          _Source('Bounty Board', 'mission rewards'),
          _Source('World Events', 'event drops'),
          _Source('Quests', 'quest completion'),
        ],
      ),
      _StatRow(
        label: 'Shards ◆',
        icon: Icons.diamond_outlined,
        color: const Color(0xFF44ccff),
        total: AppTheme.fmtNumber(game.shards),
        sources: [
          _Source('Campaign', 'small drop per kill'),
          _Source('Endless Mode', 'primary source'),
          _Source('Boss Rush', 'per boss defeated'),
          _Source('Dungeon', 'floor rewards'),
          _Source('Daily Challenges', 'chest reward'),
          _Source('Bounty Board', 'some missions'),
        ],
      ),
      _StatRow(
        label: 'Mythril ⬡',
        icon: Icons.workspaces_outlined,
        color: const Color(0xFFaa66ff),
        total: AppTheme.fmtNumber(game.mythril),
        sources: [
          _Source('Dungeon', '1 per 2 floors cleared'),
          _Source('Rebirth (Prestige)', '+10 on each prestige'),
          _Source('Boss Rush', 'rank-based rewards'),
        ],
      ),
      _StatRow(
        label: 'Essence ✨',
        icon: Icons.auto_awesome,
        color: const Color(0xFFaaff88),
        total: AppTheme.fmtNumber(game.essence),
        sources: [
          _Source('Campaign kills', 'baseline per kill, scales with stage'),
          _Source('Gauntlet runs', 'earned from challenge scores'),
          _Source('Daily Challenges', 'chest reward'),
          _Source('Passive Tree', '+% essence gain bonus'),
          _Source('Pets & Auras', '+% essence gain bonus'),
        ],
      ),
      _StatRow(
        label: 'ZCoins 🪙',
        icon: Icons.water_drop_outlined,
        color: const Color(0xFF88ddff),
        total: AppTheme.fmtNumber(game.zcoins),
        sources: [
          _Source('Daily Chest', 'complete all 7 daily challenges'),
          _Source('Achievements', 'milestone rewards'),
          _Source('Boss Rush', 'clear reward (rare)'),
          _Source('IAP', 'premium purchase'),
        ],
      ),
      _StatRow(
        label: 'Souls 🌑',
        icon: Icons.brightness_2_outlined,
        color: const Color(0xFFcc8844),
        total: AppTheme.fmtNumber(game.prestigeSouls),
        sources: [
          _Source('Rebirth', 'earned each time you prestige (scales with stage)'),
          _Source('Soul Shop', 'spend for permanent bonuses that survive resets'),
        ],
      ),
      _StatRow(
        label: 'Asc. Points 🌀',
        icon: Icons.change_circle_outlined,
        color: const Color(0xFF88ffdd),
        total: AppTheme.fmtNumber(game.ascensionPoints),
        sources: [
          _Source('Ascension', 'earned on each ascension tier'),
          _Source('Ascension tree', 'spend for powerful permanent upgrades'),
        ],
      ),
      _StatRow(
        label: 'Event Tokens 🎪',
        icon: Icons.local_activity_outlined,
        color: const Color(0xFFffaa44),
        total: AppTheme.fmtNumber(game.eventTokens),
        sources: [
          _Source('World Events', 'earned by participating in active events'),
          _Source('Event Shop', 'spend for exclusive event rewards'),
        ],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: purple.withValues(alpha: 0.05),
          border: Border.all(color: purple.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: purple, size: 13),
              const SizedBox(width: 6),
              Text('CURRENCIES & REBIRTHS',
                  style: AppTheme.pixelHeading(
                      fontSize: 11, letterSpacing: 2, color: purple)),
              const SizedBox(width: 8),
              Text('tap to see sources',
                  style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
            ]),
            const SizedBox(height: 8),
            ...rows.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _StatRowWidget(row: r),
            )),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFcc88ff).withValues(alpha: 0.10),
                border: Border.all(
                    color: const Color(0xFFcc88ff).withValues(alpha: 0.45)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(children: [
                const Text('✦',
                    style: TextStyle(fontSize: 14, color: Color(0xFFcc88ff))),
                const SizedBox(width: 8),
                Text('Rebirths',
                    style: GoogleFonts.rajdhani(
                        fontSize: 12, color: Colors.white54)),
                const Spacer(),
                Text('${game.prestigeLevel}',
                    style: GoogleFonts.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: game.prestigeLevel > 0
                            ? const Color(0xFFcc88ff)
                            : Colors.white24)),
                if (game.ascensionLevel > 0) ...[
                  const SizedBox(width: 12),
                  const Text('🌀', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('Ascension ${game.ascensionLevel}',
                      style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: const Color(0xFF88ffdd))),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ── Prestige ─────────────────────────────────────────────────────────────────

  Widget _prestigeSection() {
    const gold  = Color(0xFFcc8844);
    final goldPct  = ((game.prestigeGoldMult - 1.0) * 100).round();
    final xpPct    = ((game.prestigeXpMult  - 1.0) * 100).round();
    final idlePct  = ((game.prestigeIdleMult - 1.0) * 100).round();

    final enemyHpPct  = game.prestigeLevel * 15;
    final enemyAtkPct = game.prestigeLevel * 8;

    final chips = <String>[
      'Lv ${game.prestigeLevel} Rebirths',
      '${game.prestigeSouls} Souls',
      '+$goldPct% Gold',
      '+$xpPct% XP',
      '+$idlePct% Idle',
      '⚔ Enemy HP +$enemyHpPct%',
      '⚔ Enemy ATK +$enemyAtkPct%',
      if (game.prestigeShop.isUnlocked('shard_bonus'))   '+30% Shards',
      if (game.prestigeShop.isUnlocked('essence_bonus')) '+30% Essence',
      if (game.prestigeShop.isUnlocked('idle_bonus'))    '+5 Idle Rate',
      if (game.prestigeShop.isUnlocked('ability_disc'))  '-25% Ability Cost',
      if (game.prestigeShop.isUnlocked('start_gold'))    '+500 Start Gold',
      if (game.prestigeShop.isUnlocked('start_gold_2'))  '+1500 Start Gold',
      if (game.prestigeShop.isUnlocked('head_start'))    'Start Stage 6',
      if (game.prestigeShop.isUnlocked('head_start_2'))  'Start Stage 11',
      if (game.prestigeShop.isUnlocked('forge_bonus'))   'Forge 2 items',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.06),
          border: Border.all(color: gold.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.auto_awesome, color: gold, size: 13),
              const SizedBox(width: 6),
              Text('PRESTIGE BONUSES',
                  style: AppTheme.pixelHeading(
                      fontSize: 12, letterSpacing: 2, color: gold)),
            ]),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: chips.map((c) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.10),
                  border: Border.all(color: gold.withValues(alpha: 0.40)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(c,
                    style: const TextStyle(
                        fontSize: 12, color: gold, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section wrapper ──────────────────────────────────────────────────────────

  Widget _section(String title, List<_StatRow> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title),
          ...rows.map((r) => _StatRowWidget(row: r)),
        ],
      ),
    );
  }

  // ── Damage Type rows ──────────────────────────────────────────────────────────

  List<_StatRow> _damageTypeRows() {
    final h = game.hero;
    return DamageType.values.map((dt) {
      final pct = h.damagePctFor(dt);
      final res = game.heroResistancePct(dt);
      return _StatRow(
        label: '${dt.emoji} ${dt.label}',
        icon: Icons.whatshot,
        color: dt.color,
        total: '+$pct% DMG / $res% RES',
        sources: [
          _Source('Damage %', '+$pct%'),
          _Source('Resistance %', '$res%'),
        ],
      );
    }).toList();
  }

  // ── Upgrade rows ──────────────────────────────────────────────────────────────

  List<_StatRow> _upgradeRows() {
    final u = game.endlessUpgrades;
    return [
      if (u.levelOf(EndlessNode.str) > 0)
        _StatRow(label: 'Power', icon: Icons.fitness_center, color: const Color(0xFFe05030),
            total: 'Lv${u.levelOf(EndlessNode.str)}  +${((u.damageMultiplier - 1) * 100).toStringAsFixed(1)}% DMG',
            sources: [_Source('Level', '${u.levelOf(EndlessNode.str)}')]),
      if (u.levelOf(EndlessNode.dex) > 0)
        _StatRow(label: 'Agility', icon: Icons.directions_run, color: const Color(0xFF40b060),
            total: 'Lv${u.levelOf(EndlessNode.dex)}  +${u.attackRollBonus} Crit DMG',
            sources: [_Source('Level', '${u.levelOf(EndlessNode.dex)}')]),
      if (u.levelOf(EndlessNode.con) > 0)
        _StatRow(label: 'Fortitude', icon: Icons.shield, color: const Color(0xFF4488cc),
            total: 'Lv${u.levelOf(EndlessNode.con)}  -${u.flatDamageReduction} dmg/hit',
            sources: [_Source('Level', '${u.levelOf(EndlessNode.con)}')]),
      if (u.levelOf(EndlessNode.intelligence) > 0)
        _StatRow(label: 'Arcane', icon: Icons.psychology, color: const Color(0xFFC9A35A),
            total: 'Lv${u.levelOf(EndlessNode.intelligence)}  +${((u.goldMultiplier - 1) * 100).toStringAsFixed(1)}% Gold',
            sources: [_Source('Level', '${u.levelOf(EndlessNode.intelligence)}')]),
      if (u.levelOf(EndlessNode.wis) > 0)
        _StatRow(label: 'Focus', icon: Icons.visibility, color: const Color(0xFF9060c0),
            total: 'Lv${u.levelOf(EndlessNode.wis)}  +${((u.shardMultiplier - 1) * 100).toStringAsFixed(1)}% Echoes',
            sources: [_Source('Level', '${u.levelOf(EndlessNode.wis)}')]),
      if (u.levelOf(EndlessNode.cha) > 0)
        _StatRow(label: 'Fortune', icon: Icons.theater_comedy, color: const Color(0xFFc06080),
            total: 'Lv${u.levelOf(EndlessNode.cha)}  +${((u.xpMultiplier - 1) * 100).toStringAsFixed(1)}% XP',
            sources: [_Source('Level', '${u.levelOf(EndlessNode.cha)}')]),
    ];
  }

  // ── Combat rows ──────────────────────────────────────────────────────────────

  List<_StatRow> _damageBreakdownRows() {
    final weaponDmg = game.inventory.equippedWeaponDamage;
    final heroDmg = game.hero.baseDmg;
    final passiveDmg = game.passiveTree.totalOf(PassiveEffect.damageFlat);
    final equipDmg = game.inventory.totalOf(ItemStat.damageBonus)
        + game.inventory.totalOf(ItemStat.strength);
    final setDmg = game.inventorySetTotal(ItemStat.damageBonus)
        + game.inventorySetTotal(ItemStat.strength);
    final petDmg = game.petDamage;
    final skinDmg = game.skinDamage;
    final allyDmg = game.allyDmgBonus;
    final questDmg = game.questDamageBonus;
    final artifactDmg = game.artifactPowerBonus;
    final runeDmg = game.runeDmgBonus;
    final ascDmg = game.ascDmgBonus;
    final total = weaponDmg + heroDmg + passiveDmg + equipDmg + setDmg
        + petDmg + skinDmg + allyDmg + questDmg + artifactDmg + runeDmg + ascDmg;

    return [
      _StatRow(label: 'Total Damage', icon: Icons.flash_on, color: const Color(0xFFff6644), total: '$total', sources: [
        if (weaponDmg > 0) _Source('Weapon Base', '+$weaponDmg'),
        if (heroDmg > 0) _Source('Hero Level', '+$heroDmg'),
        if (passiveDmg > 0) _Source('Passives', '+$passiveDmg'),
        if (equipDmg > 0) _Source('Equipment', '+$equipDmg'),
        if (setDmg > 0) _Source('Set Bonuses', '+$setDmg'),
        if (petDmg > 0) _Source('Pets', '+$petDmg'),
        if (skinDmg > 0) _Source('Skins', '+$skinDmg'),
        if (allyDmg > 0) _Source('Allies', '+$allyDmg'),
        if (questDmg > 0) _Source('Quests', '+$questDmg'),
        if (artifactDmg > 0) _Source('Artifacts', '+$artifactDmg'),
        if (runeDmg > 0) _Source('Runes', '+$runeDmg'),
        if (ascDmg > 0) _Source('Ascension', '+$ascDmg'),
      ]),
    ];
  }

  List<_StatRow> _combatRows() {
    final h  = game.hero;
    final pt = game.passiveTree;

    final atkBase  = h.attackBonus;
    final atkPass  = pt.totalOf(PassiveEffect.attackFlat);
    final atkEquip = game.inventory.totalOf(ItemStat.attackBonus)
                   + game.inventory.totalOf(ItemStat.strength);
    final atkSet   = game.inventorySetTotal(ItemStat.attackBonus)
                   + game.inventorySetTotal(ItemStat.strength);
    final atkPets  = game.petAttackBonus;
    final atkSkin  = game.skinAttackBonus;
    final atkAlly  = game.allyAtkBonus;

    final dmgBase  = h.damageMod;
    final dmgPass  = pt.totalOf(PassiveEffect.damageFlat);
    final dmgEquip = game.inventory.totalOf(ItemStat.damageBonus)
                   + game.inventory.totalOf(ItemStat.strength);
    final dmgSet   = game.inventorySetTotal(ItemStat.damageBonus)
                   + game.inventorySetTotal(ItemStat.strength);
    final dmgPets  = game.petDamage;
    final dmgSkin  = game.skinDamage;
    final dmgAlly  = game.allyDmgBonus;
    final dmgTrait = game.traitDmgPct;

    final acBase  = h.armorClass;
    final acPass  = pt.totalOf(PassiveEffect.armorFlat);
    final acEquip = game.inventory.totalOf(ItemStat.armorClass)
                  + game.inventory.totalOf(ItemStat.dexterity);
    final acSet   = game.inventorySetTotal(ItemStat.armorClass)
                  + game.inventorySetTotal(ItemStat.dexterity);
    final acPets  = game.petArmor;
    final acSkin  = game.skinArmor;
    final acAlly  = game.allyAcBonus;

    final hpBase  = h.maxHealth;
    final hpPass  = pt.totalOf(PassiveEffect.maxHp);
    final hpAlly  = game.allyHpPct;
    final hpTrait = game.traitHpPct + game.artifactHpPct + game.runeHpPct + hpAlly;

    final pierce    = pt.totalOf(PassiveEffect.pierce);
    final critPass  = pt.totalOf(PassiveEffect.critChance);
    final dodgePass = pt.totalOf(PassiveEffect.dodgeChance);
    final dodgePets = game.petDodgeChance;

    final regenPass  = pt.totalOf(PassiveEffect.regenFlat);
    final regenEquip = game.inventory.totalOf(ItemStat.constitution) * 3
                     + game.inventorySetTotal(ItemStat.constitution) * 3
                     + game.inventoryGemTotal(ItemStat.constitution) * 3;
    final regenPets  = game.petHpRegen;
    final regenSkin  = game.skinHpRegen;

    return [
      _StatRow(
        label: 'Power',
        icon: Icons.flash_on,
        color: const Color(0xFFff6644),
        total: '+${atkBase + atkPass + atkEquip + atkSet + atkPets + atkSkin + atkAlly + dmgBase + dmgPass + dmgEquip + dmgSet + dmgPets + dmgSkin + dmgAlly}'
            '${dmgTrait != 0 ? "  ×${(1 + dmgTrait / 100).toStringAsFixed(2)}" : ""}',
        sources: [
          _Source('Base (prof + level)', '+${atkBase + dmgBase}'),
          _Source('Passives', '+${atkPass + dmgPass}'),
          _Source('Equipment', '+${atkEquip + dmgEquip}'),
          _Source('Set bonuses', '+${atkSet + dmgSet}'),
          ..._petSourcesOrZero(PetBonusType.attackBonus, (v) => '+$v'),
          ..._petSourcesOrZero(PetBonusType.damage, (v) => '+$v'),
          _Source('Skin', '+${atkSkin + dmgSkin}'),
          _Source('Mercenaries', '+${atkAlly + dmgAlly}'),
          if (dmgTrait != 0) _Source('Trait (mult)', '${dmgTrait >= 0 ? '+' : ''}$dmgTrait%'),
        ],
      ),
      _StatRow(
        label: 'Armor',
        icon: Icons.shield_outlined,
        color: const Color(0xFF66aaff),
        total: '${acBase + acPass + acEquip + acSet + acPets + acSkin + acAlly}',
        sources: [
          _Source('Base (flat)', '$acBase'),
          _Source('Passives', '+$acPass'),
          _Source('Equipment', '+$acEquip'),
          _Source('Set bonuses', '+$acSet'),
          ..._petSourcesOrZero(PetBonusType.armor, (v) => '+$v'),
          _Source('Skin', '+$acSkin'),
          _Source('Mercenaries', '+$acAlly'),
        ],
      ),
      _StatRow(
        label: 'Max HP',
        icon: Icons.favorite_outline,
        color: const Color(0xFFff6666),
        total: '$hpBase HP',
        sources: [
          _Source('Base (level)', '${(h.maxHealth * 100 / (100 + hpPass + hpTrait)).round()} HP'),
          _Source('Passives', '+$hpPass%'),
          _Source('Trait / Artifact / Rune', '+${game.traitHpPct + game.artifactHpPct + game.runeHpPct}%'),
          _Source('Mercenaries', '+$hpAlly%'),
        ],
      ),
      _StatRow(
        label: 'Pierce (Armor Pen)',
        icon: Icons.compare_arrows,
        color: const Color(0xFFffaa44),
        total: '$pierce flat armor ignored',
        sources: [
          _Source('Passives', '+$pierce'),
          _Source('Effect', 'Reduces enemy flat armor before damage is applied (physical only)'),
          _Source('How to get', 'Pierce passive nodes'),
        ],
      ),
      _StatRow(
        label: 'Crit Chance',
        icon: Icons.star_outline,
        color: const Color(0xFFffee44),
        total: '${game.totalCritChancePct}%  (cap 75%)',
        sources: [
          _Source('Passives (crit nodes)', '+$critPass%'),
          _Source('ATK stat (items ×2)', '+${(game.inventory.totalOf(ItemStat.attackBonus) + game.inventorySetTotal(ItemStat.attackBonus)) * 2}%'),
          _Source('Passives (ATK flat ×2)', '+${pt.totalOf(PassiveEffect.attackFlat) * 2}%'),
          _Source('Pets / Skin / Aura', '+${(atkPets + atkSkin) * 2}%'),
          _Source('Prestige: Killing Blow', '+${game.prestigeCritBonus}%'),
          if (game.subclassEffect == SubclassEffect.champion) _Source('Champion subclass', '+15%'),
          if (game.endlessUpgrades.ironGrip) _Source('Iron Grip upgrade', '+5%'),
          if (game.endlessUpgrades.keenEdge) _Source('Keen Edge upgrade', '+10%'),
          _Source('Active buff (ATK ability)', '+${game.buffAttackBonus}%'),
        ],
      ),
      _StatRow(
        label: 'Crit Damage',
        icon: Icons.flash_on_outlined,
        color: const Color(0xFFff8844),
        total: '${game.totalCritDamageMult.toStringAsFixed(1)}× damage',
        sources: [
          _Source('Base', '2.0× (hits deal double damage)'),
          if (game.prestigeCritDamageMult > 1.0) _Source("Prestige: Death's Edge", '×${game.prestigeCritDamageMult.toStringAsFixed(1)}'),
          if (game.subclassEffect == SubclassEffect.assassin) _Source('Assassin subclass', '3× base (triple damage)'),
          _Source('Critical Fury keyword', '3× base if item equipped'),
        ],
      ),
      _StatRow(
        label: 'Dodge Chance',
        icon: Icons.directions_run,
        color: const Color(0xFF88ffcc),
        total: '+${dodgePass + dodgePets}%',
        sources: [
          _Source('Passives', '+$dodgePass%'),
          ..._petSourcesOrZero(PetBonusType.dodgeChance, (v) => '+$v%'),
        ],
      ),
      _StatRow(
        label: 'HP Regen / round',
        icon: Icons.healing,
        color: const Color(0xFF44cc88),
        total: '+${regenPass + regenEquip + regenPets + regenSkin} HP',
        sources: [
          _Source('Passives', '+$regenPass'),
          _Source('Equipment (CON)', '+$regenEquip'),
          ..._petSourcesOrZero(PetBonusType.hpRegen, (v) => '+$v HP'),
          _Source('Skin', '+$regenSkin'),
        ],
      ),
      _StatRow(
        label: 'Hit Chance bonus',
        icon: Icons.gps_fixed,
        color: const Color(0xFFffcc44),
        total: '+${game.inventory.totalOf(ItemStat.hitChance)}%',
        sources: [
          _Source('Equipment (HIT)', '+${game.inventory.totalOf(ItemStat.hitChance)}%'),
          _Source('How to get', 'HIT% stat on weapons & accessories'),
          _Source('Effect', 'Force-hit ignoring AC (stacks with crit)'),
        ],
      ),
      _StatRow(
        label: 'All Damage %',
        icon: Icons.trending_up,
        color: const Color(0xFFff6633),
        total: '+${pt.totalOf(PassiveEffect.allDamage) + game.inventory.totalOf(ItemStat.damagePercent) + h.levelBonusDamagePct}%',
        sources: [
          _Source('Passives', '+${pt.totalOf(PassiveEffect.allDamage)}%'),
          _Source('Equipment (%DMG)', '+${game.inventory.totalOf(ItemStat.damagePercent)}%'),
          _Source('Level milestones', '+${h.levelBonusDamagePct}% (+10% per 10 levels)'),
        ],
      ),
    ];
  }

  // ── Resistance rows ───────────────────────────────────────────────────────────

  List<_StatRow> _resistanceRows() {
    final h = game.hero;

    return DamageType.values.map((type) {
      final baseStat = switch (type) {
        DamageType.physical  => h.strength,
        DamageType.lightning => h.dexterity,
        DamageType.poison    => h.constitution,
        DamageType.void_     => h.intelligence,
        DamageType.cold      => h.wisdom,
        DamageType.fire      => h.charisma,
      };
      final itemStat = switch (type) {
        DamageType.physical  => ItemStat.strength,
        DamageType.lightning => ItemStat.dexterity,
        DamageType.poison    => ItemStat.constitution,
        DamageType.void_     => ItemStat.intelligence,
        DamageType.cold      => ItemStat.wisdom,
        DamageType.fire      => ItemStat.charisma,
      };

      final equip = game.inventory.totalOf(itemStat);
      final set   = game.inventorySetTotal(itemStat);
      final gem   = game.inventoryGemTotal(itemStat);

      // Attribute the -10 base offset to the base stat contribution.
      final basePct  = ((baseStat - 10) * 25.0 / 90).round();
      final equipPct = (equip * 25.0 / 90).round();
      final setPct   = (set   * 25.0 / 90).round();
      final gemPct   = (gem   * 25.0 / 90).round();

      final pct   = game.heroResistancePct(type);
      final sign  = pct >= 0 ? '+' : '';
      final color = pct > 0
          ? type.color
          : pct < 0
              ? const Color(0xFFff4444)
              : AppTheme.textMuted;
      final capped = pct.abs() == 75;

      String sg(int v) => v >= 0 ? '+' : '';

      return _StatRow(
        label: '${type.label} Resist',
        icon: pct < 0 ? Icons.warning_amber_rounded : Icons.shield_outlined,
        color: color,
        total: '$sign$pct%${capped ? ' ⬆' : ''}',
        sources: [
          _Source('Base ${type.resistanceStat} ($baseStat stat)', '${sg(basePct)}$basePct%'),
          _Source('Equipment', '${sg(equipPct)}$equipPct%'),
          _Source('Set bonuses', '${sg(setPct)}$setPct%'),
          _Source('Gems', '${sg(gemPct)}$gemPct%'),
          _Source('Cap', '±75% max'),
        ],
      );
    }).toList();
  }

  // ── Economy rows ─────────────────────────────────────────────────────────────

  List<_StatRow> _economyRows() {
    final pt = game.passiveTree;

    final goldPass    = pt.totalOf(PassiveEffect.goldFlat);
    final goldEquip   = game.inventory.totalOf(ItemStat.goldPct)
                      + game.inventorySetTotal(ItemStat.goldPct)
                      + game.inventoryGemTotal(ItemStat.goldPct);
    final goldSkin    = game.skinGoldPct;
    final goldArt     = game.artifactGoldPct + game.runeGoldPct;
    final goldPrest   = ((game.prestigeGoldMult - 1.0) * 100).round();
    final goldAlly    = ((game.allyGoldMult - 1.0) * 100).round();
    final goldEndless = ((game.endlessUpgrades.goldMultiplier - 1.0) * 100).round();
    final totalGoldPct = goldPass + goldEquip + game.petGoldPct + goldSkin
                       + goldArt + goldPrest + goldAlly + goldEndless;

    final xpPass    = pt.totalOf(PassiveEffect.xpFlat);
    final xpEquip   = game.inventory.totalOf(ItemStat.xpPct)
                    + game.inventorySetTotal(ItemStat.xpPct)
                    + game.inventoryGemTotal(ItemStat.xpPct);
    final xpSkin    = game.skinXpPct;
    final xpArt     = game.artifactXpPct + game.runeXpPct;
    final xpPrest   = ((game.prestigeXpMult - 1.0) * 100).round();
    final xpAlly    = ((game.allyXpMult - 1.0) * 100).round();
    final xpEndless = ((game.endlessUpgrades.xpMultiplier - 1.0) * 100).round();
    final totalXpPct = xpPass + xpEquip + game.petXpPct + xpSkin
                     + xpArt + xpPrest + xpAlly + xpEndless;

    final shardPass  = pt.totalOf(PassiveEffect.shardFlat);
    final shardPct   = game.traitShardPct + game.artifactShardPct + game.runeShardPct;
    final shardAlly  = ((game.allyShardMult - 1.0) * 100).round();
    final shardPrest = ((game.prestigeShardMult - 1.0) * 100).round();
    final shardPets  = game.petShards;

    final idleBase    = game.hero.idleRate;
    final idlePass    = pt.totalOf(PassiveEffect.idleFlat);
    final idlePrest   = game.prestigeIdleBonus;
    final idleEquip   = game.inventory.totalOf(ItemStat.wisdom);
    final idleMultPct = ((game.prestigeIdleMult - 1.0) * 100).round()
                      + ((game.allyIdleMult - 1.0) * 100).round();

    return [
      _StatRow(
        label: 'Gold per Kill',
        icon: Icons.monetization_on_outlined,
        color: AppTheme.accentGold,
        total: '+$totalGoldPct%',
        sources: [
          _Source('Passives', '+$goldPass%'),
          _Source('Equipment', '+$goldEquip%'),
          ..._petSourcesOrZero(PetBonusType.goldPct, (v) => '+$v%'),
          _Source('Skin', '+$goldSkin%'),
          _Source('Artifact / Rune', '+$goldArt%'),
          _Source('Prestige', '+$goldPrest%'),
          _Source('Allies', '+$goldAlly%'),
          _Source('Endless upgrades', '+$goldEndless%'),
        ],
      ),
      _StatRow(
        label: 'XP per Kill',
        icon: Icons.trending_up,
        color: const Color(0xFF88aaff),
        total: '+$totalXpPct%',
        sources: [
          _Source('Passives', '+$xpPass%'),
          _Source('Equipment', '+$xpEquip%'),
          ..._petSourcesOrZero(PetBonusType.xpPct, (v) => '+$v%'),
          _Source('Skin', '+$xpSkin%'),
          _Source('Artifact / Rune', '+$xpArt%'),
          _Source('Prestige', '+$xpPrest%'),
          _Source('Allies', '+$xpAlly%'),
          _Source('Endless upgrades', '+$xpEndless%'),
        ],
      ),
      _StatRow(
        label: 'Shards per Kill',
        icon: Icons.diamond_outlined,
        color: const Color(0xFF44ccff),
        total: '+$shardPass flat'
            '${shardPct + shardAlly + shardPrest > 0 ? "  +${shardPct + shardAlly + shardPrest}%" : ""}'
            '${shardPets > 0 ? "  +$shardPets" : ""}',
        sources: [
          _Source('Passives', '+$shardPass/kill'),
          ..._petSourcesOrZero(PetBonusType.shardBonus, (v) => '+$v/kill'),
          _Source('Trait / Artifact / Rune', '+$shardPct%'),
          _Source('Allies', '+$shardAlly%'),
          _Source('Prestige', '+$shardPrest%'),
        ],
      ),
      _StatRow(
        label: 'Idle Rate',
        icon: Icons.timelapse,
        color: const Color(0xFF44cc66),
        total: '${idleBase + idlePass + idlePrest + idleEquip + game.petIdleRate}/tick'
            '${idleMultPct > 0 ? "  ×${(1 + idleMultPct / 100).toStringAsFixed(2)}" : ""}',
        sources: [
          _Source('Base (flat)', '$idleBase'),
          _Source('Passives', '+$idlePass'),
          _Source('Equipment (WIS)', '+$idleEquip'),
          ..._petSourcesOrZero(PetBonusType.idleRate, (v) => '+$v'),
          _Source('Prestige shop', '+$idlePrest'),
          _Source('Prestige / Ally (mult)', '+$idleMultPct%'),
        ],
      ),
    ];
  }

  // ── Mastery rows ─────────────────────────────────────────────────────────────

  List<_StatRow> _masteryRows() {
    final pt = game.passiveTree;

    final cdRedPass   = pt.totalOf(PassiveEffect.cooldownReduce);
    final cdRedTrait  = game.traitCooldownReduction;
    final abilDmgPass = pt.totalOf(PassiveEffect.abilityDamage);
    final healPass    = pt.totalOf(PassiveEffect.healBoost);
    final essPass     = pt.totalOf(PassiveEffect.essenceGain);
    final essPrest    = ((game.prestigeEssenceMult - 1.0) * 100).round();

    return [
      _StatRow(
        label: 'Cooldown Reduction',
        icon: Icons.fast_forward,
        color: const Color(0xFFcc88ff),
        total: '-${cdRedPass + cdRedTrait} round${(cdRedPass + cdRedTrait) == 1 ? '' : 's'}',
        sources: [
          _Source('Passives', '-$cdRedPass'),
          _Source('Trait', '-$cdRedTrait'),
        ],
      ),
      _StatRow(
        label: 'Ability Damage',
        icon: Icons.bolt,
        color: const Color(0xFFffcc44),
        total: '+$abilDmgPass%',
        sources: [
          _Source('Passives', '+$abilDmgPass%'),
          _Source('How to get', 'Ability Damage passive nodes'),
        ],
      ),
      _StatRow(
        label: 'Heal Boost',
        icon: Icons.local_hospital_outlined,
        color: const Color(0xFF44ee88),
        total: '+$healPass%',
        sources: [
          _Source('Passives', '+$healPass%'),
          _Source('How to get', 'Heal Boost passive nodes'),
        ],
      ),
      _StatRow(
        label: 'Essence per Kill',
        icon: Icons.auto_awesome,
        color: const Color(0xFFaaff88),
        total: '+${essPass + essPrest + game.petEssenceGain}%',
        sources: [
          _Source('Passives', '+$essPass%'),
          ..._petSourcesOrZero(PetBonusType.essenceGain, (v) => '+$v%'),
          _Source('Prestige', '+$essPrest%'),
        ],
      ),
    ];
  }

  // ── Survival rows ─────────────────────────────────────────────────────────────

  List<_StatRow> _survivalRows() {
    final h           = game.hero;
    const baseHealPct = 10;
    final conEquip    = game.inventory.totalOf(ItemStat.constitution) * 3
                      + game.inventorySetTotal(ItemStat.constitution) * 3
                      + game.inventoryGemTotal(ItemStat.constitution) * 3;
    final endlessRegen = game.endlessUpgrades.flatDamageReduction;
    final regenPets   = game.petHpRegen;
    final regenSkin   = game.skinHpRegen;
    final totalRegen  = (h.maxHealth * baseHealPct / 100).round()
                      + endlessRegen + conEquip + regenPets + regenSkin;

    return [
      _StatRow(
        label: 'Post-battle HP Heal',
        icon: Icons.healing,
        color: const Color(0xFFff6666),
        total: '~$totalRegen HP ($baseHealPct% base)',
        sources: [
          _Source('Flat base — $baseHealPct% of max HP',
              '~${(h.maxHealth * baseHealPct / 100).round()} HP'),
          _Source('Endless upgrade (HP Recovery)', '+$endlessRegen HP'),
          _Source('Equipment CON stat', '+$conEquip HP'),
          ..._petSourcesOrZero(PetBonusType.hpRegen, (v) => '+$v HP'),
          _Source('Skin', '+$regenSkin HP'),
        ],
      ),
      _StatRow(
        label: 'Vitality (VIT)',
        icon: Icons.favorite_border,
        color: const Color(0xFFff8888),
        total: '${h.vitality} (mod ${h.conMod >= 0 ? '+' : ''}${h.conMod})',
        sources: [
          _Source('Base VIT', '${h.vitality}'),
          _Source('Max HP Bonus', '+${h.vitality}%'),
          _Source('Poison Dmg %', '+${h.damagePctFor(DamageType.poison)}% (${h.vitality}÷4)'),
        ],
      ),
    ];
  }

  // ── Mercenaries section ───────────────────────────────────────────────────────

  Widget _mercenariesSection() {
    const teal = Color(0xFF44ddcc);
    final allies   = game.unlockedAllies;
    final synergies = game.activeSynergies;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: teal.withValues(alpha: 0.05),
          border: Border.all(color: teal.withValues(alpha: 0.30)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.handshake_outlined, color: teal, size: 13),
              const SizedBox(width: 6),
              Text('MERCENARIES',
                  style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: teal)),
              const SizedBox(width: 8),
              Text('${allies.length} / ${NpcAllyDef.all.length} recruited',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ]),
            const SizedBox(height: 10),
            // One row per recruited ally
            ...allies.map((a) {
              final lv  = game.allyLevel(a.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(a.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                                color: AppTheme.textLight)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: teal.withValues(alpha: 0.15),
                            border: Border.all(color: teal.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text('Lv $lv',
                              style: TextStyle(fontSize: 10, color: teal,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      const SizedBox(height: 2),
                      Text('Passive: ${a.bonusDescription} (×$lv = ${_allyPassiveTotal(a, lv)})',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      if (a.activeAbility != null)
                        Text('Active: ${a.activeAbility!.icon} ${a.activeAbility!.name} — ${a.activeAbility!.description}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4)),
                    ]),
                  ),
                ]),
              );
            }),
            // Active synergies
            if (synergies.isNotEmpty) ...[
              const Divider(color: AppTheme.cardBorder, height: 16, thickness: 0.5),
              Text('ACTIVE SYNERGIES',
                  style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2,
                      color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              ...synergies.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  const Icon(Icons.link, color: teal, size: 13),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                            color: AppTheme.textLight)),
                    Text('${s.description}  •  ${s.bonusSummary}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4)),
                  ])),
                ]),
              )),
            ],
          ],
        ),
      ),
    );
  }

  String _allyPassiveTotal(NpcAllyDef a, int lv) {
    final parts = <String>[];
    if (a.atkBonus > 0)      parts.add('+${a.atkBonus * lv} ATK');
    if (a.dmgBonus > 0)      parts.add('+${a.dmgBonus * lv} DMG');
    if (a.acBonus > 0)       parts.add('+${a.acBonus * lv} AC');
    if (a.hpPctBonus > 0)    parts.add('+${(a.hpPctBonus * lv * 100).round()}% HP');
    if (a.goldPctBonus > 0)  parts.add('+${(a.goldPctBonus * lv * 100).round()}% Gold');
    if (a.xpPctBonus > 0)    parts.add('+${(a.xpPctBonus * lv * 100).round()}% XP');
    if (a.shardPctBonus > 0) parts.add('+${(a.shardPctBonus * lv * 100).round()}% Shards');
    if (a.idlePctBonus > 0)  parts.add('+${(a.idlePctBonus * lv * 100).round()}% Idle');
    return parts.join('  •  ');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _Source {
  const _Source(this.label, this.value);
  final String label;
  final String value;
}

class _StatRow {
  const _StatRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.total,
    this.sources = const [],
  });
  final String        label;
  final IconData      icon;
  final Color         color;
  final String        total;
  final List<_Source> sources;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(title,
          style: AppTheme.pixelHeading(
              fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
    );
  }
}

class _StatRowWidget extends StatefulWidget {
  const _StatRowWidget({required this.row});
  final _StatRow row;

  @override
  State<_StatRowWidget> createState() => _StatRowWidgetState();
}

class _StatRowWidgetState extends State<_StatRowWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final row       = widget.row;
    final hasDetail = row.sources.isNotEmpty;

    return GestureDetector(
      onTap: hasDetail ? () => setState(() => _expanded = !_expanded) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: _expanded
              ? row.color.withValues(alpha: 0.08)
              : const Color(0xFF0d1020),
          border: Border.all(
            color: _expanded
                ? row.color.withValues(alpha: 0.4)
                : const Color(0xFF1e2235),
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                children: [
                  Icon(row.icon, color: row.color, size: 13),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      row.label,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    row.total,
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: row.color,
                    ),
                  ),
                  if (hasDetail) ...[
                    const SizedBox(width: 6),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 14,
                      color: Colors.white24,
                    ),
                  ],
                ],
              ),
            ),
            if (_expanded && row.sources.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: row.color.withValues(alpha: 0.2))),
                  color: row.color.withValues(alpha: 0.04),
                ),
                child: Column(
                  children: row.sources
                      .map((s) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: row.color.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(s.label,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white38)),
                                ),
                                Text(s.value,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: row.color.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
