import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'QuestionSet.dart';
import 'QuizUtilities.dart';
import 'ResultScreen.dart';

class PlayerScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final String questionsUrl;

  const PlayerScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.questionsUrl,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  QuestionSet? currentQuestionSet;
  int qIndex = 0;
  int score = 0;
  Set<String> answered = {};
  String notice = 'Loading questions...';

  @override
  void initState() {
    super.initState();
    _loadQuestionsForQuiz(widget.questionsUrl, widget.quizId);
  }

  Future<void> _loadQuestionsForQuiz(String questionsUrl, String quizId) async {
    currentQuestionSet = null;
    qIndex = 0;
    score = 0;
    answered.clear();
    setState(() => notice = 'Loading questions...');

    final remote = questionsUrl.isNotEmpty
        ? await QuizUtilities.downloadJson(questionsUrl)
        : null;

    QuestionSet? parsedSet;

    if (remote != null) {
      if (remote is List) {
        final mapWrap = {
          'id': quizId,
          'title': widget.quizTitle,
          'questions': remote,
        };
        parsedSet = QuestionSet.fromJson(Map<String, dynamic>.from(mapWrap));
      } else if (remote is Map) {
        parsedSet = QuestionSet.fromJson(Map<String, dynamic>.from(remote));
      }
    }

    if (!mounted) return;

    if (parsedSet == null || parsedSet.questions.isEmpty) {
      setState(() {
        currentQuestionSet = null;
        notice = 'Failed to load questions.';
      });
      return;
    }

    setState(() {
      currentQuestionSet = parsedSet;
      notice = '';
    });
  }

  void _answerCurrent(bool selected) {
    final qs = currentQuestionSet;
    if (qs == null) return;

    final q = qs.questions[qIndex];
    if (answered.contains(q.id)) return;

    final correct = q.answer == selected;
    if (correct) score++;
    answered.add(q.id);
    setState(() {});
  }

  void _nextQuestion() {
    if (currentQuestionSet == null) return;
    if (qIndex < currentQuestionSet!.questions.length - 1) {
      setState(() => qIndex++);
    } else {
      _gotoResult();
    }
  }

  void _gotoResult() {
    final total = currentQuestionSet?.questions.length ?? 0;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          total: total,
          quizId: widget.quizId,
          quizTitle: widget.quizTitle,
          questionsUrl: widget.questionsUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qs = currentQuestionSet;

    if (qs == null) {
      if (notice.isNotEmpty) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.quizTitle)),
          body: Center(child: Text(notice)),
        );
      }
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final q = qs.questions[qIndex];
    final already = answered.contains(q.id);

    return Scaffold(
      appBar: AppBar(title: Text(widget.quizTitle)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              qs.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (notice.isNotEmpty) Text(notice),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${qIndex + 1} / ${qs.questions.length}'),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(q.text, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: already ? null : () => _answerCurrent(true),
              child: const Text('True'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: already ? null : () => _answerCurrent(false),
              child: const Text('False'),
            ),
            const SizedBox(height: 12),
            Text('Score: $score'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: qIndex > 0 ? () => setState(() => qIndex--) : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Previous'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Next'),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _gotoResult,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Finish Now'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
