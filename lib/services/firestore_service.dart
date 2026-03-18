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

    // Update user stats with aggregate optimizations
    batch.set(_userDoc, {
      'totalQuizzesTaken': FieldValue.increment(1),
      'lastActive': FieldValue.serverTimestamp(),
      'subjectStats': {
        subject: {
          'totalScore': FieldValue.increment(score),
          'totalMax': FieldValue.increment(total),
          'quizzesTaken': FieldValue.increment(1),
        }
      }
    }, SetOptions(merge: true));

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

    await _userDoc.set({
      'totalAptitudeSolved': FieldValue.increment(1),
      'totalAptitudeCorrect': FieldValue.increment(isCorrect ? 1 : 0),
    }, SetOptions(merge: true));
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

  Future<Map<String, dynamic>> getAllUserStats() async {
    DocumentSnapshot doc;
    try {
      // Try fetching from server and cache, with a short timeout to prevent long hangs
      doc = await _userDoc.get(const GetOptions(source: Source.serverAndCache)).timeout(const Duration(seconds: 5));
    } catch (_) {
      // If offline or timed out, strictly use the local cache which contains the recent quizzes
      try {
        doc = await _userDoc.get(const GetOptions(source: Source.cache));
      } catch (e) {
        return {};
      }
    }

    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Compute subject scores
    final subs = data['subjectStats'] as Map<String, dynamic>? ?? {};
    final Map<String, int> percentages = {};
    for (var entry in subs.entries) {
      final stat = entry.value as Map<String, dynamic>;
      final max = (stat['totalMax'] ?? 0) as num;
      if (max > 0) {
        final score = (stat['totalScore'] ?? 0) as num;
        percentages[entry.key] = (score / max * 100).round();
      }
    }

    // Compute aptitude stats
    final total = (data['totalAptitudeSolved'] ?? 0) as int;
    final correct = (data['totalAptitudeCorrect'] ?? 0) as int;
    final aptitudeStats = {'correct': correct, 'total': total, 'incorrect': total > correct ? total - correct : 0};

    return {
      'userStats': data,
      'subjectScores': percentages,
      'aptitudeStats': aptitudeStats,
    };
  }

  Stream<QuerySnapshot> getQuizResults({int limit = 20}) {
    return _userDoc
        .collection('quiz_results')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<Map<String, int>> getSubjectScores() async {
    final doc = await _userDoc.get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final subs = data['subjectStats'] as Map<String, dynamic>? ?? {};

    final Map<String, int> percentages = {};
    for (var entry in subs.entries) {
      final stat = entry.value as Map<String, dynamic>;
      final max = (stat['totalMax'] ?? 0) as num;
      if (max > 0) {
        final score = (stat['totalScore'] ?? 0) as num;
        percentages[entry.key] = (score / max * 100).round();
      }
    }
    return percentages;
  }

  Future<Map<String, int>> getAptitudeStats() async {
    final doc = await _userDoc.get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    final total = (data['totalAptitudeSolved'] ?? 0) as int;
    final correct = (data['totalAptitudeCorrect'] ?? 0) as int;
    
    return {'correct': correct, 'total': total, 'incorrect': total > correct ? total - correct : 0};
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