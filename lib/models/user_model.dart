class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final int totalQuizzesTaken;
  final int totalAptitudeSolved;
  final int streak;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.totalQuizzesTaken = 0,
    this.totalAptitudeSolved = 0,
    this.streak = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      totalQuizzesTaken: json['totalQuizzesTaken'] ?? 0,
      totalAptitudeSolved: json['totalAptitudeSolved'] ?? 0,
      streak: json['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'totalQuizzesTaken': totalQuizzesTaken,
    'totalAptitudeSolved': totalAptitudeSolved,
    'streak': streak,
  };
}