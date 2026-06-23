import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/test_question.dart';
import '../models/mock_test_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the placement test at any given moment.
class PlacementTestState {
  const PlacementTestState({
    required this.questions,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.selectedAnswer,
    this.isAnswerSubmitted = false,
    this.isFinished = false,
  });

  final List<TestQuestion> questions;
  final int currentIndex;
  final int correctCount;
  final Object? selectedAnswer;
  final bool isAnswerSubmitted;
  final bool isFinished;

  // ── Derived getters ────────────────────────────────────────────────────────

  /// The question currently being displayed.
  TestQuestion get currentQuestion => questions[currentIndex];

  /// Progress as a value between 0.0 and 1.0.
  double get progress =>
      questions.isEmpty ? 0.0 : currentIndex / questions.length;

  /// Accuracy ratio (0.0 – 1.0) — used for level calculation on result screen.
  double get accuracy =>
      questions.isEmpty ? 0.0 : correctCount / questions.length;

  /// Evaluates if the current selectedAnswer is correct based on QuestionType.
  bool get isCorrect {
    if (selectedAnswer == null) return false;

    switch (currentQuestion.type) {
      case QuestionType.multipleChoice:
      case QuestionType.visualId:
      case QuestionType.audioTest:
      case QuestionType.fillInBlank:
      case QuestionType.errorId:
        return selectedAnswer == currentQuestion.correctAnswerIndex ||
            selectedAnswer == currentQuestion.errorWordIndex;
      case QuestionType.matchPairs:
        if (selectedAnswer is Map) {
          final map = selectedAnswer as Map;
          final correctMap = currentQuestion.matchingPairs!;
          if (map.length != correctMap.length) return false;
          for (final key in correctMap.keys) {
            if (map[key] != correctMap[key]) return false;
          }
          return true;
        }
        return false;
      case QuestionType.sentenceScramble:
        if (selectedAnswer is List) {
          final list = selectedAnswer as List;
          final correctList =
              currentQuestion.options; // Options store correct order
          if (list.length != correctList.length) return false;
          for (int i = 0; i < correctList.length; i++) {
            if (list[i] != correctList[i]) return false;
          }
          return true;
        }
        return false;
    }
  }

  // ── copyWith ───────────────────────────────────────────────────────────────
  PlacementTestState copyWith({
    List<TestQuestion>? questions,
    int? currentIndex,
    int? correctCount,
    Object? selectedAnswer = _keep,
    bool? isAnswerSubmitted,
    bool? isFinished,
  }) {
    return PlacementTestState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      selectedAnswer:
          selectedAnswer == _keep ? this.selectedAnswer : selectedAnswer,
      isAnswerSubmitted: isAnswerSubmitted ?? this.isAnswerSubmitted,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

// Private sentinel so copyWith can distinguish "not passed" from "null".
const _keep = Object();

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────

class PlacementTestController extends AutoDisposeNotifier<PlacementTestState> {
  @override
  PlacementTestState build() {
    ref.onDispose(() {
      _audioPlayer.dispose();
    });
    return PlacementTestState(questions: mockTestQuestions);
  }

  /// Records the option the user tapped/arranged.
  void selectAnswer(Object? answer) {
    if (state.isAnswerSubmitted) return;
    state = state.copyWith(selectedAnswer: answer);
  }

  final _audioPlayer = AudioPlayer();

  /// Validates the selected answer, increments [correctCount] if right,
  /// and marks the question as submitted so the UI can show feedback.
  void submitAnswer() async {
    if (state.selectedAnswer == null) return;
    if (state.isAnswerSubmitted) return;

    final isCorrect = state.isCorrect;

    try {
      if (isCorrect) {
        await _audioPlayer.setAsset('assets/audio/correct.wav');
      } else {
        await _audioPlayer.setAsset('assets/audio/wrong.wav');
      }
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Audio playback error: $e");
    }

    state = state.copyWith(
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
      isAnswerSubmitted: true,
    );
  }

  /// Advances to the next question (called after the feedback animation ends).
  void advance() {
    if (!state.isAnswerSubmitted) return;

    final nextIndex = state.currentIndex + 1;
    final finished = nextIndex >= state.questions.length;

    state = state.copyWith(
      currentIndex: finished ? state.currentIndex : nextIndex,
      selectedAnswer: null,
      isAnswerSubmitted: false,
      isFinished: finished,
    );
  }

  /// Resets the entire test back to the beginning.
  void reset() {
    state = PlacementTestState(questions: mockTestQuestions);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final placementTestControllerProvider =
    AutoDisposeNotifierProvider<PlacementTestController, PlacementTestState>(
  PlacementTestController.new,
);
