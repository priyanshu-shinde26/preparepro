class InterviewQuestionModel {
  final String question;
  final String answer;
  final String tip;
  final String category;

  const InterviewQuestionModel({
    required this.question,
    required this.answer,
    required this.tip,
    required this.category,
  });

  factory InterviewQuestionModel.fromJson(Map<String, dynamic> json) {
    return InterviewQuestionModel(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      tip: json['tip'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'tip': tip,
    'category': category,
  };
}