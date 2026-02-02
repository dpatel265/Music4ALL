import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'navigation/app_router.dart';
import 'features/search/domain/track_model.dart';
import 'features/playlists/domain/user_playlist_model.dart';
import 'core/models/track_metadata.dart';
import 'core/models/playback_context.dart';
import 'core/services/storage_service.dart';
import 'core/services/audio_handler_service.dart';
import 'core/providers.dart';
import 'features/library/data/local_library_repository.dart';
import 'features/library/domain/local_track_model.dart';

void main() async {
  print('🚀 MAIN STARTED');
  // Ensure binding is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ WidgetsBinding initialized');

  // Safe initialization block
  print('⏳ Starting initialization...');
  final initResult = await _safeInit();
  print('✅ Initialization complete. Running app...');

  runApp(
    ProviderScope(
      overrides: [
        if (initResult.storageService != null)
          storageServiceProvider.overrideWithValue(initResult.storageService!),
        if (initResult.audioHandler != null)
          audioHandlerProvider.overrideWithValue(initResult.audioHandler!),
      ],
      child: const MusicApp(),
    ),
  );
  print('🚀 runApp called');
}

class _InitResult {
  final StorageService? storageService;
  final AudioHandlerService? audioHandler;
  _InitResult({this.storageService, this.audioHandler});
}

Future<_InitResult> _safeInit() async {
  StorageService? storageService;
  AudioHandlerService? audioHandler;

  try {
    // 1. Load .env (Optional - fail gracefully)
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("✅ .env loaded");
    } catch (e) {
      debugPrint("⚠️ .env not found: $e");
    }

    // 2. Initialize Hive
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(TrackModelAdapter());
      Hive.registerAdapter(TrackMetadataAdapter());
      Hive.registerAdapter(PlaybackContextAdapter());
      Hive.registerAdapter(UserPlaylistAdapter());
      Hive.registerAdapter(LocalTrackAdapter());
      debugPrint("✅ Hive initialized");
    } catch (e) {
      debugPrint("❌ Hive Init Failed: $e");
    }

    // 3. Initialize Storage
    try {
      storageService = StorageService();
      await storageService.init();
      debugPrint("✅ Storage Service initialized");
    } catch (e) {
      debugPrint("❌ Storage Init Failed: $e");
    }

    // 4. Initialize Local Library
    try {
      final localRepo = LocalLibraryRepository();
      await localRepo.init();
      debugPrint("✅ Local Library initialized");
    } catch (e) {
      debugPrint("❌ Local Library Init Failed: $e");
    }

    // 5. Initialize Audio Handler via AudioService.init()
    try {
      audioHandler = await AudioService.init(
        builder: () => AudioHandlerService(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.music4all.audio',
          androidNotificationChannelName: 'Music4All Audio',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
      debugPrint("✅ Audio Handler initialized");
    } catch (e) {
      debugPrint("❌ Audio Handler Init Failed: $e");
    }
  } catch (e, stack) {
    debugPrint("🔥 CRITICAL INIT ERROR: $e\n$stack");
  }

  return _InitResult(
    storageService: storageService,
    audioHandler: audioHandler,
  );
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Music4All',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
