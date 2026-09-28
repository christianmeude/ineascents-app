import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'providers/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Landing parity: stored choice wins; otherwise resolve the OS brightness
  // once (no live System follow).
  final persisted = await loadPersistedThemeMode();
  final initial =
      persisted ??
      (WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light);
  runApp(
    ProviderScope(
      overrides: [themeModeProvider.overrideWith((ref) => initial)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Inea Scents',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme
          .darkTheme, // Support dark theme properly as there's no dark theme specified in DESIGN.md, or we can use the default with tweaked colors if we wanted. But DESIGN.md says 'The no-black rule', so forcing light theme or letting it be is fine.
      routerConfig: router,
    );
  }
}
