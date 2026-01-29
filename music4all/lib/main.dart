import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'navigation/app_router.dart';
import 'features/search/domain/track_model.dart';
import 'core/services/storage_service.dart';
import 'core/providers.dart';

void main() async {
  // Ensure binding is initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Safe initialization block
  final storageService = await _safeInit();

  runApp(
    ProviderScope(
      overrides: [
        if (storageService != null)
          storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MusicApp(),
    ),
  );
}

Future<StorageService?> _safeInit() async {
  StorageService? storageService;

  try {
    // 1. Load .env (Optional - fail gracefully)
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("✅ .env loaded");
    } catch (e) {
      debugPrint("⚠️ Failed to load .env (continuing): $e");
    }

    // 2. Initialize HIve
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(TrackModelAdapter());
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
  } catch (e, stack) {
    debugPrint("🔥 CRITICAL INIT ERROR: $e\n$stack");
  }

  return storageService;
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
