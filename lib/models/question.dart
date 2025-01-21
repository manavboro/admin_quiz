class Question {
  final int id;

  final String question;

  final List<String> options;

  final String answer;

  bool? isFavorite; // Add this property

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    this.isFavorite = false, // Default to not favorite
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }

  // Convert a Question to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'answer': answer,
    };
  }
}
