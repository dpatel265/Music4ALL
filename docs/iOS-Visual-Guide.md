# SimpMusic iOS Flutter App - Visual Architecture & Screen Flow Guide

## 1. App Navigation Structure

```
Root: Splash Screen (2-3 sec)
  ↓
Main Tab Navigation (Persistent)
├── TAB 1: HOME SCREEN
│   ├── Continue Listening Carousel
│   ├── Recommended For You
│   ├── New Releases
│   ├── Trending Now Playlist
│   └── Moods & Genres Grid
│
├── TAB 2: EXPLORE SCREEN
│   ├── Browse by Mood
│   ├── Browse by Genre
│   ├── Podcast Categories
│   ├── Charts (Top 50, Trending, New)
│   └── Featured Playlists
│
├── TAB 3: SEARCH SCREEN
│   ├── Search Bar (persistent)
│   ├── Recent Searches
│   └── Search Results (Songs, Artists, Playlists, Albums)
│
├── TAB 4: LIBRARY SCREEN
│   ├── Playlists Tab
│   │   ├── User-created Playlists
│   │   ├── Create Playlist Button
│   │   └── Playlist Detail → Songs List
│   ├── Favorites Tab
│   │   └── Liked Songs List
│   ├── Downloads Tab
│   │   └── Downloaded Tracks with Deletion
│   └── History Tab
│       └── Recently Played Tracks
│
└── TAB 5: PROFILE SCREEN
    ├── User Info Section
    ├── Playback Settings
    ├── Download Settings
    ├── Display Settings (Theme, Font Size)
    ├── Notification Settings
    └── About & Help

Modal Screens (Overlay on Tabs):
├── FULL PLAYER SCREEN
│   ├── Album Artwork (Draggable)
│   ├── Song Title & Artist
│   ├── Progress Bar with Seek
│   ├── Playback Controls (Previous, Play/Pause, Next)
│   ├── Loop & Shuffle Toggles
│   ├── Volume Control
│   └── Action Buttons (Like, Share, Add to Playlist, More)
│
├── LYRICS SCREEN
│   ├── Scrollable Lyrics
│   ├── Line-by-line Highlight Sync
│   ├── Font Size Adjustment
│   └── Translation (if available)
│
├── QUEUE SCREEN
│   ├── List of Upcoming Tracks
│   ├── Drag-to-Reorder Functionality
│   └── Clear Queue Button
│
├── PLAYLIST DETAIL
│   ├── Playlist Header (Artwork, Title, Song Count)
│   ├── Songs List with Swipe Actions
│   └── Shuffle Playlist Button
│
├── ARTIST DETAIL
│   ├── Artist Image & Bio
│   ├── Top Tracks
│   ├── Albums Grid
│   └── Related Artists
│
└── ALBUM DETAIL
    ├── Album Cover & Info
    ├── Track List with Play
    └── Album Details (Year, Artist, Genre)

Settings Modal:
├── Account Management
├── Playback Quality & Speed
├── Download Management
├── Theme & Display
├── Notifications
└── About & Privacy
```


---

> [!IMPORTANT]
> **Functional Constraints (Design Handoff)**
> This visual guide MUST be used in conjunction with the **[NRD Plan (Functional Spec)](file:///Users/deepprachi/.gemini/antigravity/brain/abb70615-7e07-4602-b136-3c6d90ab6cf6/NRD_Plan.md)**.
> While the UI/UX can be redesigned, the **Navigation Structure** (ShellRoute) and **State Management logic** (Riverpod) are architectural hard constraints.

## 2. Screen Layout Specifications

### HOME SCREEN (Tab 1)
```
┌─────────────────────────────────────┐
│ Status Bar                          │
├─────────────────────────────────────┤
│ Navigation: Home | Explore | ...    │
├─────────────────────────────────────┤
│ "Good Morning, [User]" (12pt)       │
├─────────────────────────────────────┤
│ Continue Listening                  │
│ ┌──────────────────────┐            │
│ │ Album Artwork        │            │
│ │ Song Title           │            │
│ │ Artist Name          │            │
│ └──────────────────────┘            │
├─────────────────────────────────────┤
│ Recommended For You                 │
│ ┌─────────┬─────────┬──────────┐   │
│ │ Playlist│ Playlist│ Playlist │   │
│ │ Tile 1  │ Tile 2  │ Tile 3   │   │
│ └─────────┴─────────┴──────────┘   │
├─────────────────────────────────────┤
│ New Releases (Horizontal Scroll)    │
├─────────────────────────────────────┤
│ Moods & Genres                      │
│ ┌─────┬─────┬─────┬─────┐          │
│ │ Pop │Rock │Jazz │Chill│          │
│ └─────┴─────┴─────┴─────┘          │
├─────────────────────────────────────┤
│ Mini Player Bar                     │
│ ┌──┐ Song Title         ▶ ⓘ         │
│ │  │ Artist Name        (Controls)  │
│ └──┘                                │
├─────────────────────────────────────┤
│ Bottom Tab: [●] Explore Search ...  │
└─────────────────────────────────────┘
```

### FULL PLAYER SCREEN (Persistent Overlay)
*Note: This is NOT a separate page. It is a persistent layer that slides up/down over the main content.*

```
┌─────────────────────────────────────┐
│ ⋲ "Now Playing" ⋯                   │
├─────────────────────────────────────┤
│                                     │
│          ┌───────────────────┐      │
│          │   Album Artwork   │      │
│          │   (280x280pt)     │      │
│          │   rounded shadow  │      │
│          └───────────────────┘      │
│                                     │
├─────────────────────────────────────┤
│       Artist Name (14pt gray)       │
│   Song Title (24pt bold)            │
│     Album Name (12pt gray)          │
├─────────────────────────────────────┤
│ 2:45                                │
│ ─────●────────────────────          │
│              5:30                   │
├─────────────────────────────────────┤
│        ⏮  ⏸  ⏭  🔁  🔀            │
│      (Previous, Play, Next, Loop,   │
│         Repeat, Shuffle buttons)    │
├─────────────────────────────────────┤
│ 🔊 ──────●────── 🔊                │
│   (Volume Slider)                   │
├─────────────────────────────────────┤
│    ❤️  🔗  ➕  ⋯                     │
│ (Like, Share, Add, More)            │
├─────────────────────────────────────┤
│                                     │
│  Safe Area (16pt minimum)           │
└─────────────────────────────────────┘
```

### SEARCH SCREEN (Tab 3)
```
┌─────────────────────────────────────┐
│ ┌────────────────────────────────┐  │
│ │ 🔍 Search songs, artists...    │  │
│ └────────────────────────────────┘  │
├─────────────────────────────────────┤
│ Recent Searches                     │
│ [Drake] [Taylor Swift] [Weeknd]     │
├─────────────────────────────────────┤
│ SONGS (Tap to see more)             │
│ ┌──┐ Song Title          🎵         │
│ │  │ Artist Name         Duration   │
│ ├──┤─────────────────────────────   │
│ │  │ Song Title 2         🎵        │
│ │  │ Artist Name          Duration  │
│ └──┘─────────────────────────────   │
├─────────────────────────────────────┤
│ ARTISTS                             │
│ ┌──┐ Artist Name                    │
│ │  │ X Followers                    │
│ ├──┤─────────────────────────────   │
│ │  │ Artist Name 2                  │
│ │  │ X Followers                    │
│ └──┘─────────────────────────────   │
├─────────────────────────────────────┤
│ PLAYLISTS                           │
│ ┌──────────────┐ Playlist Name      │
│ │ Playlist     │ X Songs by User    │
│ └──────────────┘                    │
├─────────────────────────────────────┤
│ Mini Player Bar                     │
├─────────────────────────────────────┤
│ Bottom Tab: Home [●] Explore...     │
└─────────────────────────────────────┘
```

### LIBRARY SCREEN (Tab 4)
```
┌─────────────────────────────────────┐
│ Library                             │
├─────────────────────────────────────┤
│ [Playlists] [Favorites] [DL] [Hist]│
├─────────────────────────────────────┤
│
│ PLAYLISTS TAB ACTIVE:               │
│ ┌────────────────────────────────┐  │
│ │ ⊕ Create Playlist              │  │
│ └────────────────────────────────┘  │
│
│ ┌──────────────┐ My Playlist 1       │
│ │ Playlist Art │ 24 songs            │
│ └──────────────┘ Created 2 days ago  │
│
│ ┌──────────────┐ My Playlist 2       │
│ │ Playlist Art │ 18 songs            │
│ └──────────────┘ Modified yesterday  │
│
├─────────────────────────────────────┤
│ Mini Player Bar                     │
├─────────────────────────────────────┤
│ Bottom Tab: Home Explore [●] ...    │
└─────────────────────────────────────┘
```

### QUEUE SCREEN (Modal)
```
┌─────────────────────────────────────┐
│ ⋲ "Now Playing Queue" ⋯             │
├─────────────────────────────────────┤
│                                     │
│ ▶ Song Title 1 (CURRENTLY PLAYING)  │
│   Artist Name                       │
│   ≡ ← Drag to reorder               │
│                                     │
│ 2. Song Title 2                     │
│    Artist Name                      │
│    ≡ ← Drag to reorder              │
│                                     │
│ 3. Song Title 3                     │
│    Artist Name                      │
│    ≡ ← Drag to reorder              │
│                                     │
│ 4. Song Title 4                     │
│    Artist Name                      │
│    ≡ ← Drag to reorder              │
│                                     │
├─────────────────────────────────────┤
│  🗑 Clear Queue                      │
├─────────────────────────────────────┤
│ Remaining: 15 songs | 1h 24min      │
│                                     │
│  Safe Area (16pt minimum)           │
└─────────────────────────────────────┘
```

---

## 3. Component Design Specifications

### Bottom Tab Navigation Bar
```
┌─────────────────────────────────────┐
│ Icon  Icon  [●]  Icon  Icon         │
│ Home  Expl  Srch  Lib  Prof         │
│       (Selected tab has color fill) │
└─────────────────────────────────────┘

Dimensions:
- Height: 50pt (49pt content + 16pt safe area)
- Tab width: Full width / 5 = responsive
- Icon size: 24x24pt
- Label size: 10pt (San Francisco)
- Spacing: 8pt between icon and label
- Background: systemBackground (adapts to dark/light)
```

### Song Tile / Row Component
```
┌──────────────────────────────────────┐
│ ┌──┐ Song Title           0:03:45    │
│ │  │ Artist Name          ⋯          │
│ └──┘────────────────────────────────│
│
Dimensions:
- Height: 56pt
- Padding: 12pt horizontal, 8pt vertical
- Thumbnail: 40x40pt, rounded corners (4pt)
- Text: Title (16pt), Artist (14pt)
- Trailing: Duration (14pt) or menu icon
```

### Album Card Component
```
┌──────────────────────┐
│                      │
│   Album Artwork      │ 140x140pt
│   (Image)            │
│                      │
├──────────────────────┤
│ Album Title          │ 14pt bold
│ Artist Name          │ 12pt gray
│ 2025                 │ 12pt gray
│                      │
└──────────────────────┘
```

### Progress Bar Component
```
Current Time: 2:45
──●──────────────────────  ← Draggable slider
Total Time: 5:30

Interactive area: 44pt height (for easy touch)
Color: systemBlue (primary accent)
Track background: systemGray3 (light gray)
Buffered portion: systemGray4 (darker gray)
```

---

## 4. Color Palette & Typography

### Color Scheme (Dark Mode Primary)

| Element | Light Mode | Dark Mode | Use Case |
|---------|-----------|-----------|----------|
| Primary Background | #FFFFFF | #000000 | Screen backgrounds |
| Secondary Background | #F5F5F5 | #1C1C1E | Card backgrounds |
| Primary Text | #000000 | #FFFFFF | Headings, body text |
| Secondary Text | #666666 | #A0A0A0 | Subtitles, dates |
| Accent Color | #FF6B00 | #FF9500 | Buttons, highlights (SimpMusic orange) |
| Divider | #E0E0E0 | #454545 | Separators |
| Success | #34C759 | #30B0C0 | Downloaded, available |
| Error | #FF3B30 | #FF453A | Errors, deletion |

### Typography Stack

| Name | Size | Weight | Usage |
|------|------|--------|-------|
| Heading 1 | 32pt | Bold (700) | Screen titles |
| Heading 2 | 24pt | Semibold (600) | Section headers |
| Heading 3 | 18pt | Semibold (600) | Subsection headers |
| Body | 16pt | Regular (400) | Main content |
| Label | 14pt | Regular (400) | Supporting text |
| Caption | 12pt | Regular (400) | Timestamps, helpers |
| Tiny | 10pt | Regular (400) | Tab labels |

Font Family: San Francisco (native iOS system font)

---

## 5. Interaction Patterns & Gestures

### Gesture Mapping

| Gesture | Component | Action | Result |
|---------|-----------|--------|--------|
| Tap | Play Button | Toggle playback | Play/Pause |
| Tap | Album Artwork (Player) | Expand | Open full player |
| Swipe Down | Full Player Screen | Dismiss/Minimize | Show mini-player |
| Swipe Up | Mini Player | Expand | Show full player |
| Long Press | Song Title | Copy | Toast: "Copied" |
| Drag | Progress Slider | Seek | Real-time position update |
| Drag | Queue Item | Reorder | Swap positions in queue |
| Swipe Left | Queue Item | Delete | Remove from queue |
| Double Tap | Album Artwork | Fullscreen | Image viewer |
| 3-Finger Tap | Anywhere | Accessibility menu | Zoom, voice control |

### Transition Animations

| Transition | Duration | Curve | Notes |
|-----------|----------|-------|-------|
| Mini → Full Player | 300ms | EaseInOut | Smooth slide up |
| Full → Mini Player | 300ms | EaseInOut | Smooth slide down |
| Tab Change | 200ms | EaseOut | Fade + slide |
| Bottom Sheet Expand | 350ms | EaseInOut | Standard iOS modal |
| Song Change | 150ms | EaseOut | Artwork fade transition |
| Progress Update | Real-time | Linear | Smooth slider movement |

---

## 6. State Indicators & Feedback

### Visual Feedback States

**Song Playback State:**
- ▶️ Paused (play icon)
- ⏸ Playing (pause icon, optional pulsing animation)
- ⚫ Loading (spinner or skeleton loader)
- ❌ Error (error icon + retry button)

**Shuffle/Repeat Modes:**
- 🔀 Shuffle OFF (gray icon)
- 🔀 Shuffle ON (colored icon)
- 🔁 Repeat OFF (gray icon)
- 🔁 Repeat ALL (colored icon)
- 🔁 Repeat ONE (colored icon + "1")

**Download Progress:**
- ⬇️ Not Downloaded
- ⏳ Downloading (circular progress indicator, % label)
- ✓ Downloaded (checkmark icon)
- ⚠️ Download Failed (error icon, retry button)

**Favorite/Like State:**
- ♡ Not Liked (hollow heart)
- ♥️ Liked (solid red heart)

---

## 7. Accessibility Features

### VoiceOver Labels (Examples)

```
Play Button: "Play button, currently paused"
Next Button: "Skip to next track"
Progress Slider: "Song progress slider, 2 minutes 45 seconds of 5 minutes 30 seconds"
Shuffle Toggle: "Shuffle toggle, currently off"
Album Artwork: "Album artwork for [Song Title] by [Artist Name]"
Favorite Button: "Add to favorites button, currently not favorited"
```

### Touch Target Sizes

- Minimum button size: 44x44pt (Apple HIG standard)
- Minimum spacing between buttons: 8pt
- Song rows: 56pt minimum height
- Slider tap target: 44pt height
- Spacing between controls: 12pt

### Motion & Animation

- Reduce Motion support: Disable parallax, fade animations
- Flashing rate: < 3 flashes per second (accessibility standard)
- Color contrast ratio: 4.5:1 minimum (WCAG AA)

---

## 8. Dark Mode Implementation

### Automatic Adaptation

All UI elements use **system colors** that automatically switch based on device appearance:

```
Color Mapping:
systemBackground     → Automatically switch light/dark
label (text)         → Automatically adjust contrast
secondaryLabel       → Automatically adjust opacity
separator            → Automatically adjust visibility
systemGray3/4        → Automatically adjust brightness
```

### Testing Checklist

- [ ] All text readable in both modes
- [ ] Images visible and not washed out
- [ ] Icons display correctly (SF Symbols handle this)
- [ ] Shadows visible in dark mode
- [ ] No pure black (#000000) backgrounds
- [ ] Custom colors tested in both modes

---

## 9. Performance Optimization Checklist

### Image Handling
- [ ] Compress artwork to WebP (50% size reduction)
- [ ] Lazy load images (only visible items)
- [ ] Progressive loading (thumbnail → full res)
- [ ] Cache size limit: 10MB max

### Memory Management
- [ ] Dispose controllers in `dispose()`
- [ ] Clean up Riverpod listeners
- [ ] Limit queue to 500 tracks max
- [ ] Clear unused image cache monthly

### Network
- [ ] API timeout: 10 seconds
- [ ] Batch requests where possible
- [ ] HTTP/2 enabled
- [ ] Request caching for search results

### UI Rendering
- [ ] Use `const` constructors
- [ ] Avoid rebuilding top-level widgets
- [ ] Repaint boundary for animations
- [ ] Frame rate: 60fps target

---

## 10. Testing Matrix

### Unit Tests
```
- Playback state transitions
- Queue management logic
- Shuffle/repeat modes
- Time formatting
- Offline detection
```

### Widget Tests
```
- Player controls respond to taps
- Progress slider updates UI
- Mini-player collapse animation
- Tab navigation switching
- Loading states display correctly
```

### Integration Tests
```
- Play song → playback controls work
- Search → results display
- Download track → play offline
- Create playlist → add songs
- Queue song → next track plays
```

---

This visual guide complements the main PRD and provides designers and developers with clear reference specifications for implementation.
