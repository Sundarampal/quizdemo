import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
