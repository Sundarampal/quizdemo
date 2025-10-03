class QuizQuestion {
  final String id;
  final String text;
  final bool answer;

  QuizQuestion({required this.id, required this.text, required this.answer});

  // Build from JSON Map; accept boolean or string values for answer.
  factory QuizQuestion.fromJson(Map<String, dynamic> j) {
    final raw = j['answer'];
    bool ans;
    if (raw is bool)
      ans = raw;
    else if (raw is String)
      ans = raw.toLowerCase() == 'true';
    else
      ans = false;
    return QuizQuestion(
      id: j['id'] ?? '',
      text: j['text'] ?? j['question'] ?? '',
      answer: ans,
    );
  }
}
