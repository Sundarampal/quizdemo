import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'QuizUtilities.dart';
import 'SubjectsScreen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});
  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  List<dynamic> news = [];
  List<dynamic> subjects = [];
  String notice = 'Loading news...';

  @override
  void initState() {
    super.initState();
    _loadNewsThenSubjects();
  }

  Future<void> _loadNewsThenSubjects() async {
    // Step 1: News
    final nRemote = await QuizUtilities.downloadJson(
      'https://sundarampal.github.io/myjsonfiles/newspaper.json',
    );

    if (!mounted) return;
    setState(() {
      news = nRemote is List ? nRemote : [];
      notice = news.isEmpty ? 'Failed to load news.' : 'Loading subjects...';
    });

    // Step 2: Subjects (only after news finishes)
    final sRemote = await QuizUtilities.downloadJson(
      'https://sundarampal.github.io/myjsonfiles/subject1_2.json',
    );

    if (!mounted) return;
    setState(() {
      subjects = sRemote is List ? sRemote : [];
      if (subjects.isEmpty) {
        notice = 'Failed to load subjects.';
      } else {
        notice = ''; // ready
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsWidgets = QuizUtilities.newsWidgets(news, context);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Demo')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'Welcome to Quiz App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (notice.isNotEmpty) Text(notice),
            Expanded(
              child: ListView(
                children: [
                  ...newsWidgets,
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: subjects.isEmpty
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectsScreen(subjects: subjects),
                        ),
                      );
                    },
                    child: const Text('View Subjects'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
