import '../api/models/scent.dart';

/// C144: bundled Scent shelf catalog (display fallback).
///
/// The backend `Package.scents` list carries names (no category or asset),
/// so grouping (Women / Men) and tile artwork resolve through this bundle
/// map by name matching. When the API list is present it wins for ids and
/// names; this map only supplies category + asset. When the API list is
/// empty the bundle entries themselves render (fallback ids 1–8).
class ScentBundleEntry {
  /// Lowercase fragments; a scent matches when its name contains any of them.
  final List<String> matchKeys;

  /// Short display label used for the fallback shelf.
  final String displayName;

  /// Shelf group: `Women` or `Men`.
  final String category;

  /// Bundle artwork under `assets/images/scents/`.
  final String asset;

  const ScentBundleEntry({
    required this.matchKeys,
    required this.displayName,
    required this.category,
    required this.asset,
  });
}

/// C144: the 8 bundled scents — Women 4, Men 4.
const scentBundle = <ScentBundleEntry>[
  ScentBundleEntry(
    matchKeys: ['ariana', 'cloud'],
    displayName: 'Ariana Cloud',
    category: 'Women',
    asset: 'assets/images/scents/ariana-cloud.png',
  ),
  ScentBundleEntry(
    matchKeys: ['burberry her', 'burberry'],
    displayName: 'Burberry Her',
    category: 'Women',
    asset: 'assets/images/scents/burberry.png',
  ),
  ScentBundleEntry(
    matchKeys: ['bright crystal'],
    displayName: 'Versace Bright Crystal',
    category: 'Women',
    asset: 'assets/images/scents/versace-bright.png',
  ),
  ScentBundleEntry(
    matchKeys: ['nectarine', 'jo malone'],
    displayName: 'Jo Malone Nectarine Blossom & Honey',
    category: 'Women',
    asset: 'assets/images/scents/jm-nectarine.png',
  ),
  ScentBundleEntry(
    matchKeys: ['1 million', 'one million', 'one-million'],
    displayName: '1 Million',
    category: 'Men',
    asset: 'assets/images/scents/one-million.png',
  ),
  ScentBundleEntry(
    matchKeys: ['aventus'],
    displayName: 'Creed Aventus',
    category: 'Men',
    asset: 'assets/images/scents/creed-aventus.png',
  ),
  ScentBundleEntry(
    matchKeys: ['eros'],
    displayName: 'Versace Eros',
    category: 'Men',
    asset: 'assets/images/scents/versace-eros.png',
  ),
  ScentBundleEntry(
    matchKeys: ['clinique happy', 'happy'],
    displayName: 'Clinique Happy for Men',
    category: 'Men',
    asset: 'assets/images/scents/clinique-happy.png',
  ),
];

/// C144: one resolved shelf row — an API scent (or bundle fallback) with
/// its group + artwork attached. `id` is null only for bundle fallbacks
/// rendered without an API list (fallback ids below fill it instead).
class ScentChoice {
  final int? id;
  final String name;
  final String category;
  final String? asset;

  const ScentChoice({
    required this.id,
    required this.name,
    required this.category,
    this.asset,
  });
}

/// C144: maximum scents per booking (shelf counter cap).
const maxScentsPerChoice = 4;

/// C144: shelf group order.
const scentCategories = ['Women', 'Men'];

ScentBundleEntry? _matchBundle(String name) {
  final lowered = name.toLowerCase();
  for (final entry in scentBundle) {
    for (final key in entry.matchKeys) {
      if (lowered.contains(key)) return entry;
    }
  }
  return null;
}

/// C144: resolves the shelf from the API list when present, else the
/// bundle fallback (ids 1–8 in bundle order). Unmatched API names split
/// across groups by position so both groups stay non-empty.
List<ScentChoice> resolveScentChoices(List<Scent>? apiScents) {
  if (apiScents != null && apiScents.isNotEmpty) {
    final out = <ScentChoice>[];
    for (var i = 0; i < apiScents.length; i++) {
      final scent = apiScents[i];
      final name = (scent.name ?? '').trim().isEmpty
          ? 'Scent ${i + 1}'
          : scent.name!.trim();
      final match = _matchBundle(name);
      out.add(
        ScentChoice(
          id: scent.id,
          name: name,
          category:
              match?.category ??
              (i < (apiScents.length / 2).ceil() ? 'Women' : 'Men'),
          asset: match?.asset,
        ),
      );
    }
    return out;
  }
  return [
    for (var i = 0; i < scentBundle.length; i++)
      ScentChoice(
        id: i + 1,
        name: scentBundle[i].displayName,
        category: scentBundle[i].category,
        asset: scentBundle[i].asset,
      ),
  ];
}

/// C144: groups resolved choices into `Women` / `Men` shelves.
Map<String, List<ScentChoice>> groupScentChoices(List<Scent>? apiScents) {
  final groups = {for (final c in scentCategories) c: <ScentChoice>[]};
  for (final choice in resolveScentChoices(apiScents)) {
    (groups[choice.category] ?? groups['Women']!).add(choice);
  }
  return groups;
}

/// C144: pure counter-cap gate (testable): true when tapping [id] may
/// change the selection — deselects always pass, selects need room.
bool canSelectMoreScent(List<int> selected, int id) {
  if (selected.contains(id)) return true;
  return selected.length < maxScentsPerChoice;
}

/// C144: `n/4` shelf counter label.
String scentCounterLabel(int selected) => '$selected/$maxScentsPerChoice';
