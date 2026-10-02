import 'package:flutter/material.dart';

import '../config/scents.dart';
import 'card_surfaces.dart';

/// C144: multi-select Scent shelf — grouped `Women` / `Men` shelves with an
/// `n/4` counter. Selection state lives in the caller (booking flow
/// `selectedScentIds` via `toggleScent`); reaching the cap disables
/// unselected tiles (deselects always stay enabled).
class ScentShelf extends StatelessWidget {
  final Map<String, List<ScentChoice>> groups;
  final List<int> selectedIds;
  final ValueChanged<int> onToggle;
  final int max;

  const ScentShelf({
    super.key,
    required this.groups,
    required this.selectedIds,
    required this.onToggle,
    this.max = maxScentsPerChoice,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = CardSurfaces.title(context);
    final bodyColor = CardSurfaces.body(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Choose your Scents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
            Text(
              scentCounterLabel(selectedIds.length),
              key: const Key('scent_counter'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pick up to $max Scents.',
          style: TextStyle(fontSize: 12, color: bodyColor),
        ),
        const SizedBox(height: 12),
        for (final category in scentCategories) ...[
          if ((groups[category] ?? const <ScentChoice>[]).isNotEmpty) ...[
            Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 600;
                final crossAxisCount = wide ? 4 : 2;
                final items = groups[category]!;
                return GridView.builder(
                  key: Key('scent_grid_$category'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 168,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final choice = items[i];
                    final id = choice.id ?? -1;
                    final selected = selectedIds.contains(id);
                    final enabled =
                        selected || selectedIds.length < max;
                    return _ScentTile(
                      choice: choice,
                      selected: selected,
                      enabled: enabled,
                      onTap: enabled ? () => onToggle(id) : null,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _ScentTile extends StatelessWidget {
  final ScentChoice choice;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _ScentTile({
    required this.choice,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = CardSurfaces.title(context);
    final id = choice.id ?? -1;
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: GestureDetector(
        key: Key('scent_tile_$id'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CardSurfaces.cardBg(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? CardSurfaces.title(context)
                  : CardSurfaces.cardBorder(context),
              width: selected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: choice.asset != null
                      ? Image.asset(
                          choice.asset!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                            Icons.spa_outlined,
                            size: 36,
                            color: titleColor,
                          ),
                        )
                      : Icon(
                          Icons.spa_outlined,
                          size: 36,
                          color: titleColor,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      choice.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: titleColor,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// C144: read-only selected-Scents chips for the booking flow Schedule
/// stage — display only, no toggle, no delete. Renders nothing when empty
/// so the desktop fixed Schedule layout keeps its geometry.
class SelectedScentsChips extends StatelessWidget {
  /// Resolved shelf (API-preferred, bundle fallback) for id → name lookup.
  final List<ScentChoice> choices;
  final List<int> selectedIds;

  const SelectedScentsChips({
    super.key,
    required this.choices,
    required this.selectedIds,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIds.isEmpty) return const SizedBox.shrink();
    final byId = {for (final c in choices) c.id: c};
    final titleColor = CardSurfaces.title(context);
    return Container(
      key: const Key('selected_scents_chips'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CardSurfaces.cardBg(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CardSurfaces.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Scents',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in selectedIds)
                Chip(
                  key: Key('selected_scent_chip_$id'),
                  label: Text(byId[id]?.name ?? 'Scent $id'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
