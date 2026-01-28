# Project Constitution (gemini.md)

**Identity:** System Pilot
**Protocol:** B.L.A.S.T.

## 0. Project Vision (North Star)
Build a cross-platform Flutter music-focused app (iOS + Android) that delivers a YouTube Music–like experience for personal use: search → play → background audio, with minimal UI and low data usage.

## 1. Data Schemas
**Data-First Rule:** All tools and code must adhere to these shapes.

### External API (YouTube Data API v3)
- **Endpoint:** `search` (list)
- **Params:** `part=snippet`, `type=video`, `videoCategoryId=10` (Music), `q={query}`
- **Raw Response Shape (relevant fields):**
  ```json
  {
    "items": [
      {
        "id": { "videoId": "string" },
        "snippet": {
          "title": "string",
          "channelTitle": "string", // Artist
          "thumbnails": { "high": { "url": "string" } }
        }
      }
    ]
  }
  ```

### Internal Models (Flutter/Dart)
- **TrackModel:**
  ```dart
  class TrackModel {
    final String id;
    final String title;
    final String artist;
    final String thumbnailUrl;
    final String? audioUrl; // Populated by Extractor
  }
  ```

### Storage Schema (Hive)
- **Box:** `favorites`
- **Box:** `history`
- **Schema:** Key: `videoId` (String), Value: `TrackModel` (Object)

## 2. Behavioral Rules
### UX Rules
- **Audio-First:** Interface prioritizes playback controls over video.
- **Minimalism:** No Shorts, no comments, no social feed.
- **Search-Driven:** Primary interaction is Search -> Play.

### Playback Rules
- **Background Audio:** **MANDATORY.** Audio must continue when screen is off.
- **Strategy (Hybrid):** 
  1.  **Search:** Use Official YouTube Data API (Reliable).
  2.  **Playback:** Use stream extraction (e.g., `youtube_explode_dart`) to fetch audio URL. 
  3.  **Player:** `just_audio` + `audio_service` (Native background handling).
- **Quality:** Default to low/medium bitrate to save data.

### "Do Not" Rules
- No music downloads.
- No ad removal (unless via official API means/compliance).
- No scraping private endpoints (except for stream extraction where necessary for background audio).
- No backend/cloud sync.

## 3. Architectural Invariants
- **Stack:** Flutter (Android/iOS).
- **State Management:** Riverpod.
- **Persistence:** Hive.
- **Networking:** `dio` (for API), `youtube_explode_dart` (for Streams).
- **Logic:** Strict YouTube API quota handling (cache metadata where possible).
- **Self-Annealing:** Analyze -> Patch -> Test -> Update Architecture.

## 4. Operational Notes
- **Flutter Location:** `tools/flutter_sdk/bin/flutter` (Local Install).
- **Project Root:** `music4all` (Inside workspace).

## Maintenance Log
- **[2026-01-28]**: Updated to Hybrid Architecture. Installed Flutter Locally (Arm64). Initialized `music4all`.
