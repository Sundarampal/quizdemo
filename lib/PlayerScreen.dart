import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'QuestionSet.dart';
import 'QuizUtilities.dart';
import 'ResultScreen.dart';
import 'main.dart' hide QuizUtilities;

class PlayerScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final String questionsUrl;

  PlayerScreen({
    Key? key,
    required this.quizId,
    required this.quizTitle,
    required this.questionsUrl,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  QuestionSet? currentQuestionSet; // null while loading
  int qIndex = 0; // index of current question
  int score = 0; // correct answers count
  Set<String> answered = {}; // question ids answered (prevents re-answer)
  String notice = 'Loading questions...'; // loading / error message

  @override
  void initState() {
    super.initState();
    _loadQuestionsForQuiz(widget.questionsUrl, widget.quizId);
  }

  // Load questions from the network or fallback strings by quiz id.
  Future<void> _loadQuestionsForQuiz(String questionsUrl, String quizId) async {
    // reset state for a fresh play
    currentQuestionSet = null;
    qIndex = 0;
    score = 0;
    answered.clear();
    setState(() => notice = 'Loading questions...');

    final remote = questionsUrl.isNotEmpty
        ? await QuizUtilities.downloadJson(questionsUrl)
        : null;

    if (remote != null) {
      if (remote is List) {
        final mapWrap = {
          'id': quizId,
          'title': widget.quizTitle,
          'questions': remote,
        };
        currentQuestionSet = QuestionSet.fromJson(
          Map<String, dynamic>.from(mapWrap),
        );
      } else if (remote is Map) {
        currentQuestionSet = QuestionSet.fromJson(
          Map<String, dynamic>.from(remote),
        );
      }
    } else {
      final Map<String, String> map = {
        'm1': fallbackQuestionsMathM1,
        'm2': fallbackQuestionsMathM2,
        's1': fallbackQuestionsScienceS1,
      };
      final fallback = map[quizId];
      if (fallback != null) {
        final parsed = json.decode(fallback);
        currentQuestionSet = QuestionSet.fromJson(
          Map<String, dynamic>.from(parsed),
        );
      }
    }

    setState(
          () => notice = currentQuestionSet == null
          ? 'Failed to load questions.'
          : '',
    );
  }

  // User selects True or False for the current question.
  // If already answered, ignore further taps (single-attempt design).
  void _answerCurrent(bool selected) {
    final qs = currentQuestionSet;
    if (qs == null) return; // questions not loaded

    final q = qs.questions[qIndex];
    if (answered.contains(q.id)) return; // already answered

    final correct = q.answer == selected;
    if (correct) score++;
    answered.add(q.id);
    setState(() {}); // update UI to disable buttons and show new score
  }

  // Move to next question. If last question, go to result screen.
  void _nextQuestion() {
    if (currentQuestionSet == null) return;
    if (qIndex < currentQuestionSet!.questions.length - 1) {
      setState(() => qIndex++);
    } else {
      _gotoResult();
    }
  }

  // Replace PlayerScreen with ResultScreen and pass quiz info so ResultScreen can retry.
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

    // If questions are still loading or failed, show message or spinner.
    if (qs == null) {
      if (notice.isNotEmpty)
        return Scaffold(
          appBar: AppBar(title: Text(widget.quizTitle)),
          body: Center(child: Text(notice)),
        );
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
            // Title
            Text(
              qs.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (notice.isNotEmpty) Text(notice),

            // Question index
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${qIndex + 1} / ${qs.questions.length}'),
                const SizedBox.shrink(),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Question text
            Text(q.text, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),

            // True / False buttons:
            // Buttons disabled if the current question has been answered (prevents re-answering).
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

            // Score
            Text('Score: $score'),
            const SizedBox(height: 8),

            // Responsive Previous / Next row to avoid overflow on small screens:
            // Each button expands to share available width.
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: qIndex > 0
                        ? () => setState(() => qIndex--)
                        : null,
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

            // Finish Now: user can finish early and view result
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
