// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'features/story/data/models/scene_model.dart';
import 'features/story/data/repositories/hive_scene_repository.dart';
import 'features/story/presentation/mode_selection_screen.dart';
import 'features/story/presentation/story_mode/story_mode_screen.dart';
import 'features/story/presentation/creator_mode/password_gate_screen.dart';
import 'features/story/presentation/creator_mode/password_setup_screen.dart';
import 'features/story/presentation/creator_mode/creator_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SceneModelAdapter());
  await Hive.openBox<SceneModel>('scenes');
  // পাসওয়ার্ড hash সহ অন্যান্য app সেটিংস রাখার জন্য।
  await Hive.openBox('settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<HiveSceneRepository>(
      create: (_) => HiveSceneRepository(Hive.box<SceneModel>('scenes')),
      child: MaterialApp(
        title: 'Our Story',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const ModeSelectionScreen(),
        routes: {
          '/story-mode': (_) => const StoryModeScreen(),
          '/creator-gate': (_) => const PasswordGateScreen(),
          '/creator-setup': (_) => const PasswordSetupScreen(),
          '/creator-dashboard': (_) => const CreatorDashboardScreen(),
        },
      ),
    );
  }
}
