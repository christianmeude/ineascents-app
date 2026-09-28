import 'package:web/web.dart' as web;

import 'checkout_window.dart';

/// Brand tokens mirrored from the app theme (see DESIGN.md): deep plum on
/// warm ivory, system font stack so the page renders before any webfont.
const _plum = '#6A4053';
const _ivory = '#FAF7F2';
const _muted = '#8A6A53';

const _pageCss =
    '''
*{box-sizing:border-box;margin:0;padding:0}
body{background:$_ivory;color:$_plum;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;min-height:100vh;display:flex;align-items:center;justify-content:center}
.card{text-align:center;padding:48px 32px;max-width:420px}
.brand{letter-spacing:.35em;font-size:13px;font-weight:700;color:$_muted;margin-bottom:28px}
.ring{width:44px;height:44px;margin:0 auto 24px;border-radius:50%;border:3px solid rgba(106,64,83,.18);border-top-color:$_plum;animation:spin 1s linear infinite}
@keyframes spin{to{transform:rotate(360deg)}}
h1{font-size:20px;font-weight:700;margin-bottom:12px}
p{font-size:14px;line-height:1.5;color:$_muted}
''';

CheckoutWindow? openCheckoutWindow() {
  final win = web.window.open('', '_blank');
  if (win == null) return null;
  try {
    final doc = win.document;
    doc.title = 'Preparing secure checkout · Inea Scents';
    final style = web.HTMLStyleElement()..textContent = _pageCss;
    final head = doc.head;
    if (head != null) head.append(style);
    final body = doc.body;
    if (body != null) {
      final card = web.HTMLDivElement()..className = 'card';
      final brand = web.HTMLDivElement()
        ..className = 'brand'
        ..textContent = 'Inea Scents';
      final ring = web.HTMLDivElement()..className = 'ring';
      final heading = web.HTMLHeadingElement.h1()
        ..textContent = 'Preparing your secure checkout…';
      final note = web.HTMLParagraphElement()
        ..textContent =
            'You will be redirected to our payment partner momentarily. '
            'Please keep this tab open.';
      card
        ..append(brand)
        ..append(ring)
        ..append(heading)
        ..append(note);
      body.append(card);
    }
    return _WebCheckoutWindow(win);
  } catch (_) {
    // Same-origin access can fail in locked-down contexts; the caller
    // falls back to launchUrl plus the on-screen recovery button.
    try {
      win.close();
    } catch (_) {}
    return null;
  }
}

final class _WebCheckoutWindow implements CheckoutWindow {
  web.Window? _win;

  _WebCheckoutWindow(this._win);

  @override
  void navigateTo(String url) {
    final win = _win;
    _win = null;
    if (win == null) return;
    try {
      win.location.href = url;
    } catch (_) {}
  }

  @override
  void close() {
    final win = _win;
    _win = null;
    if (win == null) return;
    try {
      win.close();
    } catch (_) {}
  }
}
