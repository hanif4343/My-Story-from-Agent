// lib/features/story/presentation/story_mode/story_mode_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../data/models/scene_model.dart';
import '../../../data/repositories/hive_scene_repository.dart';

/// Screen that displays all saved scenes in a vertical PageView.
/// The view is read‑only – only title, subtitle, story text and year are shown.
class StoryModeScreen extends StatelessWidget {
  const StoryModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Story Mode'),
      ),
      body: Consumer<HiveSceneRepository>(
        builder: (context, repository, _) {
          return FutureBuilder<List<SceneModel>>(
            future: repository.getAllScenes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load scenes',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                );
              }
              final scenes = snapshot.data ?? [];
              if (scenes.isEmpty) {
                return const Center(
                  child: Text(
                    'No scenes available',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: scenes.length,
                itemBuilder: (context, index) {
                  final scene = scenes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${scene.year}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            scene.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scene.subtitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),
                          const Divider(height: 32, color: Colors.white30),
                          Text(
                            scene.storyText,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
