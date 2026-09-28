import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// C100: browser tab title + web meta/manifest — title, OG/Twitter,
/// theme-color, manifest/icons correct, zero Flutter placeholders.
void main() {
  late String html;
  late Map<String, Object?> manifest;

  setUpAll(() {
    html = File('web/index.html').readAsStringSync();
    manifest = jsonDecode(File('web/manifest.json').readAsStringSync())
        as Map<String, Object?>;
  });

  test('title + description carry the brand, zero placeholders', () {
    expect(html, contains('<title>Inea Scents</title>'));
    expect(
      html,
      contains(
          'content="Inea Scents — bespoke scent experiences for unforgettable events."'),
    );
    expect(html, isNot(contains('A new Flutter project.')));
    expect(
      manifest['description'],
      'Inea Scents — bespoke scent experiences for unforgettable events.',
    );
  });

  test('theme-color meta + manifest match the plum token', () {
    expect(html, contains('<meta name="theme-color" content="#6a4053">'));
    expect(html, isNot(contains('#0175C2')));
    expect(manifest['theme_color'], '#6a4053');
    expect(manifest['background_color'], '#fdf4f5');
  });

  test('OG/Twitter tags present', () {
    expect(html, contains('<meta property="og:title" content="Inea Scents">'));
    expect(html, contains('<meta property="og:type" content="website">'));
    expect(html, contains('<meta property="og:description"'));
    expect(
        html, contains('<meta name="twitter:card" content="summary">'));
    expect(
        html, contains('<meta name="twitter:title" content="Inea Scents">'));
    expect(html, contains('<meta name="twitter:description"'));
  });

  test('manifest name + icons resolve to real files', () {
    expect(manifest['name'], 'Inea Scents');
    final icons = manifest['icons'] as List;
    expect(icons, isNotEmpty);
    for (final entry in icons) {
      final map = entry as Map<String, dynamic>;
      expect(map['src'], isA<String>());
      final src = map['src'] as String;
      expect(File('web/$src').existsSync(), isTrue, reason: src);
    }
    expect(File('web/favicon.png').existsSync(), isTrue);
  });
}
