import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'PlayerScreen.dart';
import 'QuizUtilities.dart';

class QuizzesScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final String quizzesUrl;

  const QuizzesScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.quizzesUrl,
  });

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  List<dynamic> quizzes = [];
  String notice = 'Loading quizzes...';

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    final qRemote = await QuizUtilities.downloadJson(widget.quizzesUrl);
    if (!mounted) return;
    setState(() {
      quizzes = qRemote is List ? qRemote : [];
      notice = quizzes.isEmpty ? 'Failed to load quizzes.' : '';
    });
  }

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
    final quizCards =
    QuizUtilities.quizWidgets(quizzes, (id, title, url) => _startQuiz(context, id, title, url));

    return Scaffold(
      appBar: AppBar(title: Text('Quizzes • ${widget.subjectName}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: notice.isNotEmpty
            ? Center(child: Text(notice))
            : ListView(children: quizCards),
      ),
    );
  }
}
