import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/index.dart';

/// C16/C26: Home is a concierge stack, not a catalog. Check-date CTA first,
// then the C11 upcoming Booking, one Offering teaser (→ /packages).
// No catalog grid lives here.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // C40: clamp overscroll on mobile (<768px); SDK default
          // (stretch Android / bounce iOS) displaced content past edge.
          // Desktop/web physics untouched (null = platform default).
          physics: MobileClampScroll.physicsOf(context),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ResponsiveAppShell.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // C42: unified header (mobile logo row retired — brand
                  // lives in TopNavBar on tablet/desktop).
                  // C72: shared header token; bottom 0 preserves the exact
                  // prior visuals (SizedBox h18 + horizontal 20, gap below
                  // stays the SizedBox h20).
                  Padding(
                    padding:
                        ResponsiveAppShell.screenHeaderPadding.copyWith(
                      bottom: 0,
                    ),
                    child: const TabHeader(
                      title: 'Home',
                      count: 'Plan your scent experience.',
                    ),
                  ),
                  // C60: Q9 retired — the flow itself resumes the draft
                  // at its stored stage.
                  const SizedBox(height: 20),
                  // C91: two-column concierge body on tablet/desktop
                  // (screen width ≥ mobileBreakpoint 768), stacked on
                  // mobile. Col 1: upcoming Booking; col 2: next step +
                  // teaser. MediaQuery (not LayoutBuilder constraints) so
                  // the 768px breakpoint matches the repo tablet token
                  // exactly — padded content width would shift it to 808.
                  // No catalog grid lives here.
                  // C99: asymmetric hero rail on wide — 3/4 Upcoming hero
                  // + 1/4 How-it-works rail, equal height via stretch
                  // (strip fills its slot), teaser + next step full-width
                  // below. Mobile keeps the stacked concierge order with
                  // the strip below.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Builder(
                      builder: (context) {
                        final wide = MediaQuery.sizeOf(context).width >=
                            ResponsiveAppShell.mobileBreakpoint;
                        if (!wide) {
                          return const Column(
                            key: Key('home_stacked'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UpcomingBookingSection(),
                              SizedBox(height: 16),
                              NextStepCard(),
                              SizedBox(height: 16),
                              _OfferingTeaser(),
                              SizedBox(height: 16),
                              HomeHowItWorksStrip(),
                            ],
                          );
                        }
                        return const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // C99: max content — row height is the tallest
                            // child; stretch fills both to it (unbounded
                            // scroll height forbids bare stretch).
                            IntrinsicHeight(
                              child: Row(
                                key: Key('home_two_col'),
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: UpcomingBookingSection(),
                                  ),
                                  SizedBox(width: 16),
                                  // C99: strip fills the rail slot so both
                                  // cards share the row height visually.
                                  Expanded(
                                    flex: 1,
                                    child: HomeHowItWorksStrip(
                                      compact: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            NextStepCard(),
                            SizedBox(height: 16),
                            _OfferingTeaser(),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single static teaser into the Offerings list. No fetching here.
class _OfferingTeaser extends StatelessWidget {
  const _OfferingTeaser();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('home_offering_teaser'),
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
          // C112: theme type ramp (explicit Figtree) + heading semantics.
          Semantics(
            header: true,
            child: Text(
              'Explore our Offerings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CardSurfaces.title(context),
                  ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check your date, then pick a Pax Choice for your event.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  height: 1.4,
                  color: CardSurfaces.body(context),
                ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            key: const Key('home_view_offerings_cta'),
            // C31: plum/cream token both modes (was dark-on-dark).
            style: FilledButton.styleFrom(
              backgroundColor: CardSurfaces.plum,
              foregroundColor: CardSurfaces.onPrimaryButton,
            ),
            onPressed: () => context.go('/packages'),
            child: const Text('View Offerings'),
          ),
        ],
      ),
    );
  }
}
