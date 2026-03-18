import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RTDBService {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://preparepro-app-default-rtdb.firebaseio.com/',
  );

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference get _userRef => _db.ref('users/$_uid');

  // ── Quiz Results ──────────────────────────────────────────
  Future<void> saveQuizResult({
    required String subject,
    required String subtopic,
    required int score,
    required int total,
    required List<Map<String, dynamic>> answers,
  }) async {
    final resultRef = _userRef.child('quiz_results').push();
    await resultRef.set({
      'subject': subject,
      'subtopic': subtopic,
      'score': score,
      'total': total,
      'percentage': total > 0 ? (score / total * 100).round() : 0,
      'answers': answers,
      'timestamp': ServerValue.timestamp,
    });

    final updates = <String, Object?>{
      'stats/totalQuizzesTaken': ServerValue.increment(1),
      'stats/lastActive': ServerValue.timestamp,
      'stats/subjectStats/$subject/totalScore': ServerValue.increment(score),
      'stats/subjectStats/$subject/totalMax': ServerValue.increment(total),
      'stats/subjectStats/$subject/quizzesTaken': ServerValue.increment(1),
    };

    await _userRef.update(updates);
  }

  // ── Aptitude Results ──────────────────────────────────────
  Future<void> saveAptitudeResult({
    required bool isCorrect,
    required String topic,
  }) async {
    final resultRef = _userRef.child('aptitude_results').push();
    await resultRef.set({
      'topic': topic,
      'isCorrect': isCorrect,
      'timestamp': ServerValue.timestamp,
    });

    final updates = <String, Object?>{
      'stats/totalAptitudeSolved': ServerValue.increment(1),
      'stats/totalAptitudeCorrect': ServerValue.increment(isCorrect ? 1 : 0),
    };

    await _userRef.update(updates);
  }

  // ── Interview Progress ──────────────────────────────────────
  Future<void> saveInterviewProgress(int masteredCount) async {
    if (masteredCount == 0) return;
    final updates = <String, Object?>{
      'stats/interviewQuestionsMastered': ServerValue.increment(masteredCount),
    };
    await _userRef.update(updates);
  }

  // ── Progress Data Fetcher ─────────────────────────────────────────
  Future<Map<String, dynamic>> getAllUserStats() async {
    try {
      final snapshot = await _userRef.child('stats').get();
      if (!snapshot.exists) return {};
      
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      // Compute subject scores
      final subsRaw = data['subjectStats'];
      final Map<String, int> percentages = {};
      if (subsRaw != null && subsRaw is Map) {
         subsRaw.forEach((key, value) {
            final stat = Map<String, dynamic>.from(value as Map);
            final max = (stat['totalMax'] ?? 0) as num;
            if (max > 0) {
              final score = (stat['totalScore'] ?? 0) as num;
              percentages[key.toString()] = (score / max * 100).round();
            }
         });
      }

      // Compute aptitude stats
      final total = (data['totalAptitudeSolved'] ?? 0) as int;
      final correct = (data['totalAptitudeCorrect'] ?? 0) as int;
      final aptitudeStats = {'correct': correct, 'total': total, 'incorrect': total > correct ? total - correct : 0};

      // Interview stats
      final interviewMastered = (data['interviewQuestionsMastered'] ?? 0) as int;

      return {
        'userStats': data,
        'subjectScores': percentages,
        'aptitudeStats': aptitudeStats,
        'interviewMastered': interviewMastered,
      };
    } catch (_) {
      return {};
    }
  }
}
