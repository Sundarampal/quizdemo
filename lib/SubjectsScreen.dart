import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'QuizUtilities.dart';
import 'QuizzesScreen.dart';

class SubjectsScreen extends StatelessWidget {
  final List<dynamic> subjects;
  final List<dynamic> quizzesMath;
  final List<dynamic> quizzesScience;

  SubjectsScreen({
    Key? key,
    required this.subjects,
    required this.quizzesMath,
    required this.quizzesScience,
  }) : super(key: key);

  void _openQuizzesFor(BuildContext context, String id, String name) {
    final List<dynamic> list = id == 'math' ? quizzesMath : quizzesScience;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuizzesScreen(subjectId: id, subjectName: name, quizzesList: list),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectButtons = QuizUtilities.subjectWidgets(
      subjects,
          (id, name) => _openQuizzesFor(context, id, name),
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
