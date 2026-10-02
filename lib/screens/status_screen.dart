import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/index.dart';

/// C161: static system status placeholder. No network calls — offline-aware
/// via the shared cached-catalog banner when [offline] is true.
class StatusScreen extends StatelessWidget {
  final bool offline;

  const StatusScreen({super.key, this.offline = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        leading: IconButton(
          tooltip: 'Back to home',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                'System status',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            if (offline) const CatalogOfflineBanner(),
            if (offline) const SizedBox(height: 12),
            const Text('All systems operational'),
            const SizedBox(height: 20),
            Semantics(
              button: true,
              label: 'Back to home',
              child: FilledButton(
                key: const Key('status_back_home'),
                onPressed: () => context.go('/home'),
                child: const Text('Back to home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
