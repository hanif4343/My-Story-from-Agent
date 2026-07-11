// lib/features/story/presentation/creator_mode/creator_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/hive_scene_repository.dart';
import '../../../data/models/scene_model.dart';

/// 화면: Creator Mode 대시보드
///
/// - HiveSceneRepository 로부터 모든 씬을 가져와 리스트 형태로 표시
/// - 각 아이템: title, year, chapter, 즐겨찾기 토글, 삭제, 편집 버튼
/// - 하단에 새로운 씬을 위한 FloatingActionButton 제공 (플레이스홀더)
class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  late final HiveSceneRepository _repository;
  List<SceneModel> _scenes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Provider 로부터 Repository 를 받아온다.
    // Provider 가 설정되지 않은 경우를 대비해 fallback 로 null 체크는 하지 않는다.
    _repository = Provider.of<HiveSceneRepository>(context, listen: false);
    _loadScenes();
  }

  Future<void> _loadScenes() async {
    final scenes = await _repository.getAllScenes();
    setState(() {
      _scenes = scenes;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(String id) async {
    await _repository.toggleFavorite(id);
    await _loadScenes();
  }

  Future<void> _deleteScene(String id) async {
    await _repository.deleteScene(id);
    await _loadScenes();
  }

  void _editScene(String id) {
    // TODO: 실제 편집 화면으로 이동
    debugPrint('Edit scene tapped: $id');
  }

  void _addNewScene() {
    // TODO: 실제 새 씬 생성 화면으로 이동
    debugPrint('Add new scene FAB tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scenes.isEmpty
              ? const Center(child: Text('No scenes available.'))
              : ListView.builder(
                  itemCount: _scenes.length,
                  itemBuilder: (context, index) {
                    final scene = _scenes[index];
                    return ListTile(
                      title: Text(scene.title),
                      subtitle: Text('${scene.year} • ${scene.chapter}'),
                      leading: IconButton(
                        icon: Icon(
                          scene.isFavorite ? Icons.star : Icons.star_border,
                          color: scene.isFavorite ? Colors.amber : null,
                        ),
                        onPressed: () => _toggleFavorite(scene.id),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editScene(scene.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteScene(scene.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewScene,
        child: const Icon(Icons.add),
        tooltip: 'Add New Scene',
      ),
    );
  }
}
