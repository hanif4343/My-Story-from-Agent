import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class SceneModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int year;
  @HiveField(2)
  final String chapter;
  @HiveField(3)
  final String date;
  @HiveField(4)
  final String title;
  @HiveField(5)
  final String subtitle;
  @HiveField(6)
  final String storyText;
  @HiveField(7)
  final List<String> photoPaths;
  @HiveField(8)
  final List<String> videoPaths;
  @HiveField(9)
  final List<String> voiceNotePaths;
  @HiveField(10)
  final String? musicPath;
  @HiveField(11)
  final String theme;
  @HiveField(12)
  final String animationType;
  @HiveField(13)
  final String transitionType;
  @HiveField(14)
  final int durationSeconds;
  @HiveField(15)
  final bool isFavorite;
  @HiveField(16)
  final List<String> tags;

  SceneModel({
    required this.id,
    required this.year,
    required this.chapter,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.storyText,
    required this.photoPaths,
    required this.videoPaths,
    required this.voiceNotePaths,
    this.musicPath,
    required this.theme,
    required this.animationType,
    required this.transitionType,
    required this.durationSeconds,
    required this.isFavorite,
    required this.tags,
  });
}

class SceneModelAdapter extends TypeAdapter<SceneModel> {
  @override
  final int typeId = 0;

  @override
  SceneModel read(BinaryReader reader) {
    final id = reader.readString();
    final year = reader.readInt();
    final chapter = reader.readString();
    final date = reader.readString();
    final title = reader.readString();
    final subtitle = reader.readString();
    final storyText = reader.readString();
    final photoPaths = List<String>.from(reader.readStringList());
    final videoPaths = List<String>.from(reader.readStringList());
    final voiceNotePaths = List<String>.from(reader.readStringList());
    final hasMusic = reader.readBool();
    final musicPath = hasMusic ? reader.readString() : null;
    final theme = reader.readString();
    final animationType = reader.readString();
    final transitionType = reader.readString();
    final durationSeconds = reader.readInt();
    final isFavorite = reader.readBool();
    final tags = List<String>.from(reader.readStringList());

    return SceneModel(
      id: id,
      year: year,
      chapter: chapter,
      date: date,
      title: title,
      subtitle: subtitle,
      storyText: storyText,
      photoPaths: photoPaths,
      videoPaths: videoPaths,
      voiceNotePaths: voiceNotePaths,
      musicPath: musicPath,
      theme: theme,
      animationType: animationType,
      transitionType: transitionType,
      durationSeconds: durationSeconds,
      isFavorite: isFavorite,
      tags: tags,
    );
  }

  @override
  void write(BinaryWriter writer, SceneModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.year);
    writer.writeString(obj.chapter);
    writer.writeString(obj.date);
    writer.writeString(obj.title);
    writer.writeString(obj.subtitle);
    writer.writeString(obj.storyText);
    writer.writeStringList(obj.photoPaths);
    writer.writeStringList(obj.videoPaths);
    writer.writeStringList(obj.voiceNotePaths);
    writer.writeBool(obj.musicPath != null);
    if (obj.musicPath != null) {
      writer.writeString(obj.musicPath!);
    }
    writer.writeString(obj.theme);
    writer.writeString(obj.animationType);
    writer.writeString(obj.transitionType);
    writer.writeInt(obj.durationSeconds);
    writer.writeBool(obj.isFavorite);
    writer.writeStringList(obj.tags);
  }
}
