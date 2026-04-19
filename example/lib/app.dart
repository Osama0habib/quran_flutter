import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/surah_list_screen.dart';
import 'screens/page_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'widgets/audio_controls.dart';
import 'providers/audio_provider.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'surahs',
          builder: (context, state) => const SurahListScreen(),
        ),
        GoRoute(
          path: '/page/:number',
          name: 'page',
          builder: (context, state) {
            final number = int.parse(state.pathParameters['number']!);
            return PageScreen(pageNumber: number);
          },
        ),
        GoRoute(
          path: '/bookmarks',
          name: 'bookmarks',
          builder: (context, state) => const BookmarksScreen(),
        ),
      ],
    ),
  ],
);

class QuranBridgeExampleApp extends StatelessWidget {
  const QuranBridgeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Quran Bridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      routerConfig: _router,
    );
  }
}

/// Root shell — persistent bottom nav + audio bar.
class _AppShell extends ConsumerWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final audioAsync = ref.watch(audioStateProvider);

    final isAudioActive = audioAsync.whenOrNull(
          data: (s) =>
              s.status.name != 'idle' && s.status.name != 'stopped',
        ) ==
        true;

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAudioActive) const AudioControls(),
          NavigationBar(
            selectedIndex: _selectedIndex(location),
            onDestinationSelected: (i) => _onTap(context, i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Surahs',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline),
                selectedIcon: Icon(Icons.bookmark),
                label: 'Bookmarks',
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith('/bookmarks')) return 1;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed('surahs');
      case 1:
        context.goNamed('bookmarks');
    }
  }
}
