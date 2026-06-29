import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dnd_class.dart';
import '../models/guild.dart';
import '../models/pvp.dart';
import '../services/auth_service.dart';
import '../services/game_state.dart';
import '../services/guild_service.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/pixel_health_bar.dart';
import '../widgets/snake_loader.dart';

class GuildScreen extends StatefulWidget {
  const GuildScreen({super.key});

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  final _guildService = GuildService();
  final _authService  = AuthService();
  final _chatCtrl     = TextEditingController();

  Guild?  _guild;
  bool    _loading = true;
  List<Guild> _publicGuilds = [];
  int _bossAttacksToday = 0;
  static const _maxBossAttacks = 3;
  bool _inBossFight = false;
  int _bossFightDamage = 0;

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  @override
  void dispose() {
    _chatCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await _doLoad().timeout(const Duration(seconds: 5));
    } catch (_) {
      // Safety fallback — show dev guilds
      final game = GameStateProvider.of(context);
      _publicGuilds = _generateDevGuilds(game);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _doLoad() async {
    final game = GameStateProvider.of(context);
    if (game.guildId != null) {
      if (game.guildId!.startsWith('dev_guild_')) {
        final devGuilds = _generateDevGuilds(game);
        _guild = devGuilds.where((g) => g.id == game.guildId).firstOrNull;
        if (_guild != null) {
          _guild!.members.add(GuildMember(
            userId: 'local_player',
            name: game.hero.name,
            heroClass: game.hero.heroClass.name,
            level: game.hero.level,
            lastActive: DateTime.now(),
          ));
          _guild!.weeklyBoss ??= GuildBoss.generate(_guild!.memberCount, _guild!.level);
        }
      } else if (GuildService.isAvailable) {
        try {
          _guild = await _guildService.fetchGuild(game.guildId!)
              .timeout(const Duration(seconds: 3));
        } catch (_) {
          _guild = null;
        }
      }
      if (_guild == null) {
        game.guildId = null;
        game.saveToLocal();
      }
    }
    if (_guild == null) {
      _publicGuilds = _generateDevGuilds(game);
    }
  }

  List<Guild> _generateDevGuilds(GameState game) {
    final rng = Random();
    final level = game.hero.level;
    final guildNames = [
      'Iron Wolves', 'Shadow Covenant', 'Golden Dawn',
      'Void Reapers', 'Storm Legion', 'Crimson Order',
    ];
    final icons = ['⚔', '🛡', '👑', '🌑', '⚡', '🔥'];

    return List.generate(3, (gi) {
      final memberCount = 12 + rng.nextInt(9); // 12-20 members
      final gLevel = (level ~/ 5).clamp(1, 20) + rng.nextInt(3);
      final members = List.generate(memberCount, (mi) {
        final cls = DndClass.values[rng.nextInt(DndClass.values.length)];
        final mLevel = (level + rng.nextInt(11) - 5).clamp(1, 200);
        final name = _randomBotPlayerName(rng);
        return GuildMember(
          userId: 'dev_${gi}_$mi',
          name: name,
          heroClass: cls.name,
          level: mLevel,
          role: mi == 0 ? GuildRole.leader : mi < 3 ? GuildRole.officer : GuildRole.member,
          weeklyDamage: rng.nextInt(5000) * mLevel,
          totalDonated: rng.nextInt(10000),
          guildCoins: rng.nextInt(200),
          lastActive: DateTime.now().subtract(Duration(hours: rng.nextInt(48))),
        );
      });
      return Guild(
        id: 'dev_guild_$gi',
        name: guildNames[gi],
        leaderId: members.first.userId,
        description: 'A mighty guild seeking new champions.',
        icon: icons[gi],
        level: gLevel,
        xp: rng.nextInt(gLevel * 500),
        members: members,
        createdAt: DateTime.now().subtract(Duration(days: 10 + rng.nextInt(30))),
      );
    });
  }

  static String _randomBotPlayerName(Random rng) {
    const first = ['Shadow', 'Iron', 'Frost', 'Storm', 'Ember', 'Ash',
      'Dusk', 'Tide', 'Gale', 'Cinder', 'Vale', 'Thorn',
      'Blaze', 'Stone', 'Void', 'Dark', 'Grim', 'Rune', 'Silver', 'Wild'];
    const last = ['hunter', 'ward', 'blade', 'born', 'seeker', 'lord',
      'walker', 'rider', 'fist', 'mage', 'guard', 'caller',
      'fury', 'strike', 'warden', 'claw', 'eye', 'reaver', 'bane', 'forge'];
    return '${first[rng.nextInt(first.length)]}${last[rng.nextInt(last.length)]}';
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(_guild?.name ?? 'GUILD',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          if (_guild != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('${game.guildCoins}',
                    style: GoogleFonts.pixelifySans(
                        fontSize: 15, fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold)),
              ]),
            ),
        ],
      ),
      body: _loading
          ? Center(child: const SnakeLoader())
          : _guild != null
              ? _buildGuildView(game)
              : _buildNoGuild(game),
    );
  }

  // ── No Guild — Create or Join ──────────────────────────────────────────────

  Widget _buildNoGuild(GameState game) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('⚔', style: TextStyle(fontSize: 48), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('JOIN A GUILD',
              style: AppTheme.pixelHeading(fontSize: 17, letterSpacing: 2),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
            'Guilds provide passive bonuses, a weekly boss challenge, '
            'and a guild shop with exclusive rewards.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Create
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => _showCreateDialog(game),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold.withValues(alpha: 0.15),
                foregroundColor: AppTheme.accentGold,
                side: const BorderSide(color: AppTheme.accentGold),
              ),
              child: Text('CREATE GUILD',
                  style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2, color: AppTheme.accentGold)),
            ),
          ),
          const SizedBox(height: 20),

          // Public guilds
          Text('PUBLIC GUILDS',
              style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          if (_publicGuilds.isEmpty)
            const Text('No guilds found. Be the first to create one!',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted))
          else
            ..._publicGuilds.map((g) => _GuildListTile(
              guild: g,
              onJoin: () => _joinGuild(game, g),
            )),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(GameState game) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Create Guild', style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              maxLength: 20,
              style: const TextStyle(color: AppTheme.textLight),
              decoration: const InputDecoration(
                labelText: 'Guild Name',
                labelStyle: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            TextField(
              controller: descCtrl,
              maxLength: 50,
              style: const TextStyle(color: AppTheme.textLight),
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: TextStyle(color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: Text('CREATE', style: TextStyle(color: AppTheme.accentGold))),
        ],
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;

    setState(() => _loading = true);
    try {
      final user = _authService.currentUser ?? await _authService.signInAnonymously();
      if (user == null) return;
      final guild = await _guildService.createGuild(
        name: nameCtrl.text.trim(),
        leaderId: user.uid,
        leaderName: game.hero.name,
        leaderClass: game.hero.heroClass.name,
        leaderLevel: game.hero.level,
        description: descCtrl.text.trim(),
      );
      game.guildId = guild.id;
      game.saveToLocal();
      _guild = guild;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _joinGuild(GameState game, Guild guild) async {
    setState(() => _loading = true);

    // Dev guilds — join locally without Firestore
    if (guild.id.startsWith('dev_guild_')) {
      final me = GuildMember(
        userId: 'local_player',
        name: game.hero.name,
        heroClass: game.hero.heroClass.name,
        level: game.hero.level,
        lastActive: DateTime.now(),
      );
      guild.members.add(me);
      game.guildId = guild.id;
      game.saveToLocal();
      _guild = guild;
      // Generate weekly boss for dev guild
      if (guild.weeklyBoss == null) {
        guild.weeklyBoss = GuildBoss.generate(guild.memberCount, guild.level);
      }
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final user = _authService.currentUser ?? await _authService.signInAnonymously();
      if (user == null) return;
      final member = GuildMember(
        userId: user.uid,
        name: game.hero.name,
        heroClass: game.hero.heroClass.name,
        level: game.hero.level,
        lastActive: DateTime.now(),
      );
      final ok = await _guildService.joinGuild(guild.id, member);
      if (ok) {
        game.guildId = guild.id;
        game.saveToLocal();
        _guild = await _guildService.fetchGuild(guild.id);
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  // ── Guild View ─────────────────────────────────────────────────────────────

  Widget _buildGuildView(GameState game) {
    final guild = _guild!;
    final boss = guild.weeklyBoss;

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: AppTheme.accentGold,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.accentGold,
            tabs: const [
              Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.info_outline, size: 14), SizedBox(width: 4), Text('INFO')])),
              Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.local_fire_department, size: 14), SizedBox(width: 4), Text('BOSS')])),
              Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.chat_bubble_outline, size: 14), SizedBox(width: 4), Text('CHAT')])),
              Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_bag_outlined, size: 14), SizedBox(width: 4), Text('SHOP')])),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildInfoTab(game, guild),
                _buildBossTab(game, guild, boss),
                _buildChatTab(game, guild),
                _buildShopTab(game),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Tab ───────────────────────────────────────────────────────────────

  Widget _buildInfoTab(GameState game, Guild guild) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guild header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Text(guild.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guild.name.toUpperCase(),
                        style: AppTheme.pixelHeading(fontSize: 15, color: AppTheme.accentGold, letterSpacing: 1)),
                    if (guild.description.isNotEmpty)
                      Text(guild.description,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    const SizedBox(height: 4),
                    Text('Level ${guild.level}  •  ${guild.memberCount}/${guild.maxMembers} members',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Bonuses
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1020),
              border: Border.all(color: AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BonusChip('💰', '+${((guild.goldBonus - 1) * 100).round()}% Gold'),
                _BonusChip('✨', '+${((guild.xpBonus - 1) * 100).round()}% XP'),
                _BonusChip('⚡', '+${((guild.idleBonus - 1) * 100).round()}% Idle'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Guild XP progress
          Row(children: [
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: guild.xp / guild.xpToNextLevel,
                minHeight: 6,
                backgroundColor: AppTheme.cardBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9966ff)),
              ),
            )),
            const SizedBox(width: 8),
            Text('${guild.xp}/${guild.xpToNextLevel} XP',
                style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
          ]),
          const SizedBox(height: 10),

          // Donate gold button
          GestureDetector(
            onTap: game.gold >= 1000 ? () => _donateGold(game, 1000) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: game.gold >= 1000
                    ? AppTheme.accentGold.withValues(alpha: 0.08)
                    : const Color(0xFF1a1a1a),
                border: Border.all(color: game.gold >= 1000
                    ? AppTheme.accentGold.withValues(alpha: 0.5)
                    : AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                const Text('💰', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text('DONATE 1000 GOLD',
                    style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1,
                        color: game.gold >= 1000 ? AppTheme.accentGold : AppTheme.textMuted)),
                const Spacer(),
                Text('→ Guild XP + 🪙',
                    style: TextStyle(fontSize: 9,
                        color: game.gold >= 1000 ? const Color(0xFF44cc88) : AppTheme.textMuted)),
              ]),
            ),
          ),
          const SizedBox(height: 10),

          // Unlocked perks
          if (guild.unlockedPerks.isNotEmpty) ...[
            Text('PERKS', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: guild.unlockedPerks.map((p) =>
              Tooltip(message: p.description, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF9966ff).withValues(alpha: 0.08),
                  border: Border.all(color: const Color(0xFF9966ff).withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('${p.icon} ${p.name}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF9966ff), fontWeight: FontWeight.bold)),
              )),
            ).toList()),
            const SizedBox(height: 6),
          ],
          if (guild.nextPerks.isNotEmpty) ...[
            ...guild.nextPerks.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text('🔒 Lv${p.levelRequired}: ${p.name} — ${p.description}',
                  style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
            )),
          ],
          const SizedBox(height: 14),

          // Members
          Text('MEMBERS', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          ...guild.members.map((m) {
            final isLeader = _authService.currentUser?.uid == guild.leaderId;
            final isSelf = _authService.currentUser?.uid == m.userId;
            final roleIcon = switch (m.role) {
              GuildRole.leader  => '👑',
              GuildRole.officer => '⚔',
              GuildRole.member  => '',
            };
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(children: [
                SizedBox(width: 24, height: 28,
                    child: StaticEnemySprite(spriteId: 'hero_${m.heroClass}', size: 24)),
                const SizedBox(width: 8),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$roleIcon ${m.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                    Text('Lv${m.level} ${m.heroClass}  •  ${m.role.name.toUpperCase()}  •  donated: ${m.totalDonated}g',
                        style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  ],
                )),
                Text('🪙${m.guildCoins}', style: const TextStyle(fontSize: 10, color: AppTheme.accentGold)),
                if (isLeader && !isSelf) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () async {
                      final newRole = m.role == GuildRole.member ? GuildRole.officer : GuildRole.member;
                      await _guildService.promoteMember(guild.id, guild.leaderId, m.userId, newRole);
                      _guild = await _guildService.fetchGuild(guild.id);
                      if (mounted) setState(() {});
                    },
                    child: Icon(m.role == GuildRole.member ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14, color: const Color(0xFF9966ff)),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () async {
                      await _guildService.kickMember(guild.id, _authService.currentUser!.uid, m.userId);
                      _guild = await _guildService.fetchGuild(guild.id);
                      if (mounted) setState(() {});
                    },
                    child: const Icon(Icons.close, size: 14, color: Color(0xFFcc4444)),
                  ),
                ],
              ]),
            );
          }),
          const SizedBox(height: 14),

          // Leave button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _leaveGuild(game),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFcc4444),
                side: const BorderSide(color: Color(0xFFcc4444)),
              ),
              child: const Text('LEAVE GUILD'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _donateGold(GameState game, int amount) async {
    if (game.gold < amount || game.guildId == null) return;
    game.gold -= amount;
    game.saveToLocal();
    try {
      final user = _authService.currentUser;
      if (user == null) return;
      await _guildService.donateGold(game.guildId!, user.uid, amount);
      _guild = await _guildService.fetchGuild(game.guildId!);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _leaveGuild(GameState game) async {
    if (game.guildId == null) return;
    setState(() => _loading = true);

    if (game.guildId!.startsWith('dev_guild_')) {
      game.guildId = null;
      game.saveToLocal();
      _guild = null;
      _publicGuilds = _generateDevGuilds(game);
    } else {
      final user = _authService.currentUser;
      if (user == null) return;
      try {
        await _guildService.leaveGuild(game.guildId!, user.uid);
        game.guildId = null;
        game.saveToLocal();
        _guild = null;
        _publicGuilds = await _guildService.listGuilds();
      } catch (_) {}
    }
    if (mounted) setState(() => _loading = false);
  }

  // ── Boss Tab ───────────────────────────────────────────────────────────────

  Widget _buildBossTab(GameState game, Guild guild, GuildBoss? boss) {
    if (boss == null) {
      return const Center(child: Text('No boss this week.', style: TextStyle(color: AppTheme.textMuted)));
    }

    final sorted = [...guild.members]..sort((a, b) => b.weeklyDamage.compareTo(a.weeklyDamage));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Boss card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a0a2a),
              border: Border.all(color: const Color(0xFFcc44ff).withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Text('☠ WEEKLY GUILD BOSS', style: AppTheme.pixelHeading(
                    fontSize: 11, letterSpacing: 2, color: const Color(0xFFcc44ff))),
                const SizedBox(height: 10),
                SizedBox(height: 60, child: StaticEnemySprite(spriteId: boss.spriteId, size: 56)),
                const SizedBox(height: 8),
                Text(boss.name.toUpperCase(), style: AppTheme.pixelHeading(
                    fontSize: 17, color: const Color(0xFFcc44ff), letterSpacing: 1)),
                const SizedBox(height: 8),
                PixelHealthBar(current: boss.hp, max: boss.maxHp, height: 14),
                const SizedBox(height: 4),
                Text('${boss.hp} / ${boss.maxHp} HP',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                if (boss.defeated) ...[
                  const SizedBox(height: 8),
                  Text('✓ DEFEATED', style: AppTheme.pixelHeading(
                      fontSize: 13, color: const Color(0xFF44cc88))),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Attack button + attempts
          if (!boss.defeated) ...[
            Text('Attempts: ${_maxBossAttacks - _bossAttacksToday} / $_maxBossAttacks',
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _bossAttacksToday < _maxBossAttacks ? () => _startBossFight(game, boss) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B1A1A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.cardBg,
                  disabledForegroundColor: AppTheme.cardBorder,
                ),
                child: Text(
                  _bossAttacksToday >= _maxBossAttacks ? 'NO ATTEMPTS LEFT' : '⚔ CHALLENGE BOSS',
                  style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2,
                      color: _bossAttacksToday >= _maxBossAttacks ? AppTheme.cardBorder : Colors.white)),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Damage leaderboard
          Text('DAMAGE RANKING', style: AppTheme.pixelHeading(
              fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          ...sorted.asMap().entries.map((e) {
            final rank = e.key + 1;
            final m = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 3),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: rank <= 3 ? AppTheme.accentGold.withValues(alpha: 0.05) : AppTheme.cardBg,
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(children: [
                Text('#$rank', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                    color: rank == 1 ? AppTheme.accentGold : AppTheme.textMuted)),
                const SizedBox(width: 8),
                Expanded(child: Text(m.name, style: const TextStyle(fontSize: 12, color: AppTheme.textLight))),
                Text('${m.weeklyDamage} dmg', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _startBossFight(GameState game, GuildBoss boss) async {
    _bossAttacksToday++;
    setState(() => _inBossFight = true);

    final damage = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => _GuildBossBattle(
        game: game,
        boss: boss,
      )),
    );

    _inBossFight = false;
    if (damage != null && damage > 0) {
      _bossFightDamage = damage;
      _applyBossDamage(game, damage);
    }
    if (mounted) setState(() {});
  }

  void _applyBossDamage(GameState game, int damage) {
    final coins = (damage ~/ 100).clamp(1, 50);
    if (game.guildId != null && game.guildId!.startsWith('dev_guild_') && _guild != null) {
      _guild!.weeklyBoss?.takeDamage(damage);
      final idx = _guild!.members.indexWhere((m) => m.userId == 'local_player');
      if (idx >= 0) {
        final old = _guild!.members[idx];
        _guild!.members[idx] = GuildMember(
          userId: old.userId, name: old.name, heroClass: old.heroClass,
          level: old.level, role: old.role,
          weeklyDamage: old.weeklyDamage + damage,
          totalDonated: old.totalDonated,
          guildCoins: old.guildCoins + coins,
          lastActive: DateTime.now(),
        );
      }
      final rng = Random();
      for (int i = 0; i < _guild!.members.length; i++) {
        if (_guild!.members[i].userId == 'local_player') continue;
        if (rng.nextInt(3) == 0) {
          final botDmg = (_guild!.members[i].level * 5 + rng.nextInt(50)) * 10;
          _guild!.weeklyBoss?.takeDamage(botDmg);
          final m = _guild!.members[i];
          _guild!.members[i] = GuildMember(
            userId: m.userId, name: m.name, heroClass: m.heroClass,
            level: m.level, role: m.role,
            weeklyDamage: m.weeklyDamage + botDmg,
            totalDonated: m.totalDonated, guildCoins: m.guildCoins,
            lastActive: m.lastActive,
          );
        }
      }
      game.guildCoins += coins;
      game.saveToLocal();
    }
  }

  Future<void> _attackBoss(GameState game) async {
    if (game.guildId == null || _guild == null) return;
    final damage = (game.hero.damageMod + game.hero.attackBonus + game.hero.level) * 10;
    final coins = (damage ~/ 100).clamp(1, 50);

    if (game.guildId!.startsWith('dev_guild_')) {
      // Dev guild — handle locally
      _guild!.weeklyBoss?.takeDamage(damage);
      // Update local member stats
      final idx = _guild!.members.indexWhere((m) => m.userId == 'local_player');
      if (idx >= 0) {
        final old = _guild!.members[idx];
        _guild!.members[idx] = GuildMember(
          userId: old.userId, name: old.name, heroClass: old.heroClass,
          level: old.level, role: old.role,
          weeklyDamage: old.weeklyDamage + damage,
          totalDonated: old.totalDonated,
          guildCoins: old.guildCoins + coins,
          lastActive: DateTime.now(),
        );
      }
      // Simulate other members also attacking
      final rng = Random();
      for (int i = 0; i < _guild!.members.length; i++) {
        if (_guild!.members[i].userId == 'local_player') continue;
        if (rng.nextInt(3) == 0) { // 33% chance each member also attacks
          final botDmg = (_guild!.members[i].level * 5 + rng.nextInt(50)) * 10;
          _guild!.weeklyBoss?.takeDamage(botDmg);
          final m = _guild!.members[i];
          _guild!.members[i] = GuildMember(
            userId: m.userId, name: m.name, heroClass: m.heroClass,
            level: m.level, role: m.role,
            weeklyDamage: m.weeklyDamage + botDmg,
            totalDonated: m.totalDonated, guildCoins: m.guildCoins,
            lastActive: m.lastActive,
          );
        }
      }
      game.guildCoins += coins;
      game.saveToLocal();
      if (mounted) setState(() {});
      return;
    }

    try {
      final user = _authService.currentUser;
      if (user == null) return;
      await _guildService.dealBossDamage(game.guildId!, user.uid, damage);
      game.guildCoins += coins;
      game.saveToLocal();
      _guild = await _guildService.fetchGuild(game.guildId!);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  // ── Chat Tab ───────────────────────────────────────────────────────────────

  Widget _buildChatTab(GameState game, Guild guild) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(10),
            reverse: true,
            children: guild.messages.reversed.map((m) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: m.isSystem ? const Color(0xFF1a2a1a) : AppTheme.cardBg,
                border: Border(left: BorderSide(
                    color: m.isSystem ? const Color(0xFF44cc88) : AppTheme.accentGold, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(m.senderName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                        color: m.isSystem ? const Color(0xFF44cc88) : AppTheme.accentGold)),
                    const Spacer(),
                    Text(_timeAgo(m.timestamp),
                        style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  ]),
                  const SizedBox(height: 2),
                  Text(m.text, style: const TextStyle(fontSize: 12, color: AppTheme.textLight, height: 1.4)),
                ],
              ),
            )).toList(),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
          color: AppTheme.cardBg,
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _chatCtrl,
                maxLength: 100,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: AppTheme.accentGold, size: 20),
              onPressed: () => _sendMessage(game),
            ),
          ]),
        ),
      ],
    );
  }

  Future<void> _sendMessage(GameState game) async {
    if (_chatCtrl.text.trim().isEmpty || game.guildId == null || _guild == null) return;
    final msg = GuildMessage(
      senderId: 'local_player',
      senderName: game.hero.name,
      text: _chatCtrl.text.trim(),
      timestamp: DateTime.now(),
    );
    if (game.guildId!.startsWith('dev_guild_')) {
      _guild!.messages.add(msg);
      _chatCtrl.clear();
      if (mounted) setState(() {});
      return;
    }
    try {
      await _guildService.sendMessage(game.guildId!, msg);
      _chatCtrl.clear();
      _guild = await _guildService.fetchGuild(game.guildId!);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  // ── Shop Tab ───────────────────────────────────────────────────────────────

  Widget _buildShopTab(GameState game) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1020),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              const Text('🪙', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('${game.guildCoins}',
                  style: GoogleFonts.pixelifySans(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
              const SizedBox(width: 6),
              const Text('Guild Coins', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ]),
          ),
          const SizedBox(height: 14),
          ...GuildShopItem.catalog.map((item) {
            final canAfford = game.guildCoins >= item.cost;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canAfford ? AppTheme.accentGold.withValues(alpha: 0.05) : AppTheme.cardBg,
                border: Border.all(color: canAfford ? AppTheme.accentGold.withValues(alpha: 0.5) : AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                Text(item.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                        color: canAfford ? AppTheme.textLight : AppTheme.textMuted)),
                    Text(item.description, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  ],
                )),
                GestureDetector(
                  onTap: canAfford ? () => _buyGuildItem(game, item) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: canAfford ? AppTheme.accentGold.withValues(alpha: 0.12) : Colors.transparent,
                      border: Border.all(color: canAfford ? AppTheme.accentGold : AppTheme.cardBorder),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('🪙${item.cost}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                        color: canAfford ? AppTheme.accentGold : AppTheme.textMuted)),
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }

  void _buyGuildItem(GameState game, GuildShopItem item) {
    if (game.guildCoins < item.cost) return;
    game.guildCoins -= item.cost;
    switch (item.id) {
      case 'guild_gold_bag':      game.gold     += 5000;
      case 'guild_shard_box':     game.shards   += 50;
      case 'guild_echo_crystal':  game.echoes   += 30;
      case 'guild_mythril_ore':   game.mythril  += 10;
      case 'guild_gem_dust':      game.gemShards += 25;
      case 'guild_essence_vial':  game.essence  += 100;
      case 'guild_crystal_chest': game.crystals += 20;
      case 'guild_xp_scroll':    game.hero.gainExperience(game.hero.experienceToNextLevel ~/ 2);
      default: break;
    }
    game.saveToLocal();
    setState(() {});
  }
}

// ── Helper Widgets ───────────────────────────────────────────────────────────

class _GuildListTile extends StatelessWidget {
  const _GuildListTile({required this.guild, required this.onJoin});
  final Guild guild;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(guild.icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guild.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
            Text('Lv${guild.level}  •  ${guild.memberCount}/${guild.maxMembers} members',
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        )),
        if (!guild.isFull)
          GestureDetector(
            onTap: onJoin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.12),
                border: Border.all(color: AppTheme.accentGold),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('JOIN', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.accentGold)),
            ),
          )
        else
          const Text('FULL', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ]),
    );
  }
}

class _BonusChip extends StatelessWidget {
  const _BonusChip(this.icon, this.label);
  final String icon, label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ],
    );
  }
}

// ── Guild Boss Battle Screen ─────────────────────────────────────────────────

class _GuildBossBattle extends StatefulWidget {
  const _GuildBossBattle({required this.game, required this.boss});
  final GameState game;
  final GuildBoss boss;

  @override
  State<_GuildBossBattle> createState() => _GuildBossBattleState();
}

class _GuildBossBattleState extends State<_GuildBossBattle> {
  late int _heroHp, _heroMaxHp, _bossHp, _bossMaxHp;
  int _totalDamage = 0;
  bool _fighting = true;
  bool _won = false;
  final _rng = Random();
  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    final hero = widget.game.hero;
    _heroHp = hero.currentHealth;
    _heroMaxHp = hero.maxHealth;
    _bossHp = widget.boss.hp.clamp(1, widget.boss.maxHp);
    _bossMaxHp = widget.boss.maxHp;
    _log.add('⚔ ${hero.name} challenges ${widget.boss.name}!');
    _startFight();
  }

  Future<void> _startFight() async {
    await Future.delayed(const Duration(milliseconds: 500));

    while (mounted && _fighting && _heroHp > 0 && _bossHp > 0) {
      // Hero attacks
      final heroDmg = (widget.game.hero.damageMod + widget.game.hero.attackBonus +
          widget.game.inventory.equippedWeaponDamage + _rng.nextInt(8) + 1)
          .clamp(1, 9999);
      _bossHp = (_bossHp - heroDmg).clamp(0, _bossMaxHp);
      _totalDamage += heroDmg;
      setState(() => _log.add('You deal $heroDmg damage! (Boss: $_bossHp/$_bossMaxHp)'));

      if (_bossHp <= 0) {
        // Rewards
        final coins = (_totalDamage ~/ 50).clamp(5, 100);
        final crystalReward = 10;
        widget.game.guildCoins += coins;
        widget.game.crystals += crystalReward;
        widget.game.rollRuneDrop();
        widget.game.saveToLocal();
        setState(() { _won = true; _fighting = false; });
        _log.add('✦ BOSS DEFEATED! Total damage: $_totalDamage');
        _log.add('🪙 +$coins Guild Coins  💎 +$crystalReward Crystals');
        break;
      }

      await Future.delayed(Duration(milliseconds: widget.game.scaledInterval(500)));
      if (!mounted || !_fighting) break;

      // Boss attacks
      final bossAtk = (widget.boss.maxHp ~/ 50).clamp(10, 500);
      final bossDmg = (_rng.nextInt(bossAtk.clamp(1, 9999)) + 1).clamp(1, 9999);
      _heroHp = (_heroHp - bossDmg).clamp(0, _heroMaxHp);
      setState(() => _log.add('${widget.boss.name} hits you for $bossDmg! (You: $_heroHp/$_heroMaxHp)'));

      if (_heroHp <= 0) {
        setState(() { _fighting = false; });
        _log.add('💀 You have fallen! Total damage dealt: $_totalDamage');
        break;
      }

      await Future.delayed(Duration(milliseconds: widget.game.scaledInterval(500)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('GUILD BOSS', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _totalDamage),
        ),
      ),
      body: Column(
        children: [
          // Boss info
          Container(
            padding: const EdgeInsets.all(14),
            color: const Color(0xFF1a0a2a),
            child: Column(children: [
              Row(children: [
                SizedBox(width: 50, height: 50,
                    child: StaticEnemySprite(spriteId: widget.boss.spriteId, size: 48)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('☠ ${widget.boss.name}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFcc44ff))),
                    Text('ATK: ${(widget.boss.maxHp ~/ 50).clamp(10, 500)}',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$_bossHp / $_bossMaxHp',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFcc44ff))),
                  const Text('BOSS HP', style: TextStyle(fontSize: 8, color: AppTheme.textMuted)),
                ]),
              ]),
              const SizedBox(height: 8),
              PixelHealthBar(current: _bossHp, max: _bossMaxHp, height: 10),
            ]),
          ),

          // Hero HP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF0a1a0a),
            child: Row(children: [
              Text('${widget.game.hero.name}  Lv${widget.game.hero.level}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
              const Spacer(),
              Text('$_heroHp / $_heroMaxHp HP',
                  style: TextStyle(fontSize: 11, color: _heroHp < _heroMaxHp * 0.3
                      ? const Color(0xFFcc4444) : const Color(0xFF44cc88))),
            ]),
          ),

          // Battle log
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              reverse: true,
              itemCount: _log.length,
              itemBuilder: (_, i) => Text(
                _log[_log.length - 1 - i],
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
              ),
            ),
          ),

          // Result + back button
          if (!_fighting)
            Container(
              padding: const EdgeInsets.all(14),
              color: _won ? const Color(0xFF0a2a0a) : const Color(0xFF2a0a0a),
              child: Column(children: [
                Text(_won ? '✦ BOSS DEFEATED!' : '💀 FALLEN',
                    style: AppTheme.pixelHeading(fontSize: 16, letterSpacing: 2,
                        color: _won ? const Color(0xFF44cc88) : const Color(0xFFcc4444))),
                const SizedBox(height: 4),
                Text('Total damage dealt: $_totalDamage',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _totalDamage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold.withValues(alpha: 0.15),
                      foregroundColor: AppTheme.accentGold,
                      side: const BorderSide(color: AppTheme.accentGold),
                    ),
                    child: Text('RETURN TO GUILD',
                        style: AppTheme.pixelHeading(fontSize: 12, color: AppTheme.accentGold)),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}
