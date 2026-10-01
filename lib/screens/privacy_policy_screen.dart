import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../config/privacy.dart';
import '../widgets/index.dart';

/// C159: offline-bundled privacy policy (mirrors backend LegalController
/// version 2026-10-01 and the landing page). Reachable from Profile and
/// from the register consent checkbox — no network needed.
class PrivacyPolicyScreen extends StatelessWidget {
  static const version = privacyPolicyVersion;
  static const effectiveDate = 'October 1, 2026';
  static const contactEmail = privacyContactEmail;

  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppTheme.onPrimaryButton : AppTheme.primary;
    final bodyColor = CardSurfaces.body(context);

    Widget section(String heading, String body) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: TextStyle(fontSize: 14, height: 1.55, color: bodyColor),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How we handle your information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version $version · Effective $effectiveDate',
              style: TextStyle(fontSize: 13, color: bodyColor),
            ),
            section(
              '1. Who we are',
              'Inea Scents provides a perfume bar service reservation system. '
              'For questions about this policy or your information, contact us at $contactEmail.',
            ),
            section(
              '2. What we collect',
              'Booking contact details (name, email, phone, event date, time slot, headcount), '
              'inquiry details, account name and email, and payment references. '
              'We never see or store card numbers — online payments are processed by PayMongo.',
            ),
            section(
              '3. Why we use it',
              'To take and confirm reservations, coordinate your event, process payments, '
              'and reply to inquiries. We do not sell your information.',
            ),
            section(
              '4. How long we keep it',
              'Inquiries with no activity: 24 months, then anonymized. '
              'Bookings: 36 months, then anonymized. Payment records: 12 months.',
            ),
            section(
              '5. Your rights',
              'You may ask for a copy of your information, correct it, or have it deleted. '
              'Email $contactEmail and we will act on verified requests.',
            ),
            section(
              '6. Cookies and tracking',
              'The app stores only your login session and theme preference on your device. '
              'We run no advertising trackers.',
            ),
          ],
        ),
      ),
    );
  }
}
