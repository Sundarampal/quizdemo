
import 'package:quizdemo/startscreen.dart';

import 'QuizzesScreen.dart';
import 'ResultScreen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'PlayerScreen.dart';
import 'SubjectsScreen.dart';

/// -----------------------------
/// FALLBACK JSON (used when network fails)
/// -----------------------------
/// These strings let the app work offline or be tested without a server.
const String fallbackNewsJson = '''
[
  {
    "id": "n1",
    "title": "Welcome to Quiz App",
    "summary": "Test your knowledge with True/False quizzes!",
    "details": "This app allows you to take various True/False quizzes to challenge your knowledge on different topics. Enjoy learning and have fun!"
  },
  {
    "id": "n2",
    "title": "New Math Quiz Added",
    "summary": "Check out the new Basic Math quiz.",
    "details": "A new quiz focusing on basic math concepts has been added. Test your arithmetic skills and improve your math knowledge!"
  }
]
''';

const String fallbackSubjectsJson = '''
[
  { "id": "math", "name": "Mathematics",
    "quizzes_url": "https://varanasi-software-junction.github.io/pictures-json/quizjson/quizzes_math.json" },
  { "id": "sci", "name": "Science",
    "quizzes_url": "https://varanasi-software-junction.github.io/pictures-json/quizjson/quizzes_science.json" }
]
''';

const String fallbackQuizzesMathJson = '''
[
  { "id": "m1", "title": "Basic Math True/False",
    "description": "Simple arithmetic questions",
    "questions_url": "https://varanasi-software-junction.github.io/pictures-json/quizjson/questions_math_m1.json" },
  { "id": "m2", "title": "Advanced Math True/False",
    "description": "Slightly tricky math questions",
    "questions_url": "https://varanasi-software-junction.github.io/pictures-json/quizjson/questions_math_m2.json" }
]
''';

const String fallbackQuizzesScienceJson = '''
[
  { "id": "s1", "title": "Basic Science Quiz",
    "description": "True/False science questions",
    "questions_url": "https://varanasi-software-junction.github.io/pictures-json/quizjson/questions_science_s1.json" }
]
''';

const String fallbackQuestionsMathM1 = '''
{
  "id": "m1",
  "title": "Basic Math True/False",
  "questions": [
    { "id": "q1", "text": "2 + 2 = 4", "answer": true },
    { "id": "q2", "text": "5 is an even number", "answer": false },
    { "id": "q3", "text": "10 is greater than 20", "answer": false },
    { "id": "q4", "text": "Square root of 9 is 3", "answer": true }
  ]
}
''';

const String fallbackQuestionsMathM2 = '''
{
  "id": "m2",
  "title": "Advanced Math True/False",
  "questions": [
    { "id": "q1", "text": "Zero is an even number", "answer": true },
    { "id": "q2", "text": "π (pi) is exactly equal to 3.14", "answer": false },
    { "id": "q3", "text": "Every prime number is odd", "answer": false },
    { "id": "q4", "text": "The derivative of x² is 2x", "answer": true }
  ]
}
''';

const String fallbackQuestionsScienceS1 = '''
{
  "id": "s1",
  "title": "Basic Science Quiz",
  "questions": [
    { "id": "q1", "text": "The Earth revolves around the Sun", "answer": true },
    { "id": "q2", "text": "Water boils at 50°C at sea level", "answer": false },
    { "id": "q3", "text": "Humans need oxygen to survive", "answer": true },
    { "id": "q4", "text": "Sound travels faster than light", "answer": false }
  ]
}
''';

/// -----------------------------
/// UTILITY CLASS - networking and widget builders
/// -----------------------------
/// Grouping helper functions reduces repetition in the code.

/// -----------------------------
/// DATA MODELS (typed classes to make code clean)
/// -----------------------------

// Represents a single true/false question

// Represents a quiz (a set of questions)

/// -----------------------------
/// APP ENTRYPOINT & ROOT WIDGET
/// -----------------------------
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp sets app-wide theme and initial route (StartScreen).
    return MaterialApp(
      title: 'Quiz Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// -----------------------------
/// START SCREEN
/// - Loads data (news, subjects, quizzes)
/// - Displays news and a button to go to subjects
/// -----------------------------


/// -----------------------------
/// SUBJECTS SCREEN
/// - Displays a button per subject and opens QuizzesScreen for the selected subject
/// -----------------------------

/// -----------------------------
/// QUIZZES SCREEN
/// - Shows list of quizzes for the chosen subject
/// - Starts the PlayerScreen when user presses Start
/// -----------------------------

/// -----------------------------
/// PLAYER SCREEN
/// - Loads questions (remote or fallback)
/// - True/False enabled immediately after questions load
/// - Questions advance only on "Next"
/// - Previous allowed (answers kept)
/// - Finish Now shows results (replace Player with Result)
/// -----------------------------

/// -----------------------------
/// RESULT SCREEN
/// - Shows score / total
/// - Back to Home: pops back to the first route (StartScreen)
/// - Retry Quiz: replaces ResultScreen with new PlayerScreen (fresh run)
/// - Buttons are full-width and responsive to avoid overflow
/// -----------------------------
