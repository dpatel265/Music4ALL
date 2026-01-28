# Project Structure

## Folder Hierarchy (Feature-First)

```
lib/
├── main.dart                # Entry point, ProviderScope
├── core/                    # Global utilities
│   ├── constants/           # ApiKeys (via Env), AppColors
│   ├── services/            # AudioHandler, StorageService
│   ├── theme/               # AppTheme
│   └── utils/               # Formatters, Logger
├── features/
│   ├── search/              # Feature: Search
│   │   ├── data/            # Repositories, API providers
│   │   ├── domain/          # Models (TrackModel)
│   │   └── presentation/    # SearchScreen, Widgets
│   ├── player/              # Feature: Audio Player
│   │   ├── logic/           # PlayerNotifier (Riverpod)
│   │   └── presentation/    # MiniPlayer, FullPlayer
│   └── library/             # Feature: Favorites/History
│       └── presentation/    # LibraryScreen
└── navigation/              # AppRouter (GoRouter)
```

## Rules
1.  **Strict Layering:** Presentation never talks to Data directly. Use Controllers/Notifiers.
2.  **Models:** All data flowing between features must be strongly typed (no raw Maps).
3.  **Services:** Singletons (like AudioHandler) are accessed via Riverpod Providers.
