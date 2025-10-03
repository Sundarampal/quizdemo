import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'QuizUtilities.dart';
import 'SubjectsScreen.dart';
import 'main.dart' hide QuizUtilities;

class StartScreen extends StatefulWidget {
  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  List<dynamic> news = [];
  List<dynamic> subjects = [];
  List<dynamic> quizzesMath = [];
  List<dynamic> quizzesScience = [];
  String notice = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Fetch remote JSON; fall back to embedded strings if network fails.
  Future<void> _loadInitialData() async {
    final nRemote = await QuizUtilities.downloadJson(
      'https://varanasi-software-junction.github.io/pictures-json/quizjson/news.json',
    );
    final sRemote = await QuizUtilities.downloadJson(
      'https://varanasi-software-junction.github.io/pictures-json/quizjson/subjects.json',
    );
    final qmRemote = await QuizUtilities.downloadJson(
      'https://varanasi-software-junction.github.io/pictures-json/quizjson/quizzes_math.json',
    );
    final qsRemote = await QuizUtilities.downloadJson(
      'https://varanasi-software-junction.github.io/pictures-json/quizjson/quizzes_science.json',
    );

    setState(() {
      news = nRemote ?? json.decode(fallbackNewsJson);
      subjects = sRemote ?? json.decode(fallbackSubjectsJson);
      quizzesMath = qmRemote ?? json.decode(fallbackQuizzesMathJson);
      quizzesScience = qsRemote ?? json.decode(fallbackQuizzesScienceJson);
      notice = '';
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
                    onPressed: () {
                      // Navigate to Subjects screen, passing loaded lists
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectsScreen(
                            subjects: subjects,
                            quizzesMath: quizzesMath,
                            quizzesScience: quizzesScience,
                          ),
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