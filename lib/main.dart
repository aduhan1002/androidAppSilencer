import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import './Providers/questions.dart';
import './Providers/auth.dart';

import './Screens/score_screen.dart';
import './Screens/play_screen.dart';
import './Screens/main_screen.dart';
import './Screens/auth_screen.dart';
import './Screens/loading_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Questions>(
          create: (ctx) => Questions(null, null, []),
          update: (ctx, authData, previousQuestions) => Questions(
            authData.token,
            authData.userId,
            previousQuestions == null ? [] : previousQuestions.questions,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          title: 'Silencer',
          theme: ThemeData(
            primarySwatch: Colors.lightBlue,
            accentColor: Colors.amber[200],
            fontFamily: 'Lato',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: authData.isAuth
              ? MainScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return LoadingScreen();
                    return AuthScreen();
                  }),
          routes: {
            MainScreen.routeName: (ctx)=>MainScreen(),
            PlayScreen.routeName: (ctx) => PlayScreen(),
            ScoreScreen.routeName: (ctx)=> ScoreScreen(),
          },
        ),
      ),
    );
  }
}
