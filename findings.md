# Findings

## Research, Discoveries, and Constraints

### Background Playback Solution
- **Constraint:** Official `youtube_player_flutter` automatically pauses on background.
- **Solution (The "Way Around"):** **Hybrid Architecture**.
    - We will use the **YouTube Data API** for Search and Metadata (Legitimate, reliable, keeps quotas in check).
    - We will use **`youtube_explode_dart`** to extract the *audio stream URL* only when the user hits play.
    - We will feed this URL to **`just_audio`**, which is fully integrated with **`audio_service`**.
- **Result:** This grants native OS background control (lock screen play/pause, next/prev) and continues playing when screen is off.

### Python Tooling
- **Observation:** `urllib` on macOS often fails with SSL certificate errors.
- **Fix:** Use `ssl.create_default_context()` with `check_hostname=False` and `verify_mode=ssl.CERT_NONE` for internal/dev scripts.

## Technical Decisions
- **Search:** YouTube Data API v3.
- **Playback:** `youtube_explode_dart` -> `just_audio`.
- **State:** Riverpod.
