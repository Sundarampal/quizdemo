
import 'ResultScreen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'PlayerScreen.dart';

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
class QuizUtilities {
  // Try to fetch JSON from `url`. Return decoded JSON (Map/List) or null on failure.
  static Future<dynamic> downloadJson(String url) async {
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) return json.decode(resp.body);
    } catch (_) {
      // ignore network errors here; caller will use fallback
    }
    return null;
  }

  // Build list of news cards (used on start screen).
  static List<Widget> newsWidgets(
      List<dynamic> newsJson,
      BuildContext context,
      ) {
    return newsJson.map<Widget>((n) {
      final title = n['title'] ?? '';
      final summary = n['summary'] ?? '';
      final details = n['details'] ?? '';
      return Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text(summary),
          trailing: TextButton(
            child: const Text('Details'),
            onPressed: () {
              // show details in a simple dialog
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(title),
                  content: Text(details),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }).toList();
  }

  // Build subject selection buttons
  static List<Widget> subjectWidgets(
      List<dynamic> subjectsJson,
      void Function(String id, String name) onTap,
      ) {
    return subjectsJson.map<Widget>((s) {
      final id = s['id'] ?? '';
      final name = s['name'] ?? s['title'] ?? '';
      return ElevatedButton(
        onPressed: () => onTap(id, name),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(name, style: const TextStyle(fontSize: 16)),
        ),
      );
    }).toList();
  }

  // Build quiz cards (used on quizzes screen)
  static List<Widget> quizWidgets(
      List<dynamic> quizzesJson,
      void Function(String id, String title, String questionsUrl) onStart,
      ) {
    return quizzesJson.map<Widget>((q) {
      final id = q['id'] ?? '';
      final title = q['title'] ?? '';
      final desc = q['description'] ?? '';
      final questionsUrl = q['questions_url'] ?? q['questionsUrl'] ?? '';
      return Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text(desc),
          trailing: ElevatedButton(
            onPressed: () => onStart(id, title, questionsUrl),
            child: const Text('Start'),
          ),
        ),
      );
    }).toList();
  }
}

/// -----------------------------
/// DATA MODELS (typed classes to make code clean)
/// -----------------------------

// Represents a single true/false question
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

// Represents a quiz (a set of questions)
class QuestionSet {
  final String id;
  final String title;
  final List<QuizQuestion> questions;

  QuestionSet({required this.id, required this.title, required this.questions});

  // Build QuestionSet from JSON Map
  factory QuestionSet.fromJson(Map<String, dynamic> j) {
    final qs = <QuizQuestion>[];
    if (j['questions'] is List) {
      for (final e in j['questions']) {
        qs.add(QuizQuestion.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return QuestionSet(
      id: j['id'] ?? j['quiz_id'] ?? 'quiz',
      title: j['title'] ?? '',
      questions: qs,
    );
  }
}

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

/// -----------------------------
/// SUBJECTS SCREEN
/// - Displays a button per subject and opens QuizzesScreen for the selected subject
/// -----------------------------
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

/// -----------------------------
/// QUIZZES SCREEN
/// - Shows list of quizzes for the chosen subject
/// - Starts the PlayerScreen when user presses Start
/// -----------------------------
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
