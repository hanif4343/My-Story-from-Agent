// lib/features/story/presentation/story_mode/story_mode_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../data/repositories/hive_scene_repository.dart';
import '../../data/models/scene_model.dart';

/// A read‑only screen that displays all saved scenes in a vertical
/// [PageView]. Each page shows the scene's year, title, subtitle and
/// story text using a dark romantic theme. If a scene contains photos,
/// they are displayed in a horizontal carousel above or below the
/// story text. If a scene contains videos, the first video is played
/// with a play/pause overlay button. Background music for each scene
/// is played in loop mode when the scene is visible. A mute/unmute
/// button is provided in the top‑right corner.
class StoryModeScreen extends StatefulWidget {
  const StoryModeScreen({super.key});

  @override
  State<StoryModeScreen> createState() => _StoryModeScreenState();
}

class _StoryModeScreenState extends State<StoryModeScreen> {
  late final AudioPlayer _audioPlayer;
  bool _isMuted = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(_isMuted ? 0 : 1);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Plays the background music for the scene at [index] if a music path
  /// is defined. Stops any previously playing music.
  Future<void> _playMusicForScene(List<SceneModel> scenes, int index) async {
    final scene = scenes[index];
    await _audioPlayer.stop();
    if (scene.musicPath != null && scene.musicPath!.isNotEmpty) {
      try {
        await _audioPlayer.setSource(DeviceFileSource(scene.musicPath!));
        await _audioPlayer.setVolume(_isMuted ? 0 : 1);
        await _audioPlayer.resume();
      } catch (_) {
        // ignore errors (e.g., file not found)
      }
    }
  }

  /// Handles page change events from the [PageView].
  void _onPageChanged(int index, List<SceneModel> scenes) {
    _currentPage = index;
    _playMusicForScene(scenes, index);
  }

  /// Toggles mute state and updates the audio player volume.
  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _audioPlayer.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveSceneRepository>(
      builder: (context, repository, _) {
        final List<SceneModel> scenes = repository.getAllScenes();

        // Play music for the first scene after the first frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentPage == 0) {
            _playMusicForScene(scenes, 0);
          }
        });

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: scenes.length,
                onPageChanged: (index) => _onPageChanged(index, scenes),
                itemBuilder: (context, index) {
                  final scene = scenes[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Year
                          Text(
                            '${scene.year}',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            scene.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Subtitle
                          Text(
                            scene.subtitle,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Story text
                          Text(
                            scene.storyText,
                            style: GoogleFonts.lora(
                              fontSize: 18,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),

                          // Video player (if any)
                          if (scene.videoPaths.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            SceneVideoPlayer(scene: scene),
                          ],

                          // Photo carousel (if any)
                          if (scene.photoPaths.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: scene.photoPaths.length,
                                itemBuilder: (context, idx) {
                                  final path = scene.photoPaths[idx];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Mute/Unmute button
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white70,
                    size: 32,
                  ),
                  onPressed: _toggleMute,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget that plays the first video of a scene with a play/pause overlay.
/// The controller is disposed when the widget is removed from the tree.
class SceneVideoPlayer extends StatefulWidget {
  final SceneModel scene;

  const SceneVideoPlayer({required this.scene, super.key});

  @override
  State<SceneVideoPlayer> createState() => _SceneVideoPlayerState();
}

class _SceneVideoPlayerState extends State<SceneVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final file = File(widget.scene.videoPaths.first);
    _controller = VideoPlayerController.file(file);
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
    _controller!.addListener(() {
      if (!mounted) return;
      setState(() {
        _isPlaying = _controller!.value.isPlaying;
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          if (!_isPlaying)
            const Icon(
              Icons.play_circle_fill,
              size: 64,
              color: Colors.white70,
            ),
        ],
      ),
    );
  }
}
