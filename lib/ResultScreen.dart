
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'PlayerScreen.dart';
// import 'package:flutter/cupertino.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final String quizId;
  final String quizTitle;
  final String questionsUrl;

  ResultScreen({
    Key? key,
    required this.score,
    required this.total,
    required this.quizId,
    required this.quizTitle,
    required this.questionsUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'Finished! Score: $score / $total',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),

            // Full-width "Back to Home" button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Pop routes until the first one (StartScreen)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Back to Home'),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Full-width "Retry Quiz" button: replace this ResultScreen with a fresh PlayerScreen
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(
                        quizId: quizId,
                        quizTitle: quizTitle,
                        questionsUrl: questionsUrl,
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Retry Quiz'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}