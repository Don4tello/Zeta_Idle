import 'package:flutter/widgets.dart';

import 'content_de.dart';
import 'content_es.dart';
import 'content_fr.dart';
import 'content_pl.dart';
import 'content_pt.dart';

/// Localization layer for **bulk game CONTENT** (campaign stages, class quests,
/// system tutorials, daily-challenge templates, patch notes …).
///
/// Unlike UI chrome — which lives in the gen-l10n ARB files as static getters —
/// game content is keyed by the stable `id` each data entry already carries, so
/// a static-getter approach doesn't fit. Instead each locale ships a flat
/// `Map<String,String>` keyed by `'<id>.<field>'` (e.g. `'stage_1.title'`,
/// `'barb_q0.desc'`). English stays inline in the `lib/data/*` files as both the
/// logic source and the fallback; translations live in `content_<lang>.dart`.
///
/// Resolution keys off [Localizations.localeOf], which is driven by
/// `LocaleController` (the same Settings language picker that drives the ARB
/// locale), so switching language updates content and chrome together.
///
/// Add a language: create `content_<code>.dart` exporting its map and wire it
/// into [_mapFor].
class ContentL10n {
  const ContentL10n(this._map);

  final Map<String, String>? _map;

  static ContentL10n of(BuildContext context) =>
      ContentL10n(_mapFor(Localizations.localeOf(context).languageCode));

  static Map<String, String>? _mapFor(String lang) => switch (lang) {
        'de' => kContentDe,
        'es' => kContentEs,
        'fr' => kContentFr,
        'pl' => kContentPl,
        'pt' => kContentPt,
        _ => null, // English is the inline fallback — no map needed.
      };

  /// Returns the localized string for `'<id>.<field>'`, falling back to the
  /// inline [english] when there's no translation (or the locale is English).
  String tr(String id, String field, String english) {
    final map = _map;
    if (map == null) return english;
    return map['$id.$field'] ?? english;
  }

  /// Like [tr] for templated content: the translated string may carry an `{n}`
  /// placeholder which is substituted with [n]. The English fallback already
  /// has its number baked in, so substitution is a no-op there.
  String trN(String id, String field, String english, int n) =>
      tr(id, field, english).replaceAll('{n}', '$n');
}
