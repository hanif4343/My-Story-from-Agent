// lib/features/story/presentation/creator_mode/scene_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/scene_model.dart';
import '../../data/repositories/hive_scene_repository.dart';
import '../../../../core/constants/app_enums.dart';

/// Screen for creating or editing a [SceneModel].
class SceneEditorScreen extends StatefulWidget {
  final SceneModel? existingScene;

  const SceneEditorScreen({Key? key, this.existingScene}) : super(key: key);

  @override
  _SceneEditorScreenState createState() => _SceneEditorScreenState();
}

class _SceneEditorScreenState extends State<SceneEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _storyTextController;
  late final TextEditingController _yearController;
  late final TextEditingController _durationController;

  ChapterId? _selectedChapter;
  AppTheme? _selectedTheme;
  AnimationType? _selectedAnimation;
  TransitionType? _selectedTransition;

  @override
  void initState() {
    super.initState();

    final scene = widget.existingScene;
    _titleController = TextEditingController(text: scene?.title ?? '');
    _subtitleController = TextEditingController(text: scene?.subtitle ?? '');
    _storyTextController = TextEditingController(text: scene?.storyText ?? '');
    _yearController = TextEditingController(
        text: scene != null ? scene.year.toString() : '');
    _durationController = TextEditingController(
        text: scene != null ? scene.durationSeconds.toString() : '');

    _selectedChapter = scene != null
        ? ChapterId.values.firstWhere(
            (c) => c.toString() == scene.chapter,
            orElse: () => ChapterId.chapter1,
          )
        : ChapterId.chapter1;
    _selectedTheme = scene != null
        ? AppTheme.values.firstWhere(
            (t) => t.toString() == scene.theme,
            orElse: () => AppTheme.darkRomantic,
          )
        : AppTheme.darkRomantic;
    _selectedAnimation = scene != null
        ? AnimationType.values.firstWhere(
            (a) => a.toString() == scene.animationType,
            orElse: () => AnimationType.heartRain,
          )
        : AnimationType.heartRain;
    _selectedTransition = scene != null
        ? TransitionType.values.firstWhere(
            (t) => t.toString() == scene.transitionType,
            orElse: () => TransitionType.fade,
          )
        : TransitionType.fade;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _storyTextController.dispose();
    _yearController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveScene() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = Provider.of<HiveSceneRepository>(context, listen: false);
    final now = DateTime.now().toIso8601String();

    final scene = widget.existingScene != null
        ? widget.existingScene!
        : SceneModel(
            id: const Uuid().v4(),
            year: int.parse(_yearController.text),
            chapter: _selectedChapter!.toString(),
            date: now,
            title: _titleController.text,
            subtitle: _subtitleController.text,
            storyText: _storyTextController.text,
            photoPaths: [],
            videoPaths: [],
            voiceNotePaths: [],
            musicPath: null,
            theme: _selectedTheme!.toString(),
            animationType: _selectedAnimation!.toString(),
            transitionType: _selectedTransition!.toString(),
            durationSeconds: int.parse(_durationController.text),
            isFavorite: false,
            tags: [],
          );

    if (widget.existingScene != null) {
      final updated = SceneModel(
        id: scene.id,
        year: int.parse(_yearController.text),
        chapter: _selectedChapter!.toString(),
        date: now,
        title: _titleController.text,
        subtitle: _subtitleController.text,
        storyText: _storyTextController.text,
        photoPaths: List<String>.from(scene.photoPaths),
        videoPaths: List<String>.from(scene.videoPaths),
        voiceNotePaths: List<String>.from(scene.voiceNotePaths),
        musicPath: scene.musicPath,
        theme: _selectedTheme!.toString(),
        animationType: _selectedAnimation!.toString(),
        transitionType: _selectedTransition!.toString(),
        durationSeconds: int.parse(_durationController.text),
        isFavorite: scene.isFavorite,
        tags: List<String>.from(scene.tags),
      );
      await repo.updateScene(updated);
    } else {
      await repo.addScene(scene);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingScene != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Scene' : 'New Scene'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Title required' : null,
              ),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(labelText: 'Subtitle'),
              ),
              TextFormField(
                controller: _storyTextController,
                decoration: const InputDecoration(labelText: 'Story Text'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Year required' : null,
              ),
              DropdownButtonFormField<ChapterId>(
                value: _selectedChapter,
                decoration: const InputDecoration(labelText: 'Chapter'),
                items: ChapterId.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.title),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedChapter = v),
              ),
              DropdownButtonFormField<AppTheme>(
                value: _selectedTheme,
                decoration: const InputDecoration(labelText: 'Theme'),
                items: AppTheme.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTheme = v),
              ),
              DropdownButtonFormField<AnimationType>(
                value: _selectedAnimation,
                decoration:
                    const InputDecoration(labelText: 'Animation Type'),
                items: AnimationType.values
                    .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAnimation = v),
              ),
              DropdownButtonFormField<TransitionType>(
                value: _selectedTransition,
                decoration:
                    const InputDecoration(labelText: 'Transition Type'),
                items: TransitionType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTransition = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveScene,
                child: Text(isEdit ? 'Update Scene' : 'Create Scene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
