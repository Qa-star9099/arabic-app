/// Question types supported by the placement test.
enum QuestionType {
  multipleChoice,
  matchPairs,
  fillInBlank,
  sentenceScramble,
  audioTest,
  visualId,
  errorId,
}

/// Represents a single question in the Arabic placement test.
class TestQuestion {
  const TestQuestion({
    required this.id,
    required this.type,
    this.difficulty,
    required this.questionText,
    this.options = const [],
    this.correctAnswerIndex,
    this.correctAnswerString,
    this.matchingPairs,
    this.scrambledWords,
    this.imageUrl,
    this.audioUrl,
    this.errorWordIndex,
    required this.xpReward,
  });

  /// Unique identifier for the question.
  final String id;

  /// The kind of question (multiple choice, match pairs, etc.).
  final QuestionType type;

  /// Difficulty level: 'A1', 'A2', 'B1'
  final String? difficulty;

  /// The prompt shown to the user.
  final String questionText;

  /// Used for multiple choice, fill in blank, visual id, error id options.
  final List<String> options;

  /// Zero-based index into [options] that is the correct answer.
  final int? correctAnswerIndex;

  /// For text-based matching (Audio Test).
  final String? correctAnswerString;

  /// For match pairs: key is Arabic, value is Uzbek.
  final Map<String, String>? matchingPairs;

  /// For sentence scramble.
  final List<String>? scrambledWords;

  /// For visual identification (mock network image url or asset).
  final String? imageUrl;

  /// For audio test.
  final String? audioUrl;

  /// For error identification: index of the incorrect word in [options].
  final int? errorWordIndex;

  /// XP awarded when the user answers correctly.
  final int xpReward;
}
