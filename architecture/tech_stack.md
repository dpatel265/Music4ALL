# Tech Stack & Dependencies

## Core Framework
- **Flutter:** Stable Channel (Latest)
- **Dart:** 3.x+

## Key Libraries (B.L.A.S.T. Approved)
### 1. State Management
- **flutter_riverpod:** ^2.0.0
- *Reason:* Compile-time safety, strict provider scoping, easy testability.

### 2. Navigation
- **go_router:** ^13.0.0
- *Reason:* Declarative routing, deep linking support, easy redirection logic.

### 3. API & Networking
- **dio:** ^5.0.0
- *Reason:* Robust HTTP client with interceptors for logging and error handling.
- **youtube_explode_dart:** ^2.0.0
- *Reason:* **CRITICAL.** Used for extracting audio stream URLs for background playback.

### 4. Audio Playback
- **just_audio:** ^0.9.0
- *Reason:* Feature-rich player, plays URL streams effectively.
- **audio_service:** ^0.18.0
- *Reason:* Manages background execution, lock screen controls, and notification shade.

### 5. Persistence
- **hive:** ^2.2.0
- **hive_flutter:** ^1.1.0
- *Reason:* High-performance NoSQL database for history and favorites.

### 6. UI/Utilities
- **cached_network_image:** ^3.0.0
- **flutter_animate:** ^4.0.0 (For "Wow" factor)
