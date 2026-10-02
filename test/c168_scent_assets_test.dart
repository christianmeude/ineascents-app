import 'package:flutter_test/flutter_test.dart';
import 'package:inea_scents_client/api/models/scent.dart';
import 'package:inea_scents_client/config/scents.dart';

/// C168: the 8 official backend names (A39 reseed) resolve to the 8 bundled
/// photos in `assets/images/scents/` — no missing-asset fallback in the
/// detail shelf for any of them.
void main() {
  const officialAssets = <String, String>{
    'Ariana Cloud': 'assets/images/scents/ariana-cloud.png',
    'Burberry Her': 'assets/images/scents/burberry.png',
    'Versace Bright Crystal': 'assets/images/scents/versace-bright.png',
    'Jo Malone Nectarine Blossom & Honey':
        'assets/images/scents/jm-nectarine.png',
    '1 Million': 'assets/images/scents/one-million.png',
    'Creed Aventus': 'assets/images/scents/creed-aventus.png',
    'Versace Eros': 'assets/images/scents/versace-eros.png',
    'Clinique Happy for Men': 'assets/images/scents/clinique-happy.png',
  };

  const officialNames = <String>[
    'Ariana Cloud',
    'Burberry Her',
    'Versace Bright Crystal',
    'Jo Malone Nectarine Blossom & Honey',
    '1 Million',
    'Creed Aventus',
    'Versace Eros',
    'Clinique Happy for Men',
  ];

  /// Retired pre-A39 long promo names — must not linger as bundle entries.
  const retiredNames = <String>[
    'Ariana Grande Cloud Eau de Parfum',
    'Burberry Her Eau de Parfum',
    'Versace Bright Crystal Eau de Toilette',
    'Jo Malone London Nectarine Blossom & Honey Cologne',
    'Rabanne 1 Million Eau de Toilette',
    'Creed Aventus Eau de Parfum',
    'Versace Eros Eau de Toilette',
    'Clinique Happy for Men Cologne Spray',
  ];

  List<Scent> officialApi() => [
    for (var i = 0; i < officialNames.length; i++)
      Scent(id: i + 1, name: officialNames[i]),
  ];

  group('c168 official scent asset map', () {
    test('bundle displayNames match the 8 official names verbatim', () {
      expect(
        scentBundle.map((e) => e.displayName).toSet(),
        officialAssets.keys.toSet(),
      );
    });

    test('no retired long promo names remain as bundle entries', () {
      final display = scentBundle.map((e) => e.displayName).toSet();
      for (final retired in retiredNames) {
        expect(display, isNot(contains(retired)));
      }
    });

    test('each official name resolves to its photo (no fallback)', () {
      final choices = resolveScentChoices(officialApi());
      expect(choices.length, 8);
      for (final choice in choices) {
        expect(
          choice.asset,
          isNotNull,
          reason: 'missing asset for ${choice.name}',
        );
        expect(choice.asset, officialAssets[choice.name]);
      }
    });

    test('official list groups Women 4 / Men 4', () {
      final groups = groupScentChoices(officialApi());
      expect(groups['Women']!.length, 4);
      expect(groups['Men']!.length, 4);
      expect(
        groups['Women']!.map((c) => c.name),
        containsAll([
          'Ariana Cloud',
          'Burberry Her',
          'Versace Bright Crystal',
          'Jo Malone Nectarine Blossom & Honey',
        ]),
      );
      expect(
        groups['Men']!.map((c) => c.name),
        containsAll([
          '1 Million',
          'Creed Aventus',
          'Versace Eros',
          'Clinique Happy for Men',
        ]),
      );
    });

    test('bundle fallback carries a photo for every row', () {
      final fallback = resolveScentChoices(null);
      expect(fallback.length, 8);
      expect(
        fallback.map((c) => c.asset),
        everyElement(startsWith('assets/images/scents/')),
      );
    });
  });
}
