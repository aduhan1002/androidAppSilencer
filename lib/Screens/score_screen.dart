import 'package:flutter/material.dart';

import '../Widgets/score_card.dart';

class ScoreScreen extends StatelessWidget {
  static const routeName='scores';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Score')),
      body: Container(
        color: Colors.white,
        child: Center(child: ScoreCard(),)),
    );
  }
}