import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/damage_type.dart';
import '../models/equipment.dart';
import '../models/passive_tree.dart';
import '../models/pet.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

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
        if (game.prestigeLevel > 0) _prestigeSection(),
        _section('COMBAT',      _combatRows()),
        _section('RESISTANCES', _resistanceRows()),
        _section('ECONOMY',     _economyRows()),
        _section('MASTERY',     _masteryRows()),
        _section('SURVIVAL',    _survivalRows()),
      ],
    );
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

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

  // Returns the evolved bonus value for a pet the player owns.
  int _evoBonus(PetDefinition p) {
    final evo = game.petEvolutionLevel(p.id);
    if (evo == 0) return p.bonusValue;
    if (evo == 1) return (p.bonusValue * 1.5).round();
    return p.bonusValue * 2;
  }

  // Returns one _Source per owned pet that has the given bonus type.
  List<_Source> _petSources(PetBonusType type, String Function(int v) fmt) {
    return game.ownedPetIds
        .map((id) => kPetCatalog.where((p) => p.id == id).firstOrNull)
        .where((p) => p?.bonusType == type)
        .cast<PetDefinition>()
        .map((p) => _Source('${p.emoji} ${p.name}', fmt(_evoBonus(p))))
        .toList();
  }

  // ── data builders ───────────────────────────────────────────────────────────

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

    final dmgBase  = h.damageMod;
    final dmgPass  = pt.totalOf(PassiveEffect.damageFlat);
    final dmgEquip = game.inventory.totalOf(ItemStat.damageBonus)
                   + game.inventory.totalOf(ItemStat.strength);
    final dmgSet   = game.inventorySetTotal(ItemStat.damageBonus)
                   + game.inventorySetTotal(ItemStat.strength);
    final dmgPets  = game.petDamage;
    final dmgSkin  = game.skinDamage;
    final dmgTrait = game.traitDmgPct;

    final acBase  = h.armorClass;
    final acPass  = pt.totalOf(PassiveEffect.armorFlat);
    final acEquip = game.inventory.totalOf(ItemStat.armorClass)
                  + game.inventory.totalOf(ItemStat.dexterity);
    final acSet   = game.inventorySetTotal(ItemStat.armorClass)
                  + game.inventorySetTotal(ItemStat.dexterity);
    final acPets  = game.petArmor;
    final acSkin  = game.skinArmor;

    final hpBase  = h.maxHealth;
    final hpPass  = pt.totalOf(PassiveEffect.maxHp);
    final hpTrait = game.traitHpPct + game.artifactHpPct + game.runeHpPct + game.allyHpPct;

    final pierce   = pt.totalOf(PassiveEffect.pierce);
    final critPass = pt.totalOf(PassiveEffect.critChance);

    final dodgePass = pt.totalOf(PassiveEffect.dodgeChance);
    final dodgePets = game.petDodgeChance;

    final regenPass  = pt.totalOf(PassiveEffect.regenFlat);
    final regenEquip = game.inventory.totalOf(ItemStat.constitution) * 3
                     + game.inventorySetTotal(ItemStat.constitution) * 3;
    final regenPets  = game.petHpRegen;
    final regenSkin  = game.skinHpRegen;

    return [
      _StatRow(
        label: 'Attack Bonus',
        icon: Icons.add_circle_outline,
        color: const Color(0xFFff8844),
        total: '+${atkBase + atkPass + atkEquip + atkSet + atkPets + atkSkin}',
        sources: [
          if (atkBase != 0)  _Source('Base (STR/prof)', '+$atkBase'),
          if (atkPass != 0)  _Source('Passives', '+$atkPass'),
          if (atkEquip != 0) _Source('Equipment', '+$atkEquip'),
          if (atkSet != 0)   _Source('Set bonuses', '+$atkSet'),
          ..._petSources(PetBonusType.attackBonus, (v) => '+$v'),
          if (atkSkin != 0)  _Source('Skin', '+$atkSkin'),
        ],
      ),
      _StatRow(
        label: 'Damage Bonus',
        icon: Icons.flash_on,
        color: const Color(0xFFff4444),
        total: '+${dmgBase + dmgPass + dmgEquip + dmgSet + dmgPets + dmgSkin}'
            + (dmgTrait != 0 ? '  ×${(1 + dmgTrait / 100).toStringAsFixed(2)}' : ''),
        sources: [
          if (dmgBase != 0)  _Source('Base (STR)', '+$dmgBase'),
          if (dmgPass != 0)  _Source('Passives', '+$dmgPass'),
          if (dmgEquip != 0) _Source('Equipment', '+$dmgEquip'),
          if (dmgSet != 0)   _Source('Set bonuses', '+$dmgSet'),
          ..._petSources(PetBonusType.damage, (v) => '+$v'),
          if (dmgSkin != 0)  _Source('Skin', '+$dmgSkin'),
          if (dmgTrait != 0) _Source('Trait (mult)', '${dmgTrait > 0 ? '+' : ''}$dmgTrait%'),
        ],
      ),
      _StatRow(
        label: 'Armor Class',
        icon: Icons.shield_outlined,
        color: const Color(0xFF66aaff),
        total: '${acBase + acPass + acEquip + acSet + acPets + acSkin}',
        sources: [
          if (acBase != 0)  _Source('Base (DEX)', '$acBase'),
          if (acPass != 0)  _Source('Passives', '+$acPass'),
          if (acEquip != 0) _Source('Equipment', '+$acEquip'),
          if (acSet != 0)   _Source('Set bonuses', '+$acSet'),
          ..._petSources(PetBonusType.armor, (v) => '+$v'),
          if (acSkin != 0)  _Source('Skin', '+$acSkin'),
        ],
      ),
      _StatRow(
        label: 'Max HP',
        icon: Icons.favorite_outline,
        color: const Color(0xFFff6666),
        total: '$hpBase HP',
        sources: [
          _Source('Base (CON/level)', '${(h.maxHealth * 100 / (100 + hpPass + hpTrait)).round()} HP'),
          if (hpPass != 0)  _Source('Passives', '+$hpPass%'),
          if (hpTrait != 0) _Source('Trait / Artifact / Rune', '+$hpTrait%'),
        ],
      ),
      if (pierce > 0)
        _StatRow(
          label: 'Pierce (ignore AC)',
          icon: Icons.compare_arrows,
          color: const Color(0xFFffaa44),
          total: '$pierce AC ignored',
          sources: [_Source('Passives', '$pierce')],
        ),
      if (critPass > 0)
        _StatRow(
          label: 'Crit Chance bonus',
          icon: Icons.star_outline,
          color: const Color(0xFFffee44),
          total: '+$critPass%',
          sources: [_Source('Passives', '+$critPass%')],
        ),
      if (dodgePass + dodgePets > 0)
        _StatRow(
          label: 'Dodge Chance',
          icon: Icons.directions_run,
          color: const Color(0xFF88ffcc),
          total: '+${dodgePass + dodgePets}%',
          sources: [
            if (dodgePass != 0) _Source('Passives', '+$dodgePass%'),
            ..._petSources(PetBonusType.dodgeChance, (v) => '+$v%'),
          ],
        ),
      if (regenPass + regenEquip + regenPets + regenSkin > 0)
        _StatRow(
          label: 'HP Regen / round',
          icon: Icons.healing,
          color: const Color(0xFF44cc88),
          total: '+${regenPass + regenEquip + regenPets + regenSkin} HP',
          sources: [
            if (regenPass != 0)  _Source('Passives', '+$regenPass'),
            if (regenEquip != 0) _Source('Equipment (CON)', '+$regenEquip'),
            ..._petSources(PetBonusType.hpRegen, (v) => '+$v HP'),
            if (regenSkin != 0)  _Source('Skin', '+$regenSkin'),
          ],
        ),
    ];
  }

  List<_StatRow> _resistanceRows() {
    final h = game.hero;
    return DamageType.values.map((type) {
      final pct = game.heroResistancePct(type);
      final sign = pct >= 0 ? '+' : '';
      final color = pct > 0
          ? type.color
          : pct < 0
              ? const Color(0xFFff4444)
              : AppTheme.textMuted;
      final statLabel = type.resistanceStat;
      final capped = pct.abs() == 75;
      return _StatRow(
        label: '${type.label} Resist',
        icon: pct < 0 ? Icons.warning_amber_rounded : Icons.shield_outlined,
        color: color,
        total: '$sign$pct%${capped ? " ⬆" : ""}',
        sources: [
          _Source('From $statLabel stat', '$sign$pct%'),
          _Source('Resistance cap', '±75% max'),
        ],
      );
    }).toList();
  }

  List<_StatRow> _economyRows() {
    final pt = game.passiveTree;

    final goldPass  = pt.totalOf(PassiveEffect.goldFlat);
    final goldEquip = game.inventory.totalOf(ItemStat.goldPct)
                    + game.inventorySetTotal(ItemStat.goldPct)
                    + game.inventoryGemTotal(ItemStat.goldPct);
    final goldPets  = game.petGoldPct;
    final goldSkin  = game.skinGoldPct;
    final goldArt   = game.artifactGoldPct + game.runeGoldPct;
    final goldPrest = ((game.prestigeGoldMult - 1.0) * 100).round();
    final goldAlly  = ((game.allyGoldMult - 1.0) * 100).round();
    final goldEndless = ((game.endlessUpgrades.goldMultiplier - 1.0) * 100).round();
    final totalGoldPct = goldPass + goldEquip + goldPets + goldSkin + goldArt + goldPrest + goldAlly + goldEndless;

    final xpPass    = pt.totalOf(PassiveEffect.xpFlat);
    final xpEquip   = game.inventory.totalOf(ItemStat.xpPct)
                    + game.inventorySetTotal(ItemStat.xpPct)
                    + game.inventoryGemTotal(ItemStat.xpPct);
    final xpPets    = game.petXpPct;
    final xpSkin    = game.skinXpPct;
    final xpArt     = game.artifactXpPct + game.runeXpPct;
    final xpPrest   = ((game.prestigeXpMult - 1.0) * 100).round();
    final xpAlly    = ((game.allyXpMult - 1.0) * 100).round();
    final xpEndless = ((game.endlessUpgrades.xpMultiplier - 1.0) * 100).round();
    final totalXpPct = xpPass + xpEquip + xpPets + xpSkin + xpArt + xpPrest + xpAlly + xpEndless;

    final shardPass  = pt.totalOf(PassiveEffect.shardFlat);
    final shardPets  = game.petShards;
    final shardPct   = game.traitShardPct + game.artifactShardPct + game.runeShardPct;
    final shardAlly  = ((game.allyShardMult - 1.0) * 100).round();
    final shardPrest = ((game.prestigeShardMult - 1.0) * 100).round();

    final idleBase    = game.hero.idleRate;
    final idlePass    = pt.totalOf(PassiveEffect.idleFlat);
    final idlePrest   = game.prestigeIdleBonus;
    final idleEquip   = game.inventory.totalOf(ItemStat.wisdom);
    final idlePets    = game.petIdleRate;
    final idleMultPct = ((game.prestigeIdleMult - 1.0) * 100).round()
                      + ((game.allyIdleMult - 1.0) * 100).round();

    return [
      _StatRow(
        label: 'Gold per Kill',
        icon: Icons.monetization_on_outlined,
        color: AppTheme.accentGold,
        total: '+$totalGoldPct%',
        sources: [
          if (goldPass != 0)    _Source('Passives', '+$goldPass%'),
          if (goldEquip != 0)   _Source('Equipment', '+$goldEquip%'),
          ..._petSources(PetBonusType.goldPct, (v) => '+$v%'),
          if (goldSkin != 0)    _Source('Skin', '+$goldSkin%'),
          if (goldArt != 0)     _Source('Artifact / Rune', '+$goldArt%'),
          if (goldPrest != 0)   _Source('Prestige', '+$goldPrest%'),
          if (goldAlly != 0)    _Source('Allies', '+$goldAlly%'),
          if (goldEndless != 0) _Source('Endless upgrades', '+$goldEndless%'),
        ],
      ),
      _StatRow(
        label: 'XP per Kill',
        icon: Icons.trending_up,
        color: const Color(0xFF88aaff),
        total: '+$totalXpPct%',
        sources: [
          if (xpPass != 0)    _Source('Passives', '+$xpPass%'),
          if (xpEquip != 0)   _Source('Equipment', '+$xpEquip%'),
          ..._petSources(PetBonusType.xpPct, (v) => '+$v%'),
          if (xpSkin != 0)    _Source('Skin', '+$xpSkin%'),
          if (xpArt != 0)     _Source('Artifact / Rune', '+$xpArt%'),
          if (xpPrest != 0)   _Source('Prestige', '+$xpPrest%'),
          if (xpAlly != 0)    _Source('Allies', '+$xpAlly%'),
          if (xpEndless != 0) _Source('Endless upgrades', '+$xpEndless%'),
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
          if (shardPass != 0)  _Source('Passives', '+$shardPass/kill'),
          ..._petSources(PetBonusType.shardBonus, (v) => '+$v/kill'),
          if (shardPct != 0)   _Source('Trait / Artifact / Rune', '+$shardPct%'),
          if (shardAlly != 0)  _Source('Allies', '+$shardAlly%'),
          if (shardPrest != 0) _Source('Prestige', '+$shardPrest%'),
        ],
      ),
      _StatRow(
        label: 'Idle Rate',
        icon: Icons.timelapse,
        color: const Color(0xFF44cc66),
        total: '${idleBase + idlePass + idlePrest + idleEquip + idlePets}/tick'
            '${idleMultPct > 0 ? "  ×${(1 + idleMultPct / 100).toStringAsFixed(2)}" : ""}',
        sources: [
          _Source('Base (WIS)', '$idleBase'),
          if (idlePass != 0)    _Source('Passives', '+$idlePass'),
          if (idleEquip != 0)   _Source('Equipment (WIS)', '+$idleEquip'),
          ..._petSources(PetBonusType.idleRate, (v) => '+$v'),
          if (idlePrest != 0)   _Source('Prestige shop', '+$idlePrest'),
          if (idleMultPct != 0) _Source('Prestige / Ally (mult)', '+$idleMultPct%'),
        ],
      ),
    ];
  }

  List<_StatRow> _masteryRows() {
    final pt = game.passiveTree;

    final cdRedPass   = pt.totalOf(PassiveEffect.cooldownReduce) + game.traitCooldownReduction;
    final abilDmgPass = pt.totalOf(PassiveEffect.abilityDamage);
    final healPass    = pt.totalOf(PassiveEffect.healBoost);
    final essPass     = pt.totalOf(PassiveEffect.essenceGain);
    final essPrest    = ((game.prestigeEssenceMult - 1.0) * 100).round();
    final essPets     = game.petEssenceGain;

    return [
      if (cdRedPass > 0)
        _StatRow(
          label: 'Cooldown Reduction',
          icon: Icons.fast_forward,
          color: const Color(0xFFcc88ff),
          total: '-$cdRedPass round${cdRedPass == 1 ? '' : 's'}',
          sources: [
            if (pt.totalOf(PassiveEffect.cooldownReduce) > 0)
              _Source('Passives', '-${pt.totalOf(PassiveEffect.cooldownReduce)}'),
            if (game.traitCooldownReduction > 0)
              _Source('Trait', '-${game.traitCooldownReduction}'),
          ],
        ),
      if (abilDmgPass > 0)
        _StatRow(
          label: 'Ability Damage',
          icon: Icons.bolt,
          color: const Color(0xFFffcc44),
          total: '+$abilDmgPass%',
          sources: [_Source('Passives', '+$abilDmgPass%')],
        ),
      if (healPass > 0)
        _StatRow(
          label: 'Heal Boost',
          icon: Icons.local_hospital_outlined,
          color: const Color(0xFF44ee88),
          total: '+$healPass%',
          sources: [_Source('Passives', '+$healPass%')],
        ),
      _StatRow(
        label: 'Essence per Kill',
        icon: Icons.auto_awesome,
        color: const Color(0xFFaaff88),
        total: '+${essPass + essPrest + essPets}%',
        sources: [
          if (essPass != 0)  _Source('Passives', '+$essPass%'),
          ..._petSources(PetBonusType.essenceGain, (v) => '+$v%'),
          if (essPrest != 0) _Source('Prestige', '+$essPrest%'),
        ],
      ),
    ];
  }

  List<_StatRow> _survivalRows() {
    final h           = game.hero;
    final conHealPct  = (10 + h.conMod * 5).clamp(5, 100);
    final conEquip    = game.inventory.totalOf(ItemStat.constitution) * 3
                      + game.inventorySetTotal(ItemStat.constitution) * 3
                      + game.inventoryGemTotal(ItemStat.constitution) * 3;
    final endlessRegen = (h.maxHealth * game.endlessUpgrades.hpRecoveryFraction).round();
    final regenPets   = game.petHpRegen;
    final regenSkin   = game.skinHpRegen;
    final totalRegen  = (h.maxHealth * conHealPct / 100).round()
                      + endlessRegen + conEquip + regenPets + regenSkin;

    return [
      _StatRow(
        label: 'Post-battle HP Heal',
        icon: Icons.healing,
        color: const Color(0xFFff6666),
        total: '~$totalRegen HP ($conHealPct% base)',
        sources: [
          _Source('VIT (${h.vitality}) — ${conHealPct}% of max HP',
              '~${(h.maxHealth * conHealPct / 100).round()} HP'),
          if (endlessRegen > 0)
            _Source('Endless upgrade (HP Recovery)', '+$endlessRegen HP'),
          if (conEquip > 0)
            _Source('Equipment CON stat', '+$conEquip HP'),
          ..._petSources(PetBonusType.hpRegen, (v) => '+$v HP'),
          if (regenSkin > 0) _Source('Skin', '+$regenSkin HP'),
        ],
      ),
      _StatRow(
        label: 'Vitality (VIT)',
        icon: Icons.favorite_border,
        color: const Color(0xFFff8888),
        total: '${h.vitality} (mod ${h.conMod >= 0 ? '+' : ''}${h.conMod})',
        sources: [
          _Source('Base VIT', '${h.vitality}'),
          _Source('Max HP formula', '${h.maxHealth} HP at lv ${h.level}'),
        ],
      ),
    ];
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
  final String       label;
  final IconData     icon;
  final Color        color;
  final String       total;
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
    final row      = widget.row;
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
                      style: GoogleFonts.pixelifySans(
                        fontSize: 11,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    row.total,
                    style: GoogleFonts.pixelifySans(
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
                                        color:
                                            row.color.withValues(alpha: 0.85),
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
