class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String topic;
  final String? difficulty;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.topic,
    this.difficulty,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
      topic: json['topic'] ?? '',
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
    'topic': topic,
    'difficulty': difficulty,
  };
}