# SimpMusic Flutter iOS App - Quick Start Implementation Guide

## Executive Summary

This document provides a rapid-start guide for implementing the SimpMusic Flutter iOS application. Two comprehensive PRD documents have been created:

1. **SimpMusic-iOS-PRD.md** (16 sections, 6,000+ words) - Complete product specification
2. **iOS-Visual-Guide.md** - Visual architecture, wireframes, component specs

---

## Phase 1: Setup & Infrastructure (Week 1-2)

### Step 1: Project Initialization
```bash
flutter create simpmusic --platforms ios
cd simpmusic
flutter pub add riverpod riverpod_generator
flutter pub add dio hive hive_flutter
flutter pub add just_audio just_audio_background audio_service
flutter pub add go_router cached_network_image
flutter pub add intl logger
```

### Step 2: iOS Configuration
```bash
# Navigate to iOS project
cd ios
pod install --repo-update
cd ..

# Update Info.plist for background audio
# Add UIBackgroundModes with "audio" value
```

### Step 3: Project Structure
```
lib/
├── main.dart
├── config/
│   ├── routes.dart
│   ├── theme.dart
│   └── constants.dart
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── pages/
├── domain/
│   ├── models/
│   ├── repositories/
│   └── services/
├── application/
│   ├── providers/
│   └── state/
└── infrastructure/
    ├── api/
    ├── storage/
    ├── audio/
    └── platform/
```

---

## Phase 2: Core Playback (Week 3-4)

### Key Components to Build

**1. Audio Handler (infrastructure/audio/audio_handler.dart)**
- Extends AudioHandler from audio_service
- Implements play(), pause(), seek(), next(), previous()
- Manages queue state
- Broadcasts playback events to UI

**2. Playback Provider (application/providers/playback_providers.dart)**
- StateNotifierProvider for PlaybackState
- FutureProvider for loading tracks
- Real-time stream updates for position

**3. Player UI Screen (presentation/screens/player/full_player_screen.dart)**
- Album artwork display
- Playback controls
- Progress slider
- Volume control

### Critical Logic: Queue Management

```dart
// Fisher-Yates Shuffle Algorithm
List<Track> shuffleQueue(List<Track> original) {
  final shuffled = List.from(original);
  for (int i = shuffled.length - 1; i > 0; i--) {
    final j = Random().nextInt(i + 1);
    final temp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp;
  }
  return shuffled;
}

// Repeat Mode Cycling
LoopMode cycleLoopMode(LoopMode current) {
  return switch (current) {
    LoopMode.off => LoopMode.all,
    LoopMode.all => LoopMode.one,
    LoopMode.one => LoopMode.off,
  };
}
```

---

## Phase 3: Discovery (Week 5-7)

### Screens to Implement
1. **HomeScreen** - Carousel, recommendations, grid layouts
2. **SearchScreen** - Real-time search with debouncing
3. **ExploreScreen** - Category browsing, charts
4. **PlaylistDetailScreen** - Songs list, swipe actions

### API Integration Pattern
```dart
// Create API client with Dio
final musicApiProvider = Provider((ref) {
  return MusicApiClient(
    dio: Dio(BaseOptions(
      baseUrl: 'https://api.simpmusic.com',
      connectTimeout: Duration(seconds: 10),
    )),
  );
});

// Use in screens
final homeDataProvider = FutureProvider((ref) async {
  return ref.watch(musicApiProvider).getHomeScreenData();
});
```

---

## Phase 4: User Library (Week 8-10)

### LibraryScreen Structure
```
Segmented Control Tabs:
├── Playlists
│   ├── Fetch from Hive
│   ├── Display with swipe delete
│   └── Create new playlist button
├── Favorites
│   ├── Filter liked tracks
│   └── Sort options
├── Downloads
│   ├── Show cached tracks
│   └── Storage usage indicator
└── History
    └── Recently played with timestamps
```

### Download Management
```dart
// Download service pattern
class DownloadService {
  final dio = Dio();
  final hiveBox = Hive.box('downloads');
  
  Future<void> downloadTrack(Track track) async {
    try {
      final response = await dio.download(
        track.streamUrl,
        _getLocalPath(track.id),
        onReceiveProgress: (received, total) {
          // Update progress state
        },
      );
      await hiveBox.put(track.id, track);
    } catch (e) {
      // Handle error
    }
  }
}
```

---

## Phase 5: Advanced Features (Week 11-13)

### Sleep Timer Implementation
```dart
// Riverpod provider
final sleepTimerProvider = StateNotifierProvider<SleepTimerNotifier, Duration?>((ref) {
  return SleepTimerNotifier(ref);
});

class SleepTimerNotifier extends StateNotifier<Duration?> {
  Timer? _timer;
  
  void startTimer(Duration duration) {
    _timer = Timer(duration, () {
      ref.read(playbackProvider.notifier).pause();
      state = null;
    });
  }
  
  void cancelTimer() {
    _timer?.cancel();
    state = null;
  }
}
```

### Lyrics Synchronization
```dart
// Parse LRC format (Line-based lyrics with timestamps)
class LyricsParser {
  static Map<Duration, String> parseLRC(String content) {
    final lyrics = <Duration, String>{};
    for (final line in content.split('\n')) {
      final match = RegExp(r'\[(\d{2}):(\d{2}).(\d{2})\](.*)').firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final centiseconds = int.parse(match.group(3)!);
        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: centiseconds * 10,
        );
        lyrics[duration] = match.group(4)!;
      }
    }
    return lyrics;
  }
}
```

---

## Phase 6-7: Testing & Deployment (Week 14-20)

### Testing Strategy

**Unit Tests (test/domain/models_test.dart)**
```dart
test('Shuffle produces all unique items', () {
  final original = List.generate(100, (i) => Track(id: '$i'));
  final shuffled = shuffleQueue(original);
  expect(shuffled.length, equals(100));
  expect(shuffled.toSet().length, equals(100)); // All unique
});

test('Loop mode cycles correctly', () {
  expect(cycleLoopMode(LoopMode.off), equals(LoopMode.all));
  expect(cycleLoopMode(LoopMode.all), equals(LoopMode.one));
  expect(cycleLoopMode(LoopMode.one), equals(LoopMode.off));
});
```

**Widget Tests (test/presentation/widgets_test.dart)**
```dart
testWidgets('Play button toggles playback', (WidgetTester tester) async {
  await tester.pumpWidget(const TestApp());
  
  final playButton = find.byIcon(Icons.play_arrow);
  expect(playButton, findsOneWidget);
  
  await tester.tap(playButton);
  await tester.pumpAndSettle();
  
  expect(find.byIcon(Icons.pause), findsOneWidget);
});
```

**Integration Tests (integration_test/app_test.dart)**
```dart
testWidgets('Play song end-to-end', (WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle();
  
  // Navigate to song
  await tester.tap(find.byType(SongTile).first);
  await tester.pumpAndSettle();
  
  // Verify player opened
  expect(find.byType(FullPlayerScreen), findsOneWidget);
  
  // Tap play
  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pumpAndSettle();
  
  // Verify playing state
  expect(playbackState.isPlaying, isTrue);
});
```

---

## Key Technical Decisions

### State Management: Riverpod
- **Why:** Better than Provider, cleaner syntax, no context needed
- **Pattern:** FutureProvider for async data, StateNotifierProvider for mutable state
- **Lifecycle:** Automatic cleanup, ref watching for dependencies

### Audio Backend: just_audio + audio_service
- **Why:** iOS AVFoundation integration, background playback, system control center support
- **Alternative:** AudioPlayers (simpler but fewer features)

### Database: Hive
- **Why:** Fast, doesn't require complex setup, built-in encryption
- **Alternative:** SQLite (more complex), Firebase (needs internet)

### Theme System
- **Light/Dark:** Use system colors, automatic adaptation
- **No custom appearance toggle:** Follow Apple HIG (respect system setting)

---

## Critical Implementation Notes

### 1. Safe Area Handling
```dart
// ALWAYS wrap bottom sheets with proper padding
showModalBottomSheet(
  context: context,
  useSafeArea: true, // Important for notch safety
  builder: (context) => SafeArea(
    child: YourWidget(),
  ),
);
```

### 2. Background Audio Setup
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

### 3. Queue Memory Limit
```dart
// Prevent OutOfMemory with large queues
const MAX_QUEUE_SIZE = 500;

void addToQueue(Track track) {
  if (queue.length >= MAX_QUEUE_SIZE) {
    queue.removeAt(MAX_QUEUE_SIZE - 1);
  }
  queue.add(track);
}
```

### 4. Progress Slider Interaction
```dart
// Use StreamBuilder for real-time updates without rebuilds
StreamBuilder<Duration>(
  stream: audioPlayer.positionStream,
  builder: (context, snapshot) {
    return Slider(
      value: snapshot.data?.inMilliseconds.toDouble() ?? 0,
      onChanged: (value) => audioPlayer.seek(Duration(milliseconds: value.toInt())),
    );
  },
)
```

---

## Performance Targets

| Metric | Target | How to Achieve |
|--------|--------|----------------|
| Cold Start | < 2 sec | Lazy load UI, async init |
| Playback Start | < 1 sec | Pre-buffer on tap |
| Screen Transition | < 300ms | Use const widgets, avoid rebuilds |
| Memory Peak | < 150MB | Cache eviction, dispose timers |
| Network Latency | < 500ms | API optimization, CDN usage |

---

## Release Checklist

- [ ] All screens implemented per PRD
- [ ] Unit test coverage > 80%
- [ ] Widget tests for all main components
- [ ] Integration tests for 3+ critical flows
- [ ] Dark mode tested on iOS 13+
- [ ] Accessibility audit (VoiceOver, contrast ratios)
- [ ] Performance profiling (Xcode instruments)
- [ ] Crash analytics enabled (Sentry)
- [ ] Beta testing on TestFlight (50+ users, 1 week)
- [ ] App Store submission with screenshots/description
- [ ] Launch announcement and marketing

---

## Success Metrics (Post-Launch)

- DAU growth: Target 10,000 within 3 months
- Session duration: Target 20+ minutes average
- Crash-free rate: Target > 99.5%
- User retention: Target > 40% D30
- Search conversion: Target > 40%
- Offline usage: Target > 10% of sessions

---

## Next Steps

1. **Review both PRD documents** (SimpMusic-iOS-PRD.md and iOS-Visual-Guide.md)
2. **Finalize design in Figma** using component specifications
3. **Set up iOS project** with dependencies and configuration
4. **Assign team members** to phases 1-3 (foundation, playback, discovery)
5. **Establish sprint schedule** (2-week sprints)
6. **Create detailed Jira tickets** from PRD screens
7. **Schedule weekly sync** for architecture decisions

---

## Additional Resources

- **Just Audio Docs:** https://pub.dev/packages/just_audio
- **Audio Service Docs:** https://pub.dev/packages/audio_service
- **Riverpod Guide:** https://riverpod.dev
- **iOS HIG:** https://developer.apple.com/design/human-interface-guidelines
- **Flutter Best Practices:** https://flutter.dev/docs/best-practices

---

**Document Version:** 1.0  
**Created:** January 29, 2026  
**Status:** Ready for Development

This guide, combined with the detailed PRD and visual specifications, provides everything needed to build a world-class iOS music streaming application.
