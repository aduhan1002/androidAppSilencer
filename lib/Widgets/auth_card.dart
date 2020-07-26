import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey();

  AnimationController _animationController;
  Animation<double> _fadeAnimation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInToLinear));
    //_heightAnimation.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  bool _isLoading = false;
  var _passwordController = TextEditingController();

  void _switchAuthMode() {
    if (_authMode == AuthMode.Signup) {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animationController.reverse();
    } else {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animationController.forward();
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on Exception catch (error) {
      print('SCREEN' + error.toString());
      var errorString = 'Authentication Failed!';
      if (error.toString().contains('INVALID_EMAIL')) {
        errorString = 'Entered E-Mail is invalid!';
      } else if (error.toString().contains('EMAIL_EXIST')) {
        errorString = 'Entered E-Mail already exists!';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorString = 'Entered Password is weak!';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorString = 'Entered E-Mail does not exists!';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorString = 'Entered Password is invalid!';
      }
      _showErrorMessage(errorString);
    } catch (error) {
      const errorString = 'Could not process the request. Try again later.';
      _showErrorMessage(errorString);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
        height: _authMode == AuthMode.Signup ? 320 : 260,
        //height: _heightAnimation.value.height,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Signup ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    _passwordFocusNode.nextFocus();
                  },
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid E-Mail';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  textInputAction: _authMode == AuthMode.Login
                      ? TextInputAction.done
                      : TextInputAction.next,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  onFieldSubmitted: (value) {
                    if (_authMode == AuthMode.Login) {
                      _submit();
                    } else {
                      _confirmPasswordFocusNode.nextFocus();
                    }
                  },
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: TextFormField(
                      focusNode: _confirmPasswordFocusNode,
                      enabled: _authMode == AuthMode.Signup,
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      onFieldSubmitted: (value) {
                        _submit();
                      },
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text(
                      _authMode == AuthMode.Signup ? 'SIGN UP' : 'LOGIN',
                    ),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                      '${_authMode == AuthMode.Signup ? 'LOGIN' : 'SIGN UP'} INSTEAD'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
