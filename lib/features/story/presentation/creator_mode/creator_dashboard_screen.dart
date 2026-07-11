// lib/features/story/presentation/creator_mode/creator_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/scene_model.dart';
import '../../data/repositories/hive_scene_repository.dart';
import 'scene_editor_screen.dart';

/// Dashboard showing list of scenes with ability to add or edit.
class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({Key? key}) : super(key: key);

  @override
  _CreatorDashboardScreenState createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  List<SceneModel> _scenes = [];

  @override
  void initState() {
    super.initState();
    _loadScenes();
  }

  /// Loads all scenes from the Hive repository.
  Future<void> _loadScenes() async {
    final repo = Provider.of<HiveSceneRepository>(context, listen: false);
    final scenes = await repo.getAllScenes();
    setState(() {
      _scenes = scenes;
    });
  }

  /// Navigates to [SceneEditorScreen] for creating a new scene or editing an existing one.
  /// After returning, refreshes the scene list.
  Future<void> _navigateToEditor({SceneModel? scene}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SceneEditorScreen(existingScene: scene),
      ),
    );
    // Refresh list when coming back from the editor.
    _loadScenes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Dashboard'),
      ),
      body: ListView.builder(
        itemCount: _scenes.length,
        itemBuilder: (context, index) {
          final scene = _scenes[index];
          return ListTile(
            title: Text(scene.title),
            subtitle: Text(scene.subtitle),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditor(scene: scene),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(),
        tooltip: 'নতুন Scene',
        child: const Icon(Icons.add),
      ),
    );
  }
}
