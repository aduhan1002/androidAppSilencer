import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../Providers/questions.dart';

class ScoreCard extends StatelessWidget {
  final double height;
  ScoreCard({this.height=0});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: height==0?200:height*0.3,
      padding: EdgeInsets.all(10),
      child: Consumer<Questions>(builder: (ctx,questions,child)=>Column(
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(child: Text('Completed ${questions.item1.length}')),
              Expanded(child: LinearProgressIndicator(value: questions.item1.length/50,)),
            ],),
            SizedBox(height: 10,),
            Row(children: <Widget>[
              Expanded(child: Text('Reviewing ${questions.item2.length}')),
              Expanded(child: LinearProgressIndicator(value: questions.item2.length/50,)),
            ],),
            SizedBox(height: 10,),
            Row(children: <Widget>[
              Expanded(child: Text('Learning ${questions.item3.length}')),
              Expanded(child: LinearProgressIndicator(value: questions.item3.length/50,)),
            ],),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
