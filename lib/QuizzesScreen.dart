import 'package:flutter/material.dart';

import 'PlayerScreen.dart';
import 'QuizUtilities.dart';

class QuizzesScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;
  final List<dynamic> quizzesList;

  QuizzesScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
    required this.quizzesList,
  }) : super(key: key);

  void _startQuiz(
      BuildContext context,
      String id,
      String title,
      String questionsUrl,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          quizId: id,
          quizTitle: title,
          questionsUrl: questionsUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizCards = QuizUtilities.quizWidgets(
      quizzesList,
          (id, title, url) => _startQuiz(context, id, title, url),
    );
    return Scaffold(
      appBar: AppBar(title: Text('Quizzes • $subjectName')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(children: quizCards),
      ),
    );
  }
}
