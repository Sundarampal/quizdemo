import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'QuizUtilities.dart';
import 'QuizzesScreen.dart';

class SubjectsScreen extends StatelessWidget {
  final List<dynamic> subjects;

  const SubjectsScreen({
    super.key,
    required this.subjects,
  });

  void _openQuizzesFor(
      BuildContext context, String id, String name, String quizzesUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizzesScreen(
          subjectId: id,
          subjectName: name,
          quizzesUrl: quizzesUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectButtons = QuizUtilities.subjectWidgets(
      subjects,
          (id, name, quizzesUrl) => _openQuizzesFor(context, id, name, quizzesUrl),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(children: subjectButtons),
      ),
    );
  }
}
