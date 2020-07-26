import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Question {
  String id;
  String question;
  List<String> options;
  String answer;
  int category;
  Question(
      {this.question, this.answer, this.options, this.category = 1, this.id});
}

class Questions extends ChangeNotifier {
  static const String baseUrl = 'https://silencerproject.firebaseio.com/';
  List<Question> item1 = [], item2 = [], item3 = [];
  List<Question> questions = [];
  int index = 0;
  final String token, userId;

  Questions(this.token, this.userId, this.questions);

  List<Question> get items {
    return [...questions];
  }

  void changeScore(passed, question) {
    if (questions.length > 0 && questions.lastIndexOf(question) > -1) {
      if (passed) {
        question.category=1;
        item1.add(question);
      } else {
        question.category=3;
        item3.add(question);
      }
      questions.removeAt(0);
    } else if (item3.length > 0 && item3.lastIndexOf(question) > -1) {
      if (passed) {
        question.category=2;
        item2.add(question);
        item3.removeAt(0);
      }
    } else if (item2.length > 0 && item2.lastIndexOf(question) > -1) {
      if (passed) {
        question.category=1;
        item1.add(question);
      } else {
        question.category=3;
        item3.add(question);
      }
      item2.removeAt(0);
    }
    http.patch(baseUrl + 'Users/$userId/${question.id}.json',
        body: json.encode({
          'catgory': question.category,
          'question': question.question,
          'answer': question.answer,
          'options': question.options,
        }));
  }

  void changeQuestion() {
    index++;
    notifyListeners();
  }

  Question get item {
    if (index % 8 == 7 && item3.length > 0) {
      return item3[0];
    }
    if (index % 13 == 12 && item2.length > 0) {
      return item2[0];
    }
    if (questions.length <= 0) return null;
    return questions[0];
  }

  void uploadQuestions() {
    questions.forEach((ques) {
      http.post(baseUrl + 'Users/$userId.json',
          body: json.encode({
            'catgory': ques.category,
            'question': ques.question,
            'answer': ques.answer,
            'options': ques.options,
          }));
    });
  }

  Future<void> addQuestions() async {
    if (questions.length >= 5) {
      index = 0;
      notifyListeners();
      return;
    }
    await http.get(baseUrl + 'Questions/ques.json').then((value) {
      final newQuestions = json.decode(value.body) as Map;
      if (newQuestions == null) {
        return;
      }
      newQuestions.forEach((key, element) {
        List<String> optionsList = [];
        element['options'].forEach((option) {
          optionsList.add(option);
        });
        final ques = Question(
          id: key,
          category: 1,
          question:
              (element['question'] as String).replaceAll(RegExp('&quot;'), ''),
          answer: element['answer'] as String,
          options: optionsList,
        );
        questions.add(ques);
        index = 0;
      });
      notifyListeners();
      uploadQuestions();
    });
  }

  Future<void> fetchAndSyncData() async {
    await http.get(baseUrl + '$userId.json?auth=$token').then((value) {
      final itemsData = json.decode(value.body) as Map<String, dynamic>;
      if (itemsData == null) {
        addQuestions();
        return;
      }
      questions.clear();
      itemsData.forEach((key, value) {
        final ques = Question(
            id: key,
            category: value['category'],
            question: value['question'],
            answer: value['answer'],
            options: value['options']);
        questions.add(ques);
        if (value['category'] == 1) {
          item1.add(ques);
        } else if (value['category'] == 2) {
          item2.add(ques);
        } else if (value['category'] == 3) {
          item3.add(ques);
        }
      });
      index = 0;
      notifyListeners();
    });
  }
}
