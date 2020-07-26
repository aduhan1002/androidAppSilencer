import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Widgets/question_card.dart';
import '../Widgets/score_card.dart';

import '../Providers/questions.dart';

class PlayScreen extends StatefulWidget {
  static const String routeName = 'play-screen';

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  double mediaQuery;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<Questions>(context, listen: false).fetchAndSyncData();
    mediaQuery=MediaQuery.of(context).size.height- MediaQuery.of(context).padding.top-kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Play')),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black45,
        ),
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              QuestionCard(mediaQuery),
              ScoreCard(height:mediaQuery),
            ],
          ),
        ),
      ),
    );
  }
}
