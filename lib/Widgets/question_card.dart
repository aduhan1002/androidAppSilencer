import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/questions.dart';

class QuestionCard extends StatefulWidget {
  final double height;
  QuestionCard(this.height);
  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  void questionAnswered(passed, question) async {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(passed ? 'Correct' : 'Wrong'),
      duration: Duration(seconds: 1),
    ));
    await Future.delayed(Duration(seconds: 1));
    Provider.of<Questions>(context, listen: false)
        .changeScore(passed, question);
    Provider.of<Questions>(context, listen: false).changeQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final question = Provider.of<Questions>(context).item;
    if (question == null) {
      return Container(
        height: widget.height * 0.7,
        color: Colors.white,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    List<String> optionsList = [];
    optionsList = question.options;
    optionsList.add(question.answer);
    optionsList.shuffle();
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      height: widget.height * 0.7,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30,),
            Text(question != null
                ? question.question
                : "Who wrote and directed the animated movie Spirited Away (2001)?"),
            SizedBox(
              height: 20,
            ),
            FlatButton(
              child: Text(question != null ? optionsList[0] : "Hayao Miyazaki"),
              onPressed: () {
                questionAnswered(optionsList[0] == question.answer, question);
              },
            ),
            SizedBox(
              height: 5,
            ),
            FlatButton(
              child: Text(question != null ? optionsList[1] : "Isao Takahata"),
              onPressed: () {
                questionAnswered(optionsList[1] == question.answer, question);
              },
            ),
            SizedBox(
              height: 5,
            ),
            FlatButton(
              child: Text(question != null ? optionsList[2] : "Mamoru Hosoda"),
              onPressed: () {
                questionAnswered(optionsList[2] == question.answer, question);
              },
            ),
            SizedBox(
              height: 5,
            ),
            FlatButton(
              child:
                  Text(question != null ? optionsList[3] : "Hidetaka Miyazaki"),
              onPressed: () {
                questionAnswered(optionsList[3] == question.answer, question);
              },
            ),
          ],
        ),
      ),
    );
  }
}
