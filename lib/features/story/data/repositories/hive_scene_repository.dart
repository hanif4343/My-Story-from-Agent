// lib/features/story/data/repositories/hive_scene_repository.dart
import 'package:hive/hive.dart';
import '../models/scene_model.dart';

/// Repository for managing [SceneModel] objects in a Hive box.
class HiveSceneRepository {
  final Box<SceneModel> _box;

  /// Creates a repository with the given Hive [box].
  HiveSceneRepository(this._box);

  /// Adds a new [scene] to the box.
  Future<void> addScene(SceneModel scene) async {
    await _box.put(scene.id, scene);
  }

  /// Updates an existing [scene] (or adds if it does not exist).
  Future<void> updateScene(SceneModel scene) async {
    await _box.put(scene.id, scene);
  }

  /// Deletes the scene with the given [id].
  Future<void> deleteScene(String id) async {
    await _box.delete(id);
  }

  /// Returns all scenes sorted by their [year] in ascending order.
  List<SceneModel> getAllScenes() {
    final scenes = _box.values.toList();
    scenes.sort((a, b) => a.year.compareTo(b.year));
    return scenes;
  }

  /// Retrieves a scene by its [id]. Returns `null` if not found.
  SceneModel? getSceneById(String id) {
    return _box.get(id);
  }

  /// Reorders scenes according to the provided list of [orderedIds].
  ///
  /// The method preserves only the scenes whose ids are present in
  /// [orderedIds] and re‑inserts them in that exact order.
  Future<void> reorderScenes(List<String> orderedIds) async {
    // Preserve the scenes that need to be reordered.
    final Map<String, SceneModel> preserved = {
      for (var id in orderedIds)
        if (_box.containsKey(id)) id: _box.get(id)!,
    };

    // Clear the box and re‑insert in the new order.
    await _box.clear();
    for (var id in orderedIds) {
      final scene = preserved[id];
      if (scene != null) {
        await _box.put(scene.id, scene);
      }
    }
  }

  /// Toggles the `isFavorite` flag of the scene with the given [id].
  Future<void> toggleFavorite(String id) async {
    final scene = _box.get(id);
    if (scene == null) return;

    final updated = SceneModel(
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

    await _box.put(updated.id, updated);
  }
}
