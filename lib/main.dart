// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/story/data/models/scene_model.dart';
import 'features/story/presentation/story_mode/story_mode_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SceneModelAdapter());
  await Hive.openBox<SceneModel>('scenes');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story App',
      theme: ThemeData.dark(useMaterial3: true),
      home: const CounterScreen(),
      routes: {
        '/story-mode': (_) => const StoryModeScreen(),
        '/creator-gate': (_) => const PasswordGateScreen(),
        '/creator-dashboard': (_) => const CreatorDashboardScreen(),
      },
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  void _increment() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Text(
          '$_counter',
          key: const Key('counterText'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Placeholder screens for creator mode
class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mode Selection')),
      body: const Center(child: Text('Mode Selection Screen')),
    );
  }
}

class PasswordGateScreen extends StatelessWidget {
  const PasswordGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Gate')),
      body: const Center(child: Text('Password Gate Screen')),
    );
  }
}

class CreatorDashboardScreen extends StatelessWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creator Dashboard')),
      body: const Center(child: Text('Creator Dashboard Screen')),
    );
  }
}
