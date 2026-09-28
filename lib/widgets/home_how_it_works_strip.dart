import 'package:flutter/material.dart';

import 'card_surfaces.dart';

/// C91: minimal How-it-works strip for Home (Browse → Schedule).
class HomeHowItWorksStrip extends StatelessWidget {
  const HomeHowItWorksStrip({super.key, this.compact = false});

  /// C99: rail placement forces the vertical step stack — the 1/4 rail is
  /// too narrow for the two-column switch, and LayoutBuilder cannot live
  /// under the IntrinsicHeight the hero row needs for equal height.
  final bool compact;

  static const steps = <({String title, String body})>[
    (
      title: 'Browse',
      body: 'Explore Offerings and choose your Package.',
    ),
    (
      title: 'Schedule',
      body: 'Check your date on the availability calendar.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_how_it_works'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CardSurfaces.cardBg(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CardSurfaces.cardBorder(context)),
        boxShadow: [
          BoxShadow(
            color: CardSurfaces.plum.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: CardSurfaces.title(context),
            ),
          ),
          const SizedBox(height: 14),
          if (compact)
            const _StepsColumn()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >=
                    _HowItWorksBreakpoints.twoCol;
                if (!wide) {
                  return const _StepsColumn();
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < steps.length; i++) ...[
                      if (i > 0) const SizedBox(width: 16),
                      Expanded(
                        child: _StepRow(
                          index: i + 1,
                          title: steps[i].title,
                          body: steps[i].body,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Narrower than the app shell tablet breakpoint so the two steps stack
/// on phones even inside the padded home column.
abstract final class _HowItWorksBreakpoints {
  static const double twoCol = 600.0;
}

/// Vertical step stack — phone layout and C99 rail mode.
class _StepsColumn extends StatelessWidget {
  const _StepsColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < HomeHowItWorksStrip.steps.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _StepRow(
            index: i + 1,
            title: HomeHowItWorksStrip.steps[i].title,
            body: HomeHowItWorksStrip.steps[i].body,
          ),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String title;
  final String body;

  const _StepRow({
    required this.index,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CardSurfaces.chipBg(context),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CardSurfaces.title(context),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CardSurfaces.title(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: CardSurfaces.body(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
