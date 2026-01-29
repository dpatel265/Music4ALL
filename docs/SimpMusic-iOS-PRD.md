# SimpMusic Flutter iOS App - Product Requirements Document

**Version:** 1.0  
**Date:** January 29, 2026  
**Platform:** iOS (iPhone)  
**Framework:** Flutter  
**Backend Status:** Ready (Existing API)  
**Target iOS Version:** iOS 13+  

---

## 1. Executive Summary

This PRD outlines the complete product specification for a Flutter-based music streaming application for iOS that leverages the SimpMusic reference architecture. The app provides ad-free music streaming from YouTube Music, featuring playlist management, lyrics synchronization, offline capabilities, and a polished iOS-native user experience.

**Key Differentiators:**
- Free music streaming without premium subscriptions
- YouTube Music data integration
- Multi-source lyrics sync (Musixmatch, LRCLIB, Spotify, YouTube)
- Offline playback with intelligent caching
- Sleep timer and personalized recommendations
- Full iOS integration with lock screen controls and background playback

---

## 2. User Experience Architecture

### 2.1 Information Architecture

The app follows a tab-based navigation model optimized for iOS conventions, with a persistent mini-player for queue visibility.

```
┌─────────────────────────────────────┐
│  Status Bar (Time, Battery, Signal) │
├─────────────────────────────────────┤
│                                     │
│      Tab-Specific Content           │
│      (Home/Search/Library/etc)      │
│                                     │
├─────────────────────────────────────┤
│   Mini Player Bar (Dismissible)     │
├─────────────────────────────────────┤
│  Bottom Tab Navigation (5 Tabs)     │
└─────────────────────────────────────┘
```

**Primary Navigation Tabs:**
1. **Home** - Personalized recommendations, trending content
2. **Explore** - Browse by mood, genre, podcast categories
3. **Search** - Global search across songs, artists, playlists
4. **Library** - Saved playlists, favorites, downloads
5. **Profile** - Account settings, preferences, playback history

### 2.2 Core Screen Hierarchy

#### Screen 1: Splash/Onboarding
- Launch animation with app logo
- Optional onboarding (first-time users)
- API connectivity check
- Redirect to Home on completion
- Duration: 2-3 seconds

#### Screen 2: Home Screen
- Header with greeting message (time-sensitive)
- "Continue Listening" carousel (recent tracks)
- "Recommended For You" section (personalized)
- "New Releases" horizontal scroll
- "Trending Now" playlist tiles
- "Moods & Genres" grid (6-8 items)
- Pull-to-refresh functionality
- Loading shimmer effects during data fetch

#### Screen 3: Search Screen
- Search bar at top (persistent)
- Recent searches displayed (horizontal tabs or list)
- Search results grid:
  - Songs (with artist name, duration)
  - Artists (with follower count)
  - Playlists (with song count)
  - Albums (with year, artist)
- Infinite scroll with pagination
- Clear search history option

#### Screen 4: Explore/Browse Screen
- Category grid (Moods, Genres, Podcasts, Charts)
- Each category opens a filtered view
- Featured playlists carousel
- Charts sections (Top 50, Trending, New)
- Category detail pages with infinite scroll

#### Screen 5: Library Screen
- Segmented tabs: Playlists | Favorites | Downloads | History
- **Playlists tab:**
  - User-created playlists list
  - "Create Playlist" button (floating action)
  - Swipe-to-delete gesture
- **Favorites tab:**
  - Liked songs list
  - Sort options (date added, artist, duration)
- **Downloads tab:**
  - Downloaded tracks organized by date
  - Storage usage indicator
  - Batch delete option
- **History tab:**
  - Recently played tracks
  - Timestamp for each play

#### Screen 6: Full Player Screen
- Album artwork (large, centered, draggable)
- Artist name and track title
- Current progress bar with time indicators
- Playback controls (previous, play/pause, next)
- Secondary controls row:
  - Repeat mode toggle (off → all → one)
  - Shuffle toggle
  - Queue button (opens queue viewer)
- Volume slider with icons
- Bottom action buttons:
  - Like/Heart icon (favorite toggle)
  - Share button
  - Add to playlist
  - More options (equalizer, speed, lyrics)
- Swipe-down gesture to minimize to mini-player
- Swipe-up gesture to open lyrics view

#### Screen 7: Mini Player
- Album thumbnail (left)
- Song title & artist name (center)
- Play/pause button (right)
- Tap to expand to full player
- Persistent across navigation

#### Screen 8: Queue/Now Playing Screen
- List of upcoming tracks
- Highlight current track
- Drag-to-reorder functionality
- Swipe-to-remove from queue
- "Clear Queue" button
- Queue size indicator

#### Screen 9: Lyrics Screen
- Scrollable lyrics aligned with playback
- Current line highlighted
- Synchronized line animation as song plays
- Font size adjustment slider
- Copy lyrics button
- Translation support (if available)
- Dark mode optimized for readability

#### Screen 10: Playlist Detail Screen
- Header with playlist artwork
- Playlist name, creator, song count
- Playlist options button (edit, delete, share)
- Songs list with swipe actions:
  - Remove from playlist (left)
  - Add to queue (right)
- Pull-to-refresh to sync with backend
- Shuffle playlist button (sticky header)

#### Screen 11: Artist Detail Screen
- Artist image and name (header)
- Follow/Unfollow button
- Top tracks section
- Albums grid
- Related artists carousel
- Biography text (expandable)

#### Screen 12: Settings Screen
- Account section:
  - Current user info (if logged in)
  - Login/Logout button
  - Account management
- Playback section:
  - Default volume level
  - Playback quality (streaming quality selection)
  - Normalizer toggle
  - Gapless playback toggle
- Download settings:
  - Storage location
  - Auto-delete old downloads
  - Download quality
- Display section:
  - Light/Dark mode toggle
  - Font size preference
  - Theme color picker
- Notifications:
  - Artist updates toggle
  - New release alerts toggle
  - Release radar notifications
- About:
  - App version
  - Feedback button
  - Privacy policy link
  - Terms of service link

---

## 3. UI/UX Design System

### 3.1 Design Principles

**iOS Human Interface Compliance**
- Follows Apple HIG (Human Interface Guidelines)
- Respects iOS 13+ design conventions
- Native iOS components (CupertinoTabBar, CupertinoNavigationBar)
- Safe area adherence (notch, home indicator)

**Visual Hierarchy**
- Typography: San Francisco font family (system default)
- Heading sizes: 32pt (h1), 24pt (h2), 18pt (h3), 16pt (h4)
- Body text: 16pt (regular), 14pt (secondary)
- Labels: 12pt (tertiary information)

**Color Palette**
- Primary accent: Brand color (e.g., #FF6B00 for SimpMusic orange)
- Secondary accent: Complementary color
- System colors for light/dark mode:
  - Background: systemBackground (adapts to theme)
  - Text: label (primary), secondaryLabel
  - Separators: separator, opaqueSeparator

**Dark Mode Support**
- Mandatory on iOS 13+
- Use system colors that automatically adapt
- Shadows adjusted for dark backgrounds
- No pure black (#000000) for backgrounds; use systemBackground instead
- Icons should use SF Symbols for automatic adaptation

### 3.2 Component Library

**Typography**
```
Heading 1 (32pt, Bold): Used for screen titles, splash screens
Heading 2 (24pt, Semibold): Section headers, playlist names
Heading 3 (18pt, Semibold): Sub-section headers, artist names
Body (16pt, Regular): Content text, song descriptions
Secondary (14pt, Regular): Supporting text, timestamps
Label (12pt, Regular): Icons labels, helper text
```

**Buttons**
- **Primary Button:** Filled background, white text, 44pt minimum height
- **Secondary Button:** Bordered style, transparent background
- **Icon Button:** SF Symbols, 24x24pt minimum tap target
- **Floating Action Button (FAB):** Create playlist in Library, 56x56pt

**Cards**
- Album card: Artwork + Title + Artist (rounded corners, shadow)
- Playlist card: Artwork + Title + Song count
- Artist card: Image + Name + "Follow" button
- Song row: Thumbnail + Title + Artist + Duration

**Interactive Elements**
- **Sliders:** Progress bar (16pt height), volume slider (interactive, tappable)
- **Toggle Switches:** For shuffle, repeat mode, dark mode
- **Segmented Control:** For Library tab switching
- **Bottom Sheet:** For player expansion, playlist creation
- **Modal Dialogs:** For confirmations, alerts

### 3.3 Spacing & Layout

**8-point Grid System**
- Standard padding: 8pt, 16pt, 24pt, 32pt
- Card margins: 16pt horizontal, 12pt vertical
- Safe area insets: Respected on iPhone with notch (iPhone X+)
- Bottom safe area: Min 16pt padding above home indicator

**Responsive Design**
- Fixed layouts for iPhone (320pt to 428pt widths)
- Portrait orientation primary
- Landscape support for player screen
- Dynamic spacing based on screen size category

---

## 4. Functional Specifications

### 4.1 Playback Engine & Logic

#### Audio Playback Stack
- **Core Player Library:** just_audio (Flutter package)
- **Background Service:** audio_service (iOS AVFoundation integration)
- **Background Controls:** just_audio_background (lock screen/control center)
- **Audio Format Support:** MP3, AAC, OGG, FLAC (backend-dependent)

#### Playback Controls Logic

**Play/Pause**
```
State: Playing → Paused
State: Paused → Playing
State: Stopped → Playing (resume from last position)
Behavior: Single tap on play button toggles state
Lock Screen: System media controls sync state
```

**Next Track**
```
Condition: Current track position < 3 seconds
  → Skip to next in queue
Condition: Current track position >= 3 seconds
  → Restart current track (reset to 0:00)
Queue: Auto-load next from queue
Last Track: Loop behavior depends on repeat mode
```

**Previous Track**
```
Behavior: Jump to start of current track (0:00)
Double-tap: Skip to previous track in queue
First Track: If repeat=one, restart; else pause
```

**Seek/Progress**
```
Slider Interaction: Real-time seek with visual feedback
Range: 0:00 to Total Duration
Behavior: Scrubbing (dragging) pauses audio during interaction
Release: Resumes playback from new position
Lock Position: Display current time + total duration

Stream Updates:
- Every 100ms position update
- Duration available on track load
- Buffered state tracking
```

**Loop/Repeat Modes**
```
Mode Off (default):
  → No repetition, stops after last track

Mode All:
  → After last track, restart from first
  → Queue repeats indefinitely
  → Visual indicator: Single loop icon

Mode One:
  → Current track repeats indefinitely
  → Skip commands ignored (user must manually change track)
  → Visual indicator: Loop icon with "1"

Interaction: Tap repeat button cycles through modes
State Persistence: Save to local storage
```

**Shuffle**
```
Toggle: Enables/disables shuffle mode
Algorithm: Fisher-Yates shuffle on queue
Behavior:
  → OFF: Play queue in original order
  → ON: Randomize queue order (current track remains current)
  → Does NOT replay recently heard songs
  
When Shuffle Enabled:
  → Original queue order stored in memory
  → Shuffled order generated and applied
  → Return to original on toggle OFF
  
Queue Refresh: New tracks append in shuffled order
State Persistence: Save to playback session state
```

**Volume Control**
```
Range: 0-100%
Hardware Buttons: Forward to system volume
Software Slider: Interactive volume adjustment
Visualization: Volume icon changes based on level
Mute: Tap speaker icon to mute (volume → 0)
Unmute: Tap speaker icon again (restore previous level)
```

**Queue Management**
```
Max Queue Size: 500 tracks (backend limit)
Current Position: Tracked in queue array
Add to Queue:
  → Append to end of current queue
  → OR insert after current track
Remove from Queue:
  → Swipe-to-delete gesture
  → Removes without stopping playback
Clear Queue:
  → Confirmation dialog required
  → Stops playback
Reorder Queue:
  → Drag-to-reorder in UI
  → Persistent during session
```

#### Advanced Features

**Sleep Timer**
```
Duration Options: 5, 10, 15, 30, 45, 60 minutes
Trigger: Settings → Playback section
Display: Remaining time in mini-player
Behavior: 
  → Fade out audio gradually (last 10 seconds)
  → Stop playback at duration end
  → Close mini-player after stop
Cancellation: Tap "Cancel" in sleep timer display
```

**Equalizer**
```
Presets:
  → Default (flat response)
  → Bass Boost
  → Treble Boost
  → Classical
  → Dance
  → Pop
  → Rock
Custom EQ: 5-band equalizer (adjustable sliders)
Persistence: Save custom settings
Backend: Implemented via just_audio audio effects
```

**Playback Speed**
```
Speeds: 0.5x, 0.75x, 1.0x (default), 1.25x, 1.5x, 2.0x
Control: Settings or player menu
Display: Current speed in mini-player (if >1.0x)
Persistence: Save as user preference
```

#### Offline Playback

**Download Logic**
```
Trigger: Download button in track or playlist detail
Storage:
  → iOS documents directory (iCloud backup optional)
  → Filename: hash(trackId).mp3
Download Queue:
  → Background queue with max 3 concurrent downloads
  → Respect device storage limits
  → Pause/Resume capability
Progress:
  → Show % downloaded in UI
  → Total size indication
Cleanup:
  → Manual deletion via Library → Downloads
  → Auto-delete old downloads (if enabled in settings)
```

**Offline Playback**
```
Availability: Display offline indicator for cached tracks
Playback:
  → Load from local cache if available
  → Fallback to streaming if cache unavailable
  → No internet check required for offline tracks
Limitations:
  → Lyrics not available offline
  → No real-time recommendations
```

#### Caching Strategy

**Smart Cache**
```
Cache Types:
  → Track metadata (songs, artists, playlists)
  → Artwork thumbnails (compressed, max 10MB total)
  → Playback state (current track, position, queue)

TTL (Time-to-Live):
  → Playlist metadata: 24 hours
  → User library: 6 hours
  → Search results: 1 hour
  → Artwork: 7 days

Storage Limits:
  → Metadata cache: 50MB
  → Thumbnail cache: 10MB
  → User can manually clear cache

Strategies:
  → LRU (Least Recently Used) eviction
  → Compression for images (JPEG, WebP)
```

---

## 5. Data Model & State Management

### 5.1 Core Data Models

```dart
// Song/Track
class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String artworkUrl;
  final String streamUrl;
  final bool isAvailableOffline;
  final bool isFavorite;
  final int playCount;
  DateTime? lastPlayedAt;
  DateTime? addedToLibraryAt;
}

// Playlist
class Playlist {
  final String id;
  final String name;
  final String description;
  final String? artworkUrl;
  final List<String> trackIds; // References to Track.id
  final int songCount;
  final String creatorId;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final bool isPublic;
}

// Artist
class Artist {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final int followerCount;
  final bool isFollowing;
  final List<String> topTrackIds;
  final List<String> albumIds;
}

// Album
class Album {
  final String id;
  final String title;
  final String artist;
  final String? artworkUrl;
  final List<String> trackIds;
  final int releaseYear;
  final int trackCount;
}

// Playback State
class PlaybackState {
  final Track? currentTrack;
  final int currentIndex;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isMuted;
  final double volume; // 0.0 to 1.0
  final LoopMode loopMode; // off, all, one
  final bool isShuffled;
  final List<Track> queue;
  final int? sleepTimerRemaining; // milliseconds
}

// User Profile
class UserProfile {
  final String userId;
  final String username;
  final String email;
  final String? avatarUrl;
  final List<String> favoriteTrackIds;
  final List<String> playlistIds;
  final List<String> followedArtistIds;
  final DateTime accountCreatedAt;
}

// Search Result
class SearchResult {
  final List<Track> tracks;
  final List<Playlist> playlists;
  final List<Artist> artists;
  final List<Album> albums;
  final String query;
  final int totalResults;
}
```

### 5.2 State Management Architecture

**Framework: Riverpod (StateNotifierProvider + AsyncNotifierProvider)**

```dart
// Track/Search Providers
final searchQueryProvider = StateProvider<String>((ref) => '');
final searchResultsProvider = FutureProvider((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return SearchResult.empty();
  return ref.watch(musicApiProvider).search(query);
});

final homeScreenProvider = FutureProvider((ref) async {
  return ref.watch(musicApiProvider).getHomeScreenData();
});

final playlistProvider = FutureProvider.family((ref, playlistId) async {
  return ref.watch(musicApiProvider).getPlaylist(playlistId);
});

// Playback State Management
class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier(this.ref) : super(PlaybackState.initial());
  
  final Ref ref;
  
  Future<void> play() async { /* ... */ }
  Future<void> pause() async { /* ... */ }
  Future<void> seek(Duration position) async { /* ... */ }
  Future<void> next() async { /* ... */ }
  Future<void> previous() async { /* ... */ }
  Future<void> setLoopMode(LoopMode mode) async { /* ... */ }
  Future<void> toggleShuffle() async { /* ... */ }
  Future<void> setVolume(double volume) async { /* ... */ }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  return PlaybackNotifier(ref);
});

// User Library State
class LibraryNotifier extends StateNotifier<UserLibrary> {
  LibraryNotifier(this.ref) : super(UserLibrary.initial());
  
  final Ref ref;
  
  Future<void> addToFavorites(Track track) async { /* ... */ }
  Future<void> removeFromFavorites(String trackId) async { /* ... */ }
  Future<void> createPlaylist(String name) async { /* ... */ }
  Future<void> addToPlaylist(String playlistId, Track track) async { /* ... */ }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, UserLibrary>((ref) {
  return LibraryNotifier(ref);
});

// API Provider
final musicApiProvider = Provider((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return MusicApiClient(httpClient);
});
```

### 5.3 Local Persistence

**Package: hive (lightweight, fast NoSQL database)**

```
Hive Boxes:
├── playback_state (current playback info, queue)
├── user_library (favorites, playlists, downloads)
├── search_cache (recent searches, cached results)
├── app_settings (user preferences)
├── track_metadata (cached track info)
├── playlist_metadata (cached playlist info)
└── artwork_cache (downloaded album/artist images)
```

---

## 6. Technical Architecture

### 6.1 Folder Structure

```
lib/
├── main.dart
├── config/
│   ├── routes.dart (GoRouter configuration)
│   ├── theme.dart (Light/Dark mode themes)
│   └── constants.dart
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   ├── search/
│   │   │   ├── search_screen.dart
│   │   │   └── search_results_screen.dart
│   │   ├── explore/
│   │   │   └── explore_screen.dart
│   │   ├── library/
│   │   │   ├── library_screen.dart
│   │   │   ├── playlists_tab.dart
│   │   │   ├── favorites_tab.dart
│   │   │   └── downloads_tab.dart
│   │   ├── player/
│   │   │   ├── full_player_screen.dart
│   │   │   ├── lyrics_screen.dart
│   │   │   ├── queue_screen.dart
│   │   │   └── mini_player.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   └── widgets/
│       ├── bottom_tab_navigation.dart
│       ├── track_tile.dart
│       ├── album_card.dart
│       └── custom_sliders.dart
├── domain/
│   ├── models/ (Business logic models)
│   │   ├── track.dart
│   │   ├── playlist.dart
│   │   ├── artist.dart
│   │   └── playback_state.dart
│   ├── repositories/
│   │   ├── music_repository.dart (Interface)
│   │   ├── playback_repository.dart
│   │   └── library_repository.dart
│   └── services/
│       ├── analytics_service.dart
│       └── notification_service.dart
├── application/
│   ├── providers/ (Riverpod providers)
│   │   ├── music_providers.dart
│   │   ├── playback_providers.dart
│   │   └── library_providers.dart
│   └── state/
│       ├── playback_notifier.dart
│       └── library_notifier.dart
└── infrastructure/
    ├── api/
    │   ├── http_client.dart
    │   ├── api_endpoints.dart
    │   └── music_api_client.dart
    ├── storage/
    │   ├── hive_storage.dart
    │   └── cache_manager.dart
    ├── audio/
    │   ├── audio_handler.dart
    │   └── audio_player_service.dart
    └── platform/
        └── ios_native_handler.dart (For native iOS APIs)
```

### 6.2 Dependency Injection

**Using Riverpod's Ref system for dependency management:**

```dart
// API Client Provider
final httpClientProvider = Provider((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.simpmusic.com',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
});

final musicApiProvider = Provider((ref) {
  return MusicApiClient(ref.watch(httpClientProvider));
});

// Storage Providers
final hiveStorageProvider = Provider((ref) {
  return HiveStorage();
});

final cacheManagerProvider = Provider((ref) {
  return DefaultCacheManager();
});

// Audio Service Provider
final audioServiceProvider = FutureProvider((ref) async {
  final handler = JustAudioHandler();
  await AudioService.init(
    builder: () => handler,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.simpmusic',
      androidNotificationChannelName: 'SimpMusic',
    ),
  );
  return handler;
});
```

### 6.3 Error Handling & Logging

```dart
// Error Types
enum ApiErrorType {
  networkError,
  serverError,
  authenticationError,
  notFound,
  validationError,
  unknown,
}

class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final Exception? originalException;
  
  ApiException({
    required this.type,
    required this.message,
    this.originalException,
  });
}

// Logging
final loggerProvider = Provider((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
});
```

---

## 7. Implementation Timeline & Phases

### Phase 1: Foundation (Weeks 1-3)
- Project setup, dependencies, Riverpod configuration
- Theme system (light/dark mode, colors, typography)
- Navigation structure (GoRouter, bottom tab bar)
- Basic network layer with API client
- Audio service setup (just_audio, audio_service)

### Phase 2: Core Playback (Weeks 4-6)
- Full player screen UI
- Playback controls logic (play, pause, next, previous)
- Progress bar with seek functionality
- Queue management
- Mini-player with dragging
- Lock screen integration

### Phase 3: Discovery & Content (Weeks 7-10)
- Home screen with recommendations
- Search functionality with results
- Browse/Explore screens
- Artist and album detail screens
- Playlist detail screens

### Phase 4: User Library (Weeks 11-13)
- Library screen (playlists, favorites, downloads, history)
- Favorite/like functionality
- Playlist creation and editing
- Download management
- Offline playback

### Phase 5: Advanced Features (Weeks 14-16)
- Lyrics synchronization and display
- Sleep timer
- Equalizer
- Playback speed control
- Artist notifications
- Analytics/listening history

### Phase 6: Polish & Testing (Weeks 17-19)
- UI/UX refinements
- Performance optimization
- Comprehensive testing (unit, widget, integration)
- Accessibility audit (VoiceOver)
- Bug fixes and stability improvements

### Phase 7: Deployment (Week 20)
- TestFlight beta release
- App Store submission
- Release notes preparation
- Marketing materials

---

## 8. Design Specifications by Screen

### Screen: Full Player (Detailed UI Spec)

**Layout Components (from top to bottom):**

1. **Header Bar (44pt height)**
   - Left: Collapse/dismiss button (SF Symbols: "chevron.down")
   - Center: "Now Playing" text (14pt, secondary label)
   - Right: More options button (SF Symbols: "ellipsis")
   - Separator line at bottom

2. **Album Artwork Section (280pt height)**
   - Centered square image with rounded corners (16pt radius)
   - Shadow: 0px 4px 12px rgba(0,0,0,0.15)
   - Draggable: Recognizes vertical pan gesture
   - Padding: 24pt from edges

3. **Song Information**
   - Artist name (14pt, secondary label)
   - Track title (24pt, bold, primary label)
   - Album name (12pt, tertiary label)
   - Spacing: 12pt between each

4. **Progress Indicator**
   - Current time (12pt, tertiary)
   - Progress slider (interactive, 44pt tap target)
   - Total duration (12pt, tertiary)
   - Layout: Time | Slider | Duration (flex)

5. **Playback Controls (72pt height)**
   - Layout: 5 buttons (wrap in Row)
   - Previous button (SF: "backward.end.fill")
   - Play/Pause button (SF: "play.fill" / "pause.fill", larger)
   - Next button (SF: "forward.end.fill")
   - Repeat mode button (SF: cycles through loop icons)
   - Shuffle button (SF: "shuffle", gray when off, colored when on)
   - Button size: 40x40pt, spacing: 12pt

6. **Volume Control**
   - Speaker icon (SF: "speaker.fill")
   - Slider (full width, 44pt height)
   - Speaker icon (SF: "speaker.3.fill")
   - Layout: Icon | Slider | Icon (padding 16pt)

7. **Action Buttons (56pt height)**
   - Like/Favorite (SF: "heart" / "heart.fill")
   - Share (SF: "square.and.arrow.up")
   - Add to Playlist (SF: "plus.circle")
   - More (SF: "ellipsis.circle")
   - Button size: 44x44pt, spacing: 12pt
   - Distribution: space-around

8. **Bottom Safe Area**
   - Minimum 16pt padding above home indicator

**Interaction Behaviors:**

- Swipe down: Minimizes to mini-player (dismiss animation)
- Tap album art: Opens full-resolution image viewer
- Long press track title: Copy to clipboard (toast notification)
- Drag progress slider: Real-time position update (playback pauses during drag)
- Double-tap play button: Reserved for future feature

---

## 9. Accessibility & Localization

### 9.1 Accessibility (WCAG 2.1 AA Standard)

**VoiceOver Support**
- All interactive elements have descriptive labels
- Custom labels for dynamic content (e.g., "Play button, currently paused")
- Proper heading hierarchy (H1, H2, H3)
- Meaningful alt text for album artwork
- Button tooltips for duration/timing info

**Motor Accessibility**
- Minimum touch target: 44x44pt (iOS standard)
- Sufficient spacing between interactive elements (min 8pt)
- Alternative to swipe gestures (buttons/menus)
- Drag-to-reorder with fallback buttons

**Visual Accessibility**
- Text contrast ratio: min 4.5:1 (normal text), 3:1 (large text)
- Adjustable font sizes (small, regular, large, extra-large)
- High contrast mode support
- No reliance on color alone (use icons + color)

### 9.2 Localization

**Supported Languages:** English (primary), Spanish, French, German, Portuguese, Chinese (Simplified & Traditional), Japanese, Korean, Russian (expandable)

**Approach:**
- Use Intl/localization packages
- String externalization in `.arb` files (Application Resource Bundle)
- Date/time formatting per locale
- Number formatting (thousands separator, decimal places)
- Currency formatting (if monetization added)

**RTL Support:**
- Test on Arabic/Hebrew (right-to-left layouts)
- FlipCard widget for image flipping if needed
- TextDirection: locale-based

---

## 10. Performance & Optimization

### 10.1 Target Metrics

- **App Launch Time:** < 2 seconds (cold start)
- **Screen Transition:** < 300ms (frame rate: 60fps)
- **Playback Start:** < 1 second from tap
- **Search Results:** < 500ms response time
- **Memory Usage:** < 150MB at peak
- **Battery Impact:** < 5% per hour streaming

### 10.2 Optimization Strategies

**Image Optimization**
- Compress artwork to WebP format (50% smaller than JPEG)
- Progressive loading: thumbnail first, then full resolution
- Caching with LRU eviction (max 10MB)
- Lazy load images in lists (only visible items)

**Network Optimization**
- API request batching (multiple endpoints in single request)
- Delta sync for playlists (only changed items)
- HTTP/2 multiplexing
- Request timeout: 10 seconds

**Memory Management**
- Dispose controllers in StatefulWidget.dispose()
- Stream/Future cleanup in Riverpod
- Image cache clearing periodically
- Unused widget garbage collection

**UI Rendering**
- `const` constructors for immutable widgets
- Avoid `MediaQuery.of()` in frequently rebuilt widgets (use context extension)
- Repaint boundary for complex animations
- SingleChildScrollView only when needed

---

## 11. Security & Privacy

### 11.1 Data Security

**In Transit**
- TLS 1.2+ for all API calls
- Certificate pinning for backend API
- No sensitive data in query parameters

**At Rest**
- LocalizedDB (Hive) encrypted with device keychain
- Secure storage for auth tokens (Keystore/Keychain)
- No plaintext passwords or API keys in code

**Authentication**
- OAuth 2.0 with PKCE flow (if user login required)
- Token refresh mechanism (15-min expiry)
- Session invalidation on logout
- Biometric authentication support (Face ID/Touch ID)

### 11.2 Privacy

**User Data**
- Minimal data collection (no behavior tracking unless opt-in)
- Privacy policy prominently displayed
- User control over data sharing preferences
- Offline-first where possible (minimal backend sync)

**Third-party Integrations**
- Lyrics: Musixmatch, LRCLIB (privacy-friendly)
- Analytics: Optional with clear opt-in
- Crash reporting: Sentry (anonymized)

---

## 12. QA & Testing Strategy

### 12.1 Test Coverage

| Test Type | Coverage Target | Priority |
|-----------|-----------------|----------|
| Unit Tests | 80% business logic | High |
| Widget Tests | 60% UI components | Medium |
| Integration Tests | 50% critical flows | High |
| E2E Tests | 30% user journeys | Medium |

**Critical User Flows to Test:**
1. Play song from home → playback controls work
2. Search query → results display correctly
3. Create playlist → add songs → sync
4. Download track → play offline
5. Queue song → next track plays
6. Shuffle → no duplicates in queue
7. Sleep timer → audio stops at duration

### 12.2 Device Testing

- **Primary:** iPhone 15 (latest), iPhone SE (oldest)
- **Secondary:** iPad Pro (if landscape support added)
- **iOS Versions:** iOS 13.0 (minimum), iOS 18+ (latest)

### 12.3 Beta Testing

- Internal QA team (2 weeks)
- Beta testers via TestFlight (1-2 weeks)
- Feedback collection and prioritization
- Hotfix iterations

---

## 13. Analytics & Monitoring

### 13.1 Key Metrics

| Metric | Target | Purpose |
|--------|--------|---------|
| Daily Active Users (DAU) | Track growth | User engagement |
| Session Duration | Avg 20+ min | Feature stickiness |
| Crash Rate | < 0.1% | App stability |
| API Success Rate | > 99% | Backend reliability |
| Search Conversion | > 40% | Feature usability |
| Offline Usage | > 10% | Offline value |

### 13.2 Event Tracking

```
Events:
- app_launched (source: cold/warm/background)
- screen_view (screen_name, duration)
- play_started (track_id, source)
- search_query (query, result_count)
- playlist_created (song_count)
- download_completed (track_id, duration)
- error_occurred (error_type, error_message)
```

### 13.3 Monitoring & Alerts

- Sentry for crash reporting (real-time alerts)
- Firebase Performance Monitoring (custom traces for key flows)
- App Store Connect metrics (reviews, crashes, performance)
- Custom backend logging for API errors

---

## 14. Future Enhancements

### Phase 2 (Post-Launch, Q2 2026)

- **Podcast Integration:** Browse and subscribe to podcasts
- **Social Features:** Share playlists, follow friends, see friend activity
- **Collaborative Playlists:** Multiple users edit shared playlist
- **AI Recommendations:** Enhanced personalization via ML
- **Lyrics Translation:** Real-time translation of lyrics
- **Video Playback:** Play music videos directly in app
- **Spatial Audio:** Support for Dolby Atmos spatial audio

### Phase 3 (Q3 2026+)

- **Desktop App:** macOS/Windows companion app
- **CarPlay Integration:** Full CarPlay dashboard
- **Watch OS App:** Music control from Apple Watch
- **Podcast Analytics:** Listening stats, favorite episodes
- **User Subscriptions:** Premium tier (ad-free, higher bitrate)
- **Social Listening Party:** Synchronized playback with friends

---

## 15. Appendix: Key Dependencies

```yaml
dependencies:
  flutter: 
    sdk: flutter
  
  # State Management
  riverpod: ^2.4.0
  riverpod_generator: ^2.3.0
  
  # Networking
  dio: ^5.3.0
  http: ^1.1.0
  
  # Local Storage
  hive: ^2.2.0
  hive_flutter: ^1.1.0
  
  # Audio Playback
  just_audio: ^0.9.36
  just_audio_background: ^0.6.0
  audio_service: ^0.18.12
  
  # Navigation
  go_router: ^11.1.0
  
  # UI
  cupertino_icons: ^1.0.0
  flutter_staggered_grid_view: ^0.7.0
  cached_network_image: ^3.3.0
  
  # Image Processing
  image: ^4.1.0
  
  # Logging
  logger: ^1.4.0
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.0.0
  
  # Code Generation
  build_runner: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.3.0
  mockito: ^5.4.0
  integration_test:
    sdk: flutter
```

---

## 16. Sign-Off & Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Manager | [Name] | 2026-01-29 | |
| Lead Developer | [Name] | 2026-01-29 | |
| UI/UX Designer | [Name] | 2026-01-29 | |
| Project Manager | [Name] | 2026-01-29 | |

---

**Document Status:** Final  
**Last Updated:** January 29, 2026  
**Review Schedule:** Every 2 weeks during development

This PRD serves as the authoritative specification for SimpMusic Flutter iOS application development. Any deviations must be documented and approved by product management before implementation.
