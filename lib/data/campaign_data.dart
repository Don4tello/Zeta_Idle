import '../models/campaign_stage.dart';

class CampaignData {
  static final stages = [
    CampaignStage(
      id: 'stage_1',
      title: 'Graveyard Gate',
      description: 'A corrupted gatehouse haunted by skeletons and shadow knights.',
      difficulty: 1,
      goldReward: 120,
      experienceReward: 120,
    ),
    CampaignStage(
      id: 'stage_2',
      title: 'Forsaken Keep',
      description: 'A ruined fortress where danger lurks in every hall.',
      difficulty: 2,
      goldReward: 180,
      experienceReward: 180,
    ),
    CampaignStage(
      id: 'stage_3',
      title: 'Abyssal Crypt',
      description: 'Deep beneath the earth, ancient evil waits.',
      difficulty: 3,
      goldReward: 260,
      experienceReward: 260,
    ),
    CampaignStage(
      id: 'stage_4',
      title: 'Dark Throne',
      description: 'Face the corrupted lord and claim the throne of shadows.',
      difficulty: 4,
      goldReward: 340,
      experienceReward: 320,
    ),
    CampaignStage(
      id: 'stage_5',
      title: 'Mossy Ruins',
      description: 'Crumbling walls slick with moss, where ancient stone guardians wake.',
      difficulty: 5,
      goldReward: 440,
      experienceReward: 420,
    ),
    CampaignStage(
      id: 'stage_6',
      title: 'Darkwood Hollow',
      description: 'A cursed forest where wraiths drift between the twisted trees.',
      difficulty: 6,
      goldReward: 540,
      experienceReward: 520,
    ),
    CampaignStage(
      id: 'stage_7',
      title: 'Frosted Peaks',
      description: 'Icy mountain passes prowled by a frost drake of ancient lineage.',
      difficulty: 7,
      goldReward: 660,
      experienceReward: 640,
    ),
    CampaignStage(
      id: 'stage_8',
      title: 'Bloodmarsh',
      description: 'A festering swamp where a blood-soaked ogre lords over the mire.',
      difficulty: 8,
      goldReward: 800,
      experienceReward: 780,
    ),
    CampaignStage(
      id: 'stage_9',
      title: 'Tower of Bones',
      description: 'A bone-carved tower where a lich apprentice channels forbidden magic.',
      difficulty: 9,
      goldReward: 960,
      experienceReward: 940,
    ),
    CampaignStage(
      id: 'stage_10',
      title: 'Spider Citadel',
      description: 'A vast web-shrouded fortress ruled by the Spider Queen herself.',
      difficulty: 10,
      goldReward: 1140,
      experienceReward: 1120,
    ),
    CampaignStage(
      id: 'stage_11',
      title: 'Hellfire Fortress',
      description: 'A keep of molten rock where an infernal knight guards the gate.',
      difficulty: 11,
      goldReward: 1340,
      experienceReward: 1320,
    ),
    CampaignStage(
      id: 'stage_12',
      title: "Dragon's Lair",
      description: 'A volcanic cavern where a battle-hardened dragon whelp awaits.',
      difficulty: 12,
      goldReward: 1560,
      experienceReward: 1540,
    ),
    CampaignStage(
      id: 'stage_13',
      title: 'Throne of the Ancient Lich',
      description: 'The end of all things — the Ancient Lich King rises from his frozen throne.',
      difficulty: 13,
      goldReward: 2000,
      experienceReward: 2000,
    ),
    // ── Infernal Depths: Stages 14–15 ──────────────────────────────────────
    CampaignStage(
      id: 'stage_14',
      title: 'Magma Keep',
      description: 'A volcanic citadel where lava elementals guard forges that never cool. '
          'Heat here is a weapon as much as blade or spell.',
      difficulty: 14,
      goldReward: 2300,
      experienceReward: 2280,
    ),
    CampaignStage(
      id: 'stage_15',
      title: 'The Forge Tyrant',
      description: 'A titan of living metal, born at the volcano\'s heart. '
          'It hammers the earth itself into submission.',
      difficulty: 15,
      goldReward: 2700,
      experienceReward: 2700,
    ),
    // ── Void Expanse: Stages 16–18 ─────────────────────────────────────────
    CampaignStage(
      id: 'stage_16',
      title: 'The Null Chamber',
      description: 'A room where the laws of reality shatter and reform at random. '
          'Nothing here behaves as it should — including your enemies.',
      difficulty: 16,
      goldReward: 3100,
      experienceReward: 3080,
    ),
    CampaignStage(
      id: 'stage_17',
      title: 'Phase Labyrinth',
      description: 'A dimensional maze patrolled by beings that exist in several planes at once. '
          'They strike from directions that should not exist.',
      difficulty: 17,
      goldReward: 3550,
      experienceReward: 3520,
    ),
    CampaignStage(
      id: 'stage_18',
      title: 'The Shattered Cathedral',
      description: 'A once-holy place twisted beyond recognition by void energy. '
          'Its congregation now worships the absence of everything.',
      difficulty: 18,
      goldReward: 4050,
      experienceReward: 4020,
    ),
    CampaignStage(
      id: 'stage_19',
      title: 'Starfall Ruins',
      description: 'Ancient structures from a fallen civilization drift between realities. '
          'Those who built this place no longer exist in any dimension.',
      difficulty: 19,
      goldReward: 4600,
      experienceReward: 4570,
    ),
    CampaignStage(
      id: 'stage_20',
      title: 'The Void Gate',
      description: 'An elder aberration from outside the world tears through reality. '
          'Close the gate — or be consumed by what pours through.',
      difficulty: 20,
      goldReward: 5500,
      experienceReward: 5500,
    ),
    // ── Throne of Ruin: Stages 21–25 ───────────────────────────────────────
    CampaignStage(
      id: 'stage_21',
      title: 'The Dark Citadel',
      description: 'The outer walls of an impossible fortress built from shadow and bone. '
          'Every stone was once a defeated champion.',
      difficulty: 21,
      goldReward: 6200,
      experienceReward: 6170,
    ),
    CampaignStage(
      id: 'stage_22',
      title: 'Hall of Fallen Kings',
      description: 'A gallery of heroes who came before and failed. '
          'Their memories fight on in service of the darkness that claimed them.',
      difficulty: 22,
      goldReward: 7000,
      experienceReward: 6960,
    ),
    CampaignStage(
      id: 'stage_23',
      title: 'The Necropolis Core',
      description: 'The pulsing heart of undead power buried beneath the Throne. '
          'Destroying it will wound the Dark Lord — but first, survive it.',
      difficulty: 23,
      goldReward: 7900,
      experienceReward: 7860,
    ),
    CampaignStage(
      id: 'stage_24',
      title: "The Lich's Sanctum",
      description: 'The inner sanctum where forbidden rituals maintain the Dark Lord\'s immortality. '
          'Break the seals. Shatter the phylactery. End this.',
      difficulty: 24,
      goldReward: 8900,
      experienceReward: 8860,
    ),
    CampaignStage(
      id: 'stage_25',
      title: 'The Dark Lord',
      description: 'The apex of darkness. The author of every curse you have survived. '
          'Defeat him and earn the right to begin again — stronger.',
      difficulty: 25,
      goldReward: 10500,
      experienceReward: 10500,
    ),
    // ── Crystal Sanctum: Stages 26–30 ──────────────────────────────────────
    CampaignStage(
      id: 'stage_26',
      title: 'Crystal Antechamber',
      description: 'The outer halls of an ancient palace hidden deep within the void. '
          'Its walls hum with arcane resonance that sets teeth on edge.',
      difficulty: 26,
      goldReward: 11800,
      experienceReward: 11760,
    ),
    CampaignStage(
      id: 'stage_27',
      title: 'The Gem Mines',
      description: 'Slaves of an ancient crystal curse toil in perpetual silence. '
          'They are part of the mine now — and the mine wants more.',
      difficulty: 27,
      goldReward: 13200,
      experienceReward: 13160,
    ),
    CampaignStage(
      id: 'stage_28',
      title: 'Prism Palace',
      description: 'A palace where focused light bends into blades of pure prismatic energy. '
          'Every reflection is an enemy. Every shadow, a trap.',
      difficulty: 28,
      goldReward: 14800,
      experienceReward: 14760,
    ),
    CampaignStage(
      id: 'stage_29',
      title: 'The Crystal Guardian',
      description: 'Construct defenders of living crystal that shatter into smaller attackers '
          'with every blow. You cannot simply break them.',
      difficulty: 29,
      goldReward: 16600,
      experienceReward: 16560,
    ),
    CampaignStage(
      id: 'stage_30',
      title: 'The Arcane Colossus',
      description: 'A golem of pure crystallized magic, ancient beyond memory. '
          'It was built to end wars. It has never lost one.',
      difficulty: 30,
      goldReward: 19500,
      experienceReward: 19500,
    ),
    // ── Shadow Realm: Stages 31–35 ─────────────────────────────────────────
    CampaignStage(
      id: 'stage_31',
      title: 'Umbral Gate',
      description: 'The entrance to a realm where shadows are solid and light is a wound. '
          'Step carefully — what you cannot see can still reach you.',
      difficulty: 31,
      goldReward: 21800,
      experienceReward: 21760,
    ),
    CampaignStage(
      id: 'stage_32',
      title: 'The Dark Bazaar',
      description: 'A merchant town of shade-cursed traders and contract assassins. '
          'Everything here has a price. Most prices are paid in blood.',
      difficulty: 32,
      goldReward: 24400,
      experienceReward: 24360,
    ),
    CampaignStage(
      id: 'stage_33',
      title: 'The Twilight Keep',
      description: 'A fortress existing simultaneously in light and shadow. '
          'Its defenders phase between planes mid-combat.',
      difficulty: 33,
      goldReward: 27300,
      experienceReward: 27260,
    ),
    CampaignStage(
      id: 'stage_34',
      title: 'The Shadow Court',
      description: 'Whispered judgments from judges whose faces cannot be seen. '
          'The verdict is always the same — and always immediate.',
      difficulty: 34,
      goldReward: 30500,
      experienceReward: 30460,
    ),
    CampaignStage(
      id: 'stage_35',
      title: 'The Shade Sovereign',
      description: 'The ruler of all shadow given physical form. '
          'Strike it in light — but the light here is not yours to control.',
      difficulty: 35,
      goldReward: 36000,
      experienceReward: 36000,
    ),
    // ── Frozen Wastes: Stages 36–40 ────────────────────────────────────────
    CampaignStage(
      id: 'stage_36',
      title: 'The Glacial Pass',
      description: 'A mountain pass locked in supernatural winter. '
          'Frost giants patrol the ice bridges above a thousand-foot drop.',
      difficulty: 36,
      goldReward: 40000,
      experienceReward: 39960,
    ),
    CampaignStage(
      id: 'stage_37',
      title: 'The Ice Tomb',
      description: 'Ancient warriors frozen in the heat of battle, awakening to finish what they started. '
          'They remember nothing but the need to fight.',
      difficulty: 37,
      goldReward: 44500,
      experienceReward: 44460,
    ),
    CampaignStage(
      id: 'stage_38',
      title: 'The Frost Citadel',
      description: 'A fortress carved from a single glacier by frost giant hands. '
          'The cold here is alive, and it hungers.',
      difficulty: 38,
      goldReward: 49500,
      experienceReward: 49460,
    ),
    CampaignStage(
      id: 'stage_39',
      title: 'The Blizzard Spire',
      description: 'A tower at the eye of an eternal magical storm. '
          'The wind strips flesh from bone and the ice finishes the work.',
      difficulty: 39,
      goldReward: 55000,
      experienceReward: 54960,
    ),
    CampaignStage(
      id: 'stage_40',
      title: 'The Frost Dragon',
      description: 'An ancient dragon whose breath does not burn — it freezes time itself. '
          'The last thing its victims see is their own terrified face, forever.',
      difficulty: 40,
      goldReward: 65000,
      experienceReward: 65000,
    ),
    // ── Storm Heights: Stages 41–45 ────────────────────────────────────────
    CampaignStage(
      id: 'stage_41',
      title: 'Cloudbreak Garrison',
      description: 'A sky fortress riding the back of a permanent lightning storm. '
          'Aerial hunters circle it like sharks circling a reef.',
      difficulty: 41,
      goldReward: 72000,
      experienceReward: 71960,
    ),
    CampaignStage(
      id: 'stage_42',
      title: 'The Lightning Fields',
      description: 'An open plain where lightning strikes without warning or mercy. '
          'The creatures here have evolved to call it down on command.',
      difficulty: 42,
      goldReward: 80000,
      experienceReward: 79960,
    ),
    CampaignStage(
      id: 'stage_43',
      title: 'Tempest Tower',
      description: 'A spire that channels every storm in the sky into a single beam '
          'capable of splitting mountains. The defenders wield it freely.',
      difficulty: 43,
      goldReward: 89000,
      experienceReward: 88960,
    ),
    CampaignStage(
      id: 'stage_44',
      title: "Stormwright's Hall",
      description: 'The laboratory of the being that invented thunder. '
          'Every experiment on the shelves is waiting for someone to knock it over.',
      difficulty: 44,
      goldReward: 99000,
      experienceReward: 98960,
    ),
    CampaignStage(
      id: 'stage_45',
      title: 'The Storm Titan',
      description: 'A colossus of condensed lightning and hurricane wind. '
          'The storm does not follow it — it is the storm.',
      difficulty: 45,
      goldReward: 117000,
      experienceReward: 117000,
    ),
    // ── Abyssal Ocean: Stages 46–50 ────────────────────────────────────────
    CampaignStage(
      id: 'stage_46',
      title: 'The Sunken Gate',
      description: 'An ancient doorway beneath a sunless sea. '
          'Whatever it was keeping out has been pushing for centuries.',
      difficulty: 46,
      goldReward: 130000,
      experienceReward: 129960,
    ),
    CampaignStage(
      id: 'stage_47',
      title: 'The Drowned City',
      description: 'A once-great civilization now silent beneath black water. '
          'Its drowned citizens patrol streets that no longer need streets.',
      difficulty: 47,
      goldReward: 145000,
      experienceReward: 144960,
    ),
    CampaignStage(
      id: 'stage_48',
      title: 'The Pressure Vaults',
      description: 'Sealed chambers where the water pressure alone is a weapon. '
          'The things that live here were shaped by it.',
      difficulty: 48,
      goldReward: 162000,
      experienceReward: 161960,
    ),
    CampaignStage(
      id: 'stage_49',
      title: "The Leviathan's Den",
      description: 'A cave system the size of a country, hollowed out by something vast. '
          'That something is still here, still hungry.',
      difficulty: 49,
      goldReward: 181000,
      experienceReward: 180960,
    ),
    CampaignStage(
      id: 'stage_50',
      title: 'Krakentide',
      description: 'The apex predator of the deep given intelligence and ancient malice. '
          'The ocean bends to its will. You are a guest it did not invite.',
      difficulty: 50,
      goldReward: 213000,
      experienceReward: 213000,
    ),
    // ── Twilight Labyrinth: Stages 51–55 ───────────────────────────────────
    CampaignStage(
      id: 'stage_51',
      title: 'The Mirror Halls',
      description: 'Corridors of perfect mirrors that do not reflect you as you are '
          'but as you will be when you have lost everything.',
      difficulty: 51,
      goldReward: 237000,
      experienceReward: 236960,
    ),
    CampaignStage(
      id: 'stage_52',
      title: 'The Echoing Passages',
      description: 'Tunnels where every sound you make returns as an enemy. '
          'Silence is the only safe language here.',
      difficulty: 52,
      goldReward: 264000,
      experienceReward: 263960,
    ),
    CampaignStage(
      id: 'stage_53',
      title: 'The Veil Crossing',
      description: 'A bridge between the waking world and the dreaming one. '
          'Nightmares cross over here whenever they feel like it.',
      difficulty: 53,
      goldReward: 294000,
      experienceReward: 293960,
    ),
    CampaignStage(
      id: 'stage_54',
      title: 'The Blind City',
      description: 'A city whose inhabitants have no eyes but know your every move. '
          'They navigated this maze before the concept of sight existed.',
      difficulty: 54,
      goldReward: 328000,
      experienceReward: 327960,
    ),
    CampaignStage(
      id: 'stage_55',
      title: 'The Labyrinth Warden',
      description: 'The intelligence that designed and inhabits the maze. '
          'It has never had a visitor it could not keep.',
      difficulty: 55,
      goldReward: 386000,
      experienceReward: 386000,
    ),
    // ── Forgotten Empire: Stages 56–60 ─────────────────────────────────────
    CampaignStage(
      id: 'stage_56',
      title: 'The Automated Archives',
      description: 'Libraries tended by construct scribes recording everything — '
          'including the exact moment you stepped inside.',
      difficulty: 56,
      goldReward: 430000,
      experienceReward: 429960,
    ),
    CampaignStage(
      id: 'stage_57',
      title: 'Construct Assembly Line',
      description: 'A factory that never stopped building soldiers for a war '
          'that ended before living memory. The quota is never met.',
      difficulty: 57,
      goldReward: 479000,
      experienceReward: 478960,
    ),
    CampaignStage(
      id: 'stage_58',
      title: "The Emperor's Vault",
      description: 'The treasure room of an emperor who ruled everything and left nothing behind '
          'but automated guardians to protect an empty throne.',
      difficulty: 58,
      goldReward: 533000,
      experienceReward: 532960,
    ),
    CampaignStage(
      id: 'stage_59',
      title: 'The Final Protocol',
      description: 'The last failsafe of the Forgotten Empire, activated when all other defenses fall. '
          'It was never supposed to be necessary.',
      difficulty: 59,
      goldReward: 594000,
      experienceReward: 593960,
    ),
    CampaignStage(
      id: 'stage_60',
      title: 'The Eternal Sentinel',
      description: 'A construct built to outlast its empire, its world, and perhaps time itself. '
          'Its mission log still shows tasks pending.',
      difficulty: 60,
      goldReward: 700000,
      experienceReward: 700000,
    ),
    // ── Plaguelands: Stages 61–65 ───────────────────────────────────────────
    CampaignStage(
      id: 'stage_61',
      title: 'The Blighted Fields',
      description: 'Farmland consumed by a magical pestilence that corrupts flesh and memory alike. '
          'The infected work the fields still, growing nothing useful.',
      difficulty: 61,
      goldReward: 780000,
      experienceReward: 779960,
    ),
    CampaignStage(
      id: 'stage_62',
      title: 'The Infected Citadel',
      description: 'A fortress city where the plague became the government. '
          'Its citizens enforce quarantine — from the outside.',
      difficulty: 62,
      goldReward: 869000,
      experienceReward: 868960,
    ),
    CampaignStage(
      id: 'stage_63',
      title: 'The Plague Monastery',
      description: 'A religious order devoted to the spread of corruption, believing '
          'the plague is divine will made manifest.',
      difficulty: 63,
      goldReward: 968000,
      experienceReward: 967960,
    ),
    CampaignStage(
      id: 'stage_64',
      title: 'The Corruption Core',
      description: 'The source of the plague — a wound in reality festering with magical rot. '
          'It has been growing for a thousand years.',
      difficulty: 64,
      goldReward: 1080000,
      experienceReward: 1079960,
    ),
    CampaignStage(
      id: 'stage_65',
      title: 'The Plague Mother',
      description: 'The original host. The first infected. The being that welcomed the corruption '
          'and made it part of herself — willingly.',
      difficulty: 65,
      goldReward: 1270000,
      experienceReward: 1270000,
    ),
    // ── Celestial Ruins: Stages 66–70 ──────────────────────────────────────
    CampaignStage(
      id: 'stage_66',
      title: 'The Fallen Spire',
      description: 'The highest tower of heaven, now embedded vertically in the earth. '
          'Broken angels still patrol its inverted floors.',
      difficulty: 66,
      goldReward: 1415000,
      experienceReward: 1414960,
    ),
    CampaignStage(
      id: 'stage_67',
      title: 'The Angel Graveyard',
      description: 'A field of divine corpses too large to decompose, still radiating '
          'dangerous levels of celestial energy.',
      difficulty: 67,
      goldReward: 1577000,
      experienceReward: 1576960,
    ),
    CampaignStage(
      id: 'stage_68',
      title: 'The Shattered Halo',
      description: 'The crown of a fallen god, broken into a thousand blades '
          'that orbit the site of its death endlessly.',
      difficulty: 68,
      goldReward: 1757000,
      experienceReward: 1756960,
    ),
    CampaignStage(
      id: 'stage_69',
      title: 'The Divine Wreckage',
      description: 'The crash site of something holy, still burning with heavenly fire '
          'that does not illuminate — it judges.',
      difficulty: 69,
      goldReward: 1958000,
      experienceReward: 1957960,
    ),
    CampaignStage(
      id: 'stage_70',
      title: "The Archangel's Fall",
      description: 'The first angel to fall. Not cast out — it chose to descend. '
          'What it has become in the dark is worse than what it left behind.',
      difficulty: 70,
      goldReward: 2305000,
      experienceReward: 2305000,
    ),
    // ── Dark Matter: Stages 71–75 ───────────────────────────────────────────
    CampaignStage(
      id: 'stage_71',
      title: 'The Null Fields',
      description: 'A region of pure null-energy where existence itself is hostile. '
          'Step here and you become less real with every second.',
      difficulty: 71,
      goldReward: 2570000,
      experienceReward: 2569960,
    ),
    CampaignStage(
      id: 'stage_72',
      title: 'The Anti-Matter Forge',
      description: 'A facility that creates weapons from anti-matter — devices that '
          'unmake whatever they touch at a molecular level.',
      difficulty: 72,
      goldReward: 2865000,
      experienceReward: 2864960,
    ),
    CampaignStage(
      id: 'stage_73',
      title: 'The Entropy Engine',
      description: 'A machine whose purpose is to accelerate the heat death of the universe. '
          'Someone built it. Someone is still running it.',
      difficulty: 73,
      goldReward: 3193000,
      experienceReward: 3192960,
    ),
    CampaignStage(
      id: 'stage_74',
      title: 'The Void Singularity',
      description: 'A point of infinite density from which not even thought escapes. '
          'The constructs orbiting it have given themselves to the pull.',
      difficulty: 74,
      goldReward: 3560000,
      experienceReward: 3559960,
    ),
    CampaignStage(
      id: 'stage_75',
      title: 'The Null Emperor',
      description: 'A being that has consumed so much null-energy it exists '
          'as an absence given will. It wants to share that absence with everything.',
      difficulty: 75,
      goldReward: 4194000,
      experienceReward: 4194000,
    ),
    // ── Eternal Prison: Stages 76–80 ───────────────────────────────────────
    CampaignStage(
      id: 'stage_76',
      title: 'The Outer Walls',
      description: 'Walls built to contain beings too powerful to destroy. '
          'The mortar between the stones is made of crushed hope.',
      difficulty: 76,
      goldReward: 4677000,
      experienceReward: 4676960,
    ),
    CampaignStage(
      id: 'stage_77',
      title: 'Cell Block Omega',
      description: 'The maximum-security wing. The prisoners here were put here '
          'because nothing else worked. They have had time to think.',
      difficulty: 77,
      goldReward: 5213000,
      experienceReward: 5212960,
    ),
    CampaignStage(
      id: 'stage_78',
      title: "The Warden's Keep",
      description: 'The administrative heart of the prison. The Warden has run this place '
          'since before the current era. It has never had a successful escape.',
      difficulty: 78,
      goldReward: 5812000,
      experienceReward: 5811960,
    ),
    CampaignStage(
      id: 'stage_79',
      title: 'The Containment Core',
      description: 'The energy source that powers every seal in the prison. '
          'Destroy it and every cell door opens simultaneously.',
      difficulty: 79,
      goldReward: 6480000,
      experienceReward: 6479960,
    ),
    CampaignStage(
      id: 'stage_80',
      title: 'The Unbound',
      description: 'The original prisoner — the being the prison was built to contain. '
          'The walls have held for an age. They will not hold today.',
      difficulty: 80,
      goldReward: 7636000,
      experienceReward: 7636000,
    ),
    // ── Abyss Gate: Stages 81–85 ───────────────────────────────────────────
    CampaignStage(
      id: 'stage_81',
      title: 'The Threshold',
      description: 'The edge of mapped reality. Old cartographers drew sea monsters here. '
          'They were optimists.',
      difficulty: 81,
      goldReward: 8514000,
      experienceReward: 8513960,
    ),
    CampaignStage(
      id: 'stage_82',
      title: 'The Gate Sentinels',
      description: 'Guardians who have never received a stand-down order. '
          'They have been at their posts longer than most civilizations have existed.',
      difficulty: 82,
      goldReward: 9493000,
      experienceReward: 9492960,
    ),
    CampaignStage(
      id: 'stage_83',
      title: "The Watcher's Post",
      description: 'A watchtower overlooking the nothing beyond the gate. '
          'The watchers no longer know what they are watching for — but they never look away.',
      difficulty: 83,
      goldReward: 10583000,
      experienceReward: 10582960,
    ),
    CampaignStage(
      id: 'stage_84',
      title: 'The Last Warning',
      description: 'A final defense line of ancient weapons, automated and forgotten. '
          'They were set to fire at anything that came close to the gate. '
          'You are close to the gate.',
      difficulty: 84,
      goldReward: 11800000,
      experienceReward: 11799960,
    ),
    CampaignStage(
      id: 'stage_85',
      title: 'The Gate Colossus',
      description: 'A construct the size of a city built to be the last line of defense. '
          'Nothing has ever made it necessary — until now.',
      difficulty: 85,
      goldReward: 13906000,
      experienceReward: 13906000,
    ),
    // ── Shattered Realm: Stages 86–90 ──────────────────────────────────────
    CampaignStage(
      id: 'stage_86',
      title: 'The Carrion Fields',
      description: 'A landscape of divine flesh where a god died and became geography. '
          'The flesh still twitches. Something still feeds.',
      difficulty: 86,
      goldReward: 15504000,
      experienceReward: 15503960,
    ),
    CampaignStage(
      id: 'stage_87',
      title: 'The God-Shard Mines',
      description: 'Miners extract fragments of divinity from the god-corpse. '
          'The fragments remember being divine and react accordingly.',
      difficulty: 87,
      goldReward: 17287000,
      experienceReward: 17286960,
    ),
    CampaignStage(
      id: 'stage_88',
      title: 'The Necrotic Heart',
      description: 'The god\'s heart, still beating with corrupted divine energy '
          'that sustains the realm and everything feeding from it.',
      difficulty: 88,
      goldReward: 19280000,
      experienceReward: 19279960,
    ),
    CampaignStage(
      id: 'stage_89',
      title: 'The Scar of Creation',
      description: 'The wound in reality left by the god\'s death — a tear that '
          'lets in things from outside creation itself.',
      difficulty: 89,
      goldReward: 21498000,
      experienceReward: 21497960,
    ),
    CampaignStage(
      id: 'stage_90',
      title: 'The Devourer',
      description: 'The apex predator that has been feeding on the god-corpse for an age. '
          'It is no longer merely hungry — it has become hunger.',
      difficulty: 90,
      goldReward: 25328000,
      experienceReward: 25328000,
    ),
    // ── Final Frontier: Stages 91–95 ───────────────────────────────────────
    CampaignStage(
      id: 'stage_91',
      title: 'The Boundary Layer',
      description: 'The membrane between this world and the void beyond. '
          'It is thinner here than it has ever been.',
      difficulty: 91,
      goldReward: 28255000,
      experienceReward: 28254960,
    ),
    CampaignStage(
      id: 'stage_92',
      title: 'The Point of No Return',
      description: 'Every explorer who reached this far stopped sending letters. '
          'You find out why as soon as you arrive.',
      difficulty: 92,
      goldReward: 31514000,
      experienceReward: 31513960,
    ),
    CampaignStage(
      id: 'stage_93',
      title: 'The Void Membrane',
      description: 'A living barrier between existence and non-existence. '
          'It does not want you to pass. It is very persuasive.',
      difficulty: 93,
      goldReward: 35140000,
      experienceReward: 35139960,
    ),
    CampaignStage(
      id: 'stage_94',
      title: 'The Last Light',
      description: 'The final point where any light from your world reaches. '
          'Beyond this, only the darkness the Omega Throne casts.',
      difficulty: 94,
      goldReward: 39186000,
      experienceReward: 39185960,
    ),
    CampaignStage(
      id: 'stage_95',
      title: 'The Frontier Guardian',
      description: 'A being that has stood at the edge of everything for longer '
          'than memory. It was put here to ensure no one reached what lies beyond.',
      difficulty: 95,
      goldReward: 46179000,
      experienceReward: 46179000,
    ),
    // ── Omega Throne: Stages 96–100 ────────────────────────────────────────
    CampaignStage(
      id: 'stage_96',
      title: 'The Antechamber of the End',
      description: 'The waiting room before the final confrontation. '
          'The servants of the Omega have been preparing for your arrival since the beginning.',
      difficulty: 96,
      goldReward: 51494000,
      experienceReward: 51493960,
    ),
    CampaignStage(
      id: 'stage_97',
      title: 'The Memory Halls',
      description: 'Corridors lined with the memories of every hero who ever tried and failed. '
          'The Omega keeps trophies.',
      difficulty: 97,
      goldReward: 57416000,
      experienceReward: 57415960,
    ),
    CampaignStage(
      id: 'stage_98',
      title: 'The Darkest Hour',
      description: 'The moment before the end — when the light is at its lowest '
          'and the darkness believes it has already won.',
      difficulty: 98,
      goldReward: 64030000,
      experienceReward: 64029960,
    ),
    CampaignStage(
      id: 'stage_99',
      title: 'The Throne Approach',
      description: 'The final corridor. Every step here is witnessed by the Omega itself. '
          'It is deciding whether you are worthy of a proper ending.',
      difficulty: 99,
      goldReward: 71381000,
      experienceReward: 71380960,
    ),
    CampaignStage(
      id: 'stage_100',
      title: 'The Omega',
      description: 'The original darkness. The first and the last. '
          'Every curse, every enemy, every shadow you have faced was its fingerprint. '
          'This is the hand itself.',
      difficulty: 100,
      goldReward: 84100000,
      experienceReward: 84100000,
    ),
  ];
}
