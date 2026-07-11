// lib/features/story/data/repositories/hive_scene_repository.dart

import 'package:hive/hive.dart';
import '../models/scene_model.dart';

/// Repository for managing [SceneModel] objects stored in a Hive box.
class HiveSceneRepository {
  final Box<SceneModel> _box;

  /// Creates a repository that operates on the provided [box].
  HiveSceneRepository(this._box);

  /// Adds a new [scene] to the box.
  Future<void> addScene(SceneModel scene) async {
    await _box.put(scene.id, scene);
  }

  /// Updates an existing [scene] in the box.
  Future<void> updateScene(SceneModel scene) async {
    await _box.put(scene.id, scene);
  }

  /// Deletes the scene with the given [id] from the box.
  Future<void> deleteScene(String id) async {
    await _box.delete(id);
  }

  /// Retrieves all scenes sorted by [year] in ascending order.
  Future<List<SceneModel>> getAllScenes() async {
    final scenes = _box.values.toList();
    scenes.sort((a, b) => a.year.compareTo(b.year));
    return scenes;
  }

  /// Retrieves the scene with the specified [id].
  Future<SceneModel?> getSceneById(String id) async {
    return _box.get(id);
  }

  /// Reorders scenes in the box to match the order of [orderedIds].
  ///
  /// The length of [orderedIds] must match the number of items in the box.
  Future<void> reorderScenes(List<String> orderedIds) async {
    if (orderedIds.length != _box.length) return;
    for (var i = 0; i < orderedIds.length; i++) {
      final scene = _box.get(orderedIds[i]);
      if (scene != null) {
        await _box.putAt(i, scene);
      }
    }
  }

  /// Toggles the [isFavorite] flag of the scene with the given [id].
  Future<void> toggleFavorite(String id) async {
    final scene = _box.get(id);
    if (scene == null) return;
    final toggled = SceneModel(
      id: scene.id,
      year: scene.year,
      chapter: scene.chapter,
      date: scene.date,
      title: scene.title,
      subtitle: scene.subtitle,
      storyText: scene.storyText,
      photoPaths: List<String>.from(scene.photoPaths),
      videoPaths: List<String>.from(scene.videoPaths),
      voiceNotePaths: List<String>.from(scene.voiceNotePaths),
      musicPath: scene.musicPath,
      theme: scene.theme,
      animationType: scene.animationType,
      transitionType: scene.transitionType,
      durationSeconds: scene.durationSeconds,
      isFavorite: !scene.isFavorite,
      tags: List<String>.from(scene.tags),
    );
    await _box.put(id, toggled);
  }
}
