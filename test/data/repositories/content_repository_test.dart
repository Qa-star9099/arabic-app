import 'package:flutter_test/flutter_test.dart';
import 'package:arabcha/data/repositories/content_repository.dart';
import 'package:arabcha/data/models/lesson_models.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentRepository Tests', () {
    late ContentRepository repository;

    setUp(() {
      repository = ContentRepository();
    });

    test('getTopic loads and parses T-01 Aeroport correctly', () async {
      // Act
      final topic = await repository.getTopic('T-01');

      // Assert
      expect(topic.id, 'T-01');
      expect(topic.title, 'Aeroport');
      expect(topic.phase, 'arrival');
      expect(topic.words.length, 1);
      
      final word = topic.words.first;
      expect(word.id, 'w-safar');
      expect(word.uzbekCognate, 'safar');
      expect(word.arabic, 'سَفَر');
      expect(word.root.letters, ['س', 'ف', 'ر']);
      expect(word.family.length, 4);
      expect(word.listenOptions.length, 3);
      expect(word.sentence.correctOrder, ['أنا', 'مُسَافِر']);
    });
  });
}
