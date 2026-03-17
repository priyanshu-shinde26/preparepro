import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  DocumentReference get _userDoc => _db.collection('users').doc(_uid);

  // ── Quiz Results ──────────────────────────────────────────
  Future<void> saveQuizResult({
    required String subject,
    required String subtopic,
    required int score,
    required int total,
    required List<Map<String, dynamic>> answers,
  }) async {
    final batch = _db.batch();

    // Save individual result
    final resultRef = _userDoc.collection('quiz_results').doc();
    batch.set(resultRef, {
      'subject': subject,
      'subtopic': subtopic,
      'score': score,
      'total': total,
      'percentage': (score / total * 100).round(),
      'answers': answers,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update user stats
    batch.update(_userDoc, {
      'totalQuizzesTaken': FieldValue.increment(1),
      'lastActive': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── Aptitude Results ──────────────────────────────────────
  Future<void> saveAptitudeResult({
    required bool isCorrect,
    required String topic,
  }) async {
    await _userDoc.collection('aptitude_results').add({
      'topic': topic,
      'isCorrect': isCorrect,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _userDoc.update({
      'totalAptitudeSolved': FieldValue.increment(1),
    });
  }

  // ── Bookmarks ─────────────────────────────────────────────
  Future<void> addBookmark(Map<String, dynamic> question) async {
    await _userDoc.collection('bookmarks').add({
      ...question,
      'bookmarkedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(String bookmarkId) async {
    await _userDoc.collection('bookmarks').doc(bookmarkId).delete();
  }

  Stream<QuerySnapshot> getBookmarks() {
    return _userDoc
        .collection('bookmarks')
        .orderBy('bookmarkedAt', descending: true)
        .snapshots();
  }

  // ── Progress Data ─────────────────────────────────────────
  Future<Map<String, dynamic>> getUserStats() async {
    final doc = await _userDoc.get();
    return doc.data() as Map<String, dynamic>? ?? {};
  }

  Stream<QuerySnapshot> getQuizResults({int limit = 20}) {
    return _userDoc
        .collection('quiz_results')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<Map<String, int>> getSubjectScores() async {
    final results = await _userDoc.collection('quiz_results').get();
    final Map<String, List<int>> subjectMap = {};

    for (final doc in results.docs) {
      final data = doc.data();
      final subject = data['subject'] as String;
      final pct = data['percentage'] as int;
      subjectMap.putIfAbsent(subject, () => []).add(pct);
    }

    return subjectMap.map((k, v) => MapEntry(
      k,
      (v.reduce((a, b) => a + b) / v.length).round(),
    ));
  }

  Future<Map<String, int>> getAptitudeStats() async {
    final results = await _userDoc.collection('aptitude_results').get();
    int correct = 0;
    int total = results.docs.length;

    for (final doc in results.docs) {
      if (doc.data()['isCorrect'] == true) correct++;
    }
    return {'correct': correct, 'total': total, 'incorrect': total - correct};
  }

  // ── Daily Challenge ───────────────────────────────────────
  Future<void> markDailyChallengeComplete() async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    await _userDoc.collection('daily_challenges').doc(dateKey).set({
      'completed': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isDailyChallengeComplete() async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final doc = await _userDoc.collection('daily_challenges').doc(dateKey).get();
    return doc.exists && (doc.data()?['completed'] ?? false);
  }

  // ── Leaderboard ───────────────────────────────────────────
  Stream<QuerySnapshot> getLeaderboard() {
    return _db
        .collection('users')
        .orderBy('totalQuizzesTaken', descending: true)
        .limit(20)
        .snapshots();
  }
}