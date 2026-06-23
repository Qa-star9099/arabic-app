import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(FirebaseFirestore.instance);
});

class ProgressRepository {
  final FirebaseFirestore _firestore;

  ProgressRepository(this._firestore);

  /// Marks a word as seen in the user's progress.
  /// If it's the first time, it sets `firstSeenAt`.
  /// It always increments `timesReviewed` and updates `lastSeenAt`.
  Future<void> markWordSeen(String userId, String wordId) async {
    final docRef = _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('word_states')
        .doc(wordId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // First time seeing this word
          transaction.set(docRef, {
            'firstSeenAt': FieldValue.serverTimestamp(),
            'lastSeenAt': FieldValue.serverTimestamp(),
            'timesReviewed': 1,
          });
        } else {
          // Word already seen, update it
          transaction.update(docRef, {
            'lastSeenAt': FieldValue.serverTimestamp(),
            'timesReviewed': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to update word progress: $e');
    }
  }

  /// Marks a specific step (e.g. 1 to 8) as completed for the word.
  Future<void> markStepCompleted(
      String userId, String wordId, int stepNumber) async {
    final docRef = _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('word_states')
        .doc(wordId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          transaction.set(docRef, {
            'completedSteps': [stepNumber],
            'lastSeenAt': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.update(docRef, {
            'completedSteps': FieldValue.arrayUnion([stepNumber]),
            'lastSeenAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to mark step $stepNumber as completed: $e');
    }
  }
}
