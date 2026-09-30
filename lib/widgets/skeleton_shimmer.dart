import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// C126: single-source skeleton shimmer — every loading skeleton resolves
/// base/highlight here so tone stays uniform (and muted) across screens.
///
/// Muted by construction: base sits close to the surface tint and highlight
/// lifts only one step, so the sweep reads as a whisper, never a flash.
/// C84 invariant kept: one parent Shimmer, children are plain Containers.
class SkeletonShimmer extends StatelessWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  /// Muted base for a [brightness] (pure, testable).
  static Color baseFor(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF2B2126)
      : const Color(0xFFC2B3B9);

  /// Muted highlight for a [brightness] (pure, testable).
  static Color highlightFor(Brightness brightness) =>
      brightness == Brightness.dark
      ? const Color(0xFF453540)
      : const Color(0xFFE4D9DE);

  static Color baseOf(BuildContext context) =>
      baseFor(Theme.of(context).brightness);

  static Color highlightOf(BuildContext context) =>
      highlightFor(Theme.of(context).brightness);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseOf(context),
      highlightColor: highlightOf(context),
      child: child,
    );
  }
}
