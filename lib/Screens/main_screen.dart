import 'package:flutter/material.dart';
import './play_screen.dart';
import './score_screen.dart';

class MainScreen extends StatelessWidget {
  static const String routeName = 'main-screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Silencer"),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('Assets/Images/chatur.jpg'),
          fit: BoxFit.cover,
        )),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text("Play On!"),
                onPressed: () {
                  Navigator.pushNamed(context, PlayScreen.routeName);
                },
                color: Colors.lightBlue,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                splashColor: Colors.grey,
              ),
              RaisedButton(
                child: Text("View Score!"),
                onPressed: () {
                  Navigator.pushNamed(context, ScoreScreen.routeName);
                },
                color: Colors.lightBlue,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                splashColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
