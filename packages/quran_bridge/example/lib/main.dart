import 'package:flutter/material.dart';
import 'package:quran_bridge/quran_bridge.dart';

void main() => runApp(const QuranBridgeExampleApp());

class QuranBridgeExampleApp extends StatelessWidget {
  const QuranBridgeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Bridge Example',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const _HomeScreen(),
    );
  }
}

// ── Home ──────────────────────────────────────────────────────────────────────

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quran Bridge Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavTile('Surahs',    () => const _SurahsScreen()),
          _NavTile('Page',      () => const _PageScreen()),
          _NavTile('Bookmarks', () => const _BookmarksScreen()),
          _NavTile('Audio',     () => const _AudioScreen()),
        ].map((tile) => tile.build(context)).toList(),
      ),
    );
  }
}

class _NavTile {
  const _NavTile(this.label, this.builder);
  final String label;
  final Widget Function() builder;

  Widget build(BuildContext context) => ListTile(
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => builder()),
        ),
      );
}

// ── Surahs Screen ─────────────────────────────────────────────────────────────

class _SurahsScreen extends StatefulWidget {
  const _SurahsScreen();

  @override
  State<_SurahsScreen> createState() => _SurahsScreenState();
}

class _SurahsScreenState extends State<_SurahsScreen> {
  late final Future<List<Surah>> _future;

  @override
  void initState() {
    super.initState();
    _future = QuranBridge.getSurahs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surahs')),
      body: FutureBuilder<List<Surah>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(snap.error.toString());
          }
          final surahs = snap.requireData;
          return ListView.builder(
            itemCount: surahs.length,
            itemBuilder: (_, i) {
              final s = surahs[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${s.number}')),
                title: Text(s.nameTransliteration),
                subtitle: Text('${s.ayahCount} ayahs · ${s.revelationType}'),
                trailing: Text(
                  s.nameArabic,
                  style: const TextStyle(fontSize: 18),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Page Screen ───────────────────────────────────────────────────────────────

class _PageScreen extends StatefulWidget {
  const _PageScreen();

  @override
  State<_PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<_PageScreen> {
  final _controller = TextEditingController(text: '1');
  Future<PageData>? _future;

  void _load() {
    final page = int.tryParse(_controller.text);
    if (page == null) return;
    setState(() => _future = QuranBridge.getPage(page));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Page number (1–604)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: _load, child: const Text('Load')),
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: _future == null
                  ? const Center(child: Text('Enter a page number and tap Load'))
                  : FutureBuilder<PageData>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snap.hasError) return _ErrorView(snap.error.toString());
                        final page = snap.requireData;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Page ${page.pageNumber} · Juz ${page.juzNumber}',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text('Surahs: ${page.surahNumbers.join(', ')}'),
                            const Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: page.ayahs.length,
                                itemBuilder: (_, i) {
                                  final a = page.ayahs[i];
                                  return ListTile(
                                    leading: Text('${a.surahNumber}:${a.ayahNumber}'),
                                    title: Text(a.textArabic),
                                    subtitle: a.textTranslation != null
                                        ? Text(a.textTranslation!)
                                        : null,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bookmarks Screen ──────────────────────────────────────────────────────────

class _BookmarksScreen extends StatefulWidget {
  const _BookmarksScreen();

  @override
  State<_BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<_BookmarksScreen> {
  List<Bookmark> _bookmarks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await QuranBridge.getBookmarks();
      setState(() => _bookmarks = result);
    } on QuranBridgeException catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addSample() async {
    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surahNumber: 2,
      ayahNumber: 255,
      createdAt: DateTime.now(),
      label: 'Ayat al-Kursi',
    );
    try {
      await QuranBridge.addBookmark(bookmark);
      await _loadBookmarks();
    } on QuranBridgeException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  Future<void> _remove(String id) async {
    try {
      await QuranBridge.removeBookmark(id);
      await _loadBookmarks();
    } on QuranBridgeException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSample,
        tooltip: 'Add sample bookmark',
        child: const Icon(Icons.bookmark_add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(_error!)
              : _bookmarks.isEmpty
                  ? const Center(child: Text('No bookmarks. Tap + to add one.'))
                  : ListView.builder(
                      itemCount: _bookmarks.length,
                      itemBuilder: (_, i) {
                        final b = _bookmarks[i];
                        return ListTile(
                          leading: const Icon(Icons.bookmark),
                          title: Text(b.label ?? '${b.surahNumber}:${b.ayahNumber}'),
                          subtitle: Text('${b.surahNumber}:${b.ayahNumber}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _remove(b.id),
                          ),
                        );
                      },
                    ),
    );
  }
}

// ── Audio Screen ──────────────────────────────────────────────────────────────

class _AudioScreen extends StatefulWidget {
  const _AudioScreen();

  @override
  State<_AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<_AudioScreen> {
  AudioState _state = const AudioState(status: AudioStatus.idle);
  String? _error;

  @override
  void initState() {
    super.initState();
    QuranBridge.audioStates().listen(
      (s) { if (mounted) setState(() => _state = s); },
      onError: (e) { if (mounted) setState(() => _error = e.toString()); },
    );
  }

  Future<void> _play() async {
    try {
      await QuranBridge.playAudio(
        const AudioRequest(surahNumber: 1, reciterId: 'ar.alafasy'),
      );
    } on QuranBridgeException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _pause() async {
    try { await QuranBridge.pauseAudio(); }
    on QuranBridgeException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _stop() async {
    try { await QuranBridge.stopAudio(); }
    on QuranBridgeException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  String _formatMs(int? ms) {
    if (ms == null) return '--:--';
    final d = Duration(milliseconds: ms);
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _state.status == AudioStatus.playing;
    final isPaused  = _state.status == AudioStatus.paused;

    return Scaffold(
      appBar: AppBar(title: const Text('Audio')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Surah Al-Fatiha · ar.alafasy',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            _StatusChip(_state.status),
            const SizedBox(height: 16),
            Text(
              '${_formatMs(_state.positionMs)} / ${_formatMs(_state.durationMs)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  iconSize: 36,
                  onPressed: isPlaying ? _pause : _play,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 16),
                IconButton.outlined(
                  iconSize: 36,
                  onPressed: (isPlaying || isPaused) ? _stop : null,
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              _ErrorView(_error!),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);
  final AudioStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = {
      AudioStatus.idle:    Colors.grey,
      AudioStatus.loading: Colors.orange,
      AudioStatus.playing: Colors.green,
      AudioStatus.paused:  Colors.blue,
      AudioStatus.stopped: Colors.grey,
      AudioStatus.error:   Colors.red,
    };
    return Chip(
      label: Text(status.name.toUpperCase()),
      backgroundColor: colors[status]?.withOpacity(0.15),
      side: BorderSide(color: colors[status] ?? Colors.grey),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
        textAlign: TextAlign.center,
      ),
    );
  }
}
