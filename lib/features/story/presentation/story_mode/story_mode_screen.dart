// lib/features/story/presentation/story_mode/story_mode_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/repositories/hive_scene_repository.dart';
import '../../data/models/scene_model.dart';

/// A read‑only screen that displays all saved scenes in a vertical
/// [PageView]. Each page shows the scene's year, title, subtitle and
/// story text using a dark romantic theme.
class StoryModeScreen extends StatelessWidget {
  const StoryModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveSceneRepository>(
      builder: (context, repository, _) {
        final List<SceneModel> scenes = repository.getAllScenes();

        return Scaffold(
          backgroundColor: Colors.black,
          body: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: scenes.length,
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
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
