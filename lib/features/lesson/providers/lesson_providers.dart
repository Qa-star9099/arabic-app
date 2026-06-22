import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabcha/data/models/lesson_models.dart';
import 'package:arabcha/data/repositories/content_repository.dart';

// Provide the repository
final contentRepoProvider = Provider((ref) => ContentRepository());

// Fetch the specific topic by ID
final topicProvider = FutureProvider.family<LessonTopic, String>((ref, id) {
  return ref.read(contentRepoProvider).getTopic(id);
});
