import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson_models.dart';

/// Repository for loading lesson content from local JSON assets.
/// Since this app uses a serverless architecture (CLAUDE.md), all content
/// is shipped directly within the app bundle for offline access and speed.
class ContentRepository {
  /// Loads and parses a full lesson topic from a JSON asset.
  ///
  /// [topicId] e.g. 'T-01'
  Future<LessonTopic> getTopic(String topicId) async {
    try {
      final fileName = _getFilenameForTopic(topicId);
      final path = 'assets/content/topics/$fileName.json';

      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      return LessonTopic.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load topic $topicId: $e');
    }
  }

  /// Maps topic IDs to their corresponding JSON filenames in assets.
  String _getFilenameForTopic(String topicId) {
    // Currently we only have T-01 implemented
    switch (topicId) {
      case 'T-01':
        return 't01_aeroport';
      // Future topics will be added here
      // case 'T-02':
      //   return 't02_transport';
      default:
        // Fallback for testing
        return 't01_aeroport';
    }
  }
}
