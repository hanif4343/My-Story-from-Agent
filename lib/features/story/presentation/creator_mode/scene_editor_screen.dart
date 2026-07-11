// lib/features/story/presentation/creator_mode/scene_editor_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/constants/app_enums.dart';
import '../../data/models/scene_model.dart';
import '../../data/repositories/hive_scene_repository.dart';

/// Screen for creating or editing a [SceneModel].
class SceneEditorScreen extends StatefulWidget {
  final SceneModel? existingScene;

  const SceneEditorScreen({super.key, this.existingScene});

  @override
  State<SceneEditorScreen> createState() => _SceneEditorScreenState();
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

  final List<String> _photoPaths = [];
  final List<String> _voiceNotePaths = [];
  String? _musicPath;

  final Record _record = Record();
  bool _isRecording = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingIndex;

  late final HiveSceneRepository _repository;

  @override
  void initState() {
    super.initState();

    // Initialize repository with the already opened Hive box.
    _repository = HiveSceneRepository(Hive.box<SceneModel>('scenes'));

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

    _photoPaths.addAll(scene?.photoPaths ?? []);
    _voiceNotePaths.addAll(scene?.voiceNotePaths ?? []);
    _musicPath = scene?.musicPath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _storyTextController.dispose();
    _yearController.dispose();
    _durationController.dispose();
    _audioPlayer.dispose();
    _record.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photoPaths.add(picked.path);
      });
    }
  }

  void _removePhotoAt(int index) {
    setState(() {
      _photoPaths.removeAt(index);
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _record.start(path: filePath);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _record.stop();
    if (path != null) {
      setState(() {
        _voiceNotePaths.add(path);
        _isRecording = false;
      });
    }
  }

  Future<void> _playVoiceNote(int index) async {
    final path = _voiceNotePaths[index];
    if (_currentlyPlayingIndex == index) {
      await _audioPlayer.stop();
      setState(() => _currentlyPlayingIndex = null);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(path));
      setState(() => _currentlyPlayingIndex = index);
    }
  }

  Future<void> _deleteVoiceNote(int index) async {
    final path = _voiceNotePaths[index];
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    setState(() {
      if (_currentlyPlayingIndex == index) _currentlyPlayingIndex = null;
      _voiceNotePaths.removeAt(index);
    });
  }

  Future<void> _pickMusic() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _musicPath = result.files.first.path;
      });
    }
  }

  void _clearMusic() {
    setState(() {
      _musicPath = null;
    });
  }

  Future<void> _saveScene() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final id = widget.existingScene?.id ?? const Uuid().v4();
    final scene = SceneModel(
      id: id,
      year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      chapter: _selectedChapter?.toString() ?? ChapterId.chapter1.toString(),
      date: DateTime.now().toIso8601String(),
      title: _titleController.text,
      subtitle: _subtitleController.text,
      storyText: _storyTextController.text,
      photoPaths: List<String>.from(_photoPaths),
      videoPaths: [], // video handling omitted for brevity
      voiceNotePaths: List<String>.from(_voiceNotePaths),
      musicPath: _musicPath,
      theme: _selectedTheme?.toString() ?? AppTheme.darkRomantic.toString(),
      animationType:
          _selectedAnimation?.toString() ?? AnimationType.heartRain.toString(),
      transitionType:
          _selectedTransition?.toString() ?? TransitionType.fade.toString(),
      durationSeconds:
          int.tryParse(_durationController.text) ?? 0,
      isFavorite: widget.existingScene?.isFavorite ?? false,
      tags: [], // tags omitted for brevity
    );

    // Repository method may be synchronous; call without await.
    _repository.addScene(scene);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingScene == null ? 'Create Scene' : 'Edit Scene'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveScene,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              // Subtitle
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(labelText: 'Subtitle'),
              ),
              // Story Text
              TextFormField(
                controller: _storyTextController,
                decoration: const InputDecoration(labelText: 'Story Text'),
                maxLines: 5,
              ),
              // Year
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
              ),
              // Duration
              TextFormField(
                controller: _durationController,
                decoration:
                    const InputDecoration(labelText: 'Duration (seconds)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              // Chapter Dropdown
              DropdownButtonFormField<ChapterId>(
                value: _selectedChapter,
                decoration: const InputDecoration(labelText: 'Chapter'),
                items: ChapterId.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedChapter = v),
              ),
              // Theme Dropdown
              DropdownButtonFormField<AppTheme>(
                value: _selectedTheme,
                decoration: const InputDecoration(labelText: 'Theme'),
                items: AppTheme.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTheme = v),
              ),
              // Animation Dropdown
              DropdownButtonFormField<AnimationType>(
                value: _selectedAnimation,
                decoration: const InputDecoration(labelText: 'Animation'),
                items: AnimationType.values
                    .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAnimation = v),
              ),
              // Transition Dropdown
              DropdownButtonFormField<TransitionType>(
                value: _selectedTransition,
                decoration: const InputDecoration(labelText: 'Transition'),
                items: TransitionType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTransition = v),
              ),
              const SizedBox(height: 20),
              // Photos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Photos', style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _photoPaths.length,
                itemBuilder: (c, i) => ListTile(
                  leading: Image.file(
                    File(_photoPaths[i]),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(_photoPaths[i].split('/').last),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removePhotoAt(i),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Voice notes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Voice Notes', style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    onPressed: _toggleRecording,
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _voiceNotePaths.length,
                itemBuilder: (c, i) => ListTile(
                  leading: IconButton(
                    icon: Icon(_currentlyPlayingIndex == i
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: () => _playVoiceNote(i),
                  ),
                  title: Text(_voiceNotePaths[i].split('/').last),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteVoiceNote(i),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Music picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Music', style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.music_note),
                    onPressed: _pickMusic,
                  ),
                ],
              ),
              if (_musicPath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Chip(
                    label: Text(_musicPath!.split('/').last),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: _clearMusic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
