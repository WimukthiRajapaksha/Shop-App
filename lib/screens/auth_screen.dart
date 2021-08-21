import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/model/http_exception.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode { SignUp, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = "/auth";

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                      Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, 1])),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepOrange.shade900,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(0, 2))
                          ]),
                      child: Text(
                        "MyShop",
                        style: TextStyle(
                            color:
                                Theme.of(context).accentTextTheme.title!.color,
                            fontSize: 50,
                            fontFamily: "Anton",
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  Flexible(
                    child: AuthCard(),
                    flex: deviceSize.width > 600 ? 2 : 1,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authData = {"email": "", "password": ""};
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController? _animationController;
  // Animation<Size>? _heightAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    this._animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    // this._heightAnimation = Tween<Size>(
    //         begin: Size(double.infinity, 260), end: Size(double.infinity, 320))
    //     .animate(CurvedAnimation(
    //         parent: this._animationController!, curve: Curves.linear));
    this._slideAnimation =
        Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0)).animate(
            CurvedAnimation(
                parent: this._animationController!, curve: Curves.linear));
    this._opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: this._animationController!, curve: Curves.easeIn));
    // this._heightAnimation!.addListener(() {
    //   return this.setState(() {});
    // });
    super.initState();
  }

  @override
  void dispose() {
    this._animationController!.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      this._isLoading = true;
    });
    try {
      if (this._authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .login(this._authData["email"]!, this._authData["password"]!);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signUp(this._authData["email"]!, this._authData["password"]!);
      }
    } on HttpException catch (error) {
      print(error);
      print("Http");
      var errorMsg = "Authentication failed";
      if (error.toString().contains("EMAIL_EXISTS")) {
        errorMsg = "This email address is alreay in use";
      } else if (error.toString().contains("INVALID_EMAIL")) {
        errorMsg = "This is not a valid email address";
      } else if (error.toString().contains("WEAK_PASSWORD")) {
        errorMsg = "This password is too weak";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMsg = "Couldn't find a user with that email";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMsg = "Invalid password";
      }
      this._showDialog(errorMsg);
    } catch (error) {
      print(error);
      print("catch");
      const errorMsg = "Couldn't authenticate you. Please try again later!";
      this._showDialog(errorMsg);
    }
    setState(() {
      this._isLoading = false;
    });
  }

  void _showDialog(String msg) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Error occurred!"),
              content: Text(msg),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("OKAY"))
              ],
            ));
  }

  void _switchAuthMode() {
    if (this._authMode == AuthMode.Login) {
      setState(() {
        this._authMode = AuthMode.SignUp;
      });
      this._animationController!.forward();
    } else {
      setState(() {
        this._authMode = AuthMode.Login;
      });
      this._animationController!.reverse();
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   final deviceSize = MediaQuery.of(context).size;
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     elevation: 8,
  //     child: Container(
  //       // height: (this._authMode == AuthMode.SignUp) ? 320 : 260,
  //       height: this._heightAnimation!.value.height,
  //       constraints: BoxConstraints(
  //         // minHeight: (this._authMode == AuthMode.SignUp) ? 320 : 260,
  //         minHeight: this._heightAnimation!.value.height,
  //       ),
  //       width: deviceSize.width * 0.75,
  //       padding: EdgeInsets.all(16.0),
  //       child: Form(
  //         key: _formKey,
  //         child: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               TextFormField(
  //                 decoration: InputDecoration(labelText: "E-Mail"),
  //                 keyboardType: TextInputType.emailAddress,
  //                 validator: (value) {
  //                   if (value!.isEmpty || !value.contains("@")) {
  //                     return "Invalid email";
  //                   }
  //                 },
  //                 onSaved: (newValue) {
  //                   _authData["email"] = newValue!;
  //                 },
  //               ),
  //               TextFormField(
  //                 decoration: InputDecoration(labelText: "Password"),
  //                 obscureText: true,
  //                 controller: _passwordController,
  //                 validator: (value) {
  //                   if (value!.isEmpty || value.length < 5) {
  //                     return "Password is too short";
  //                   }
  //                 },
  //                 onSaved: (newValue) {
  //                   _authData["password"] = newValue!;
  //                 },
  //               ),
  //               if (this._authMode == AuthMode.SignUp)
  //                 TextFormField(
  //                   enabled: (this._authMode == AuthMode.SignUp),
  //                   decoration: InputDecoration(labelText: "Confirm Password"),
  //                   obscureText: true,
  //                   validator: (this._authMode == AuthMode.SignUp)
  //                       ? (value) {
  //                           if (value != this._passwordController.text) {
  //                             return "Password do not match";
  //                           }
  //                         }
  //                       : null,
  //                 ),
  //               SizedBox(
  //                 height: 20.0,
  //               ),
  //               if (this._isLoading)
  //                 CircularProgressIndicator()
  //               else
  //                 RaisedButton(
  //                   onPressed: this._submit,
  //                   child: Text((this._authMode == AuthMode.Login)
  //                       ? "LOGIN"
  //                       : "SIGN UP"),
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(30)),
  //                   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
  //                   color: Theme.of(context).primaryTextTheme.button!.color,
  //                 ),
  //               FlatButton(
  //                 onPressed: this._switchAuthMode,
  //                 child: Text(
  //                     "${(this._authMode == AuthMode.Login) ? "SIGN UP" : "LOGIN"} INSTEAD"),
  //                 padding: EdgeInsets.symmetric(vertical: 4, horizontal: 30),
  //                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                 textColor: Theme.of(context).primaryColor,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   final deviceSize = MediaQuery.of(context).size;
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     elevation: 8,
  //     child: AnimatedBuilder(
  //       animation: this._heightAnimation!,
  //       child: Form(
  //         key: _formKey,
  //         child: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               TextFormField(
  //                 decoration: InputDecoration(labelText: "E-Mail"),
  //                 keyboardType: TextInputType.emailAddress,
  //                 validator: (value) {
  //                   if (value!.isEmpty || !value.contains("@")) {
  //                     return "Invalid email";
  //                   }
  //                 },
  //                 onSaved: (newValue) {
  //                   _authData["email"] = newValue!;
  //                 },
  //               ),
  //               TextFormField(
  //                 decoration: InputDecoration(labelText: "Password"),
  //                 obscureText: true,
  //                 controller: _passwordController,
  //                 validator: (value) {
  //                   if (value!.isEmpty || value.length < 5) {
  //                     return "Password is too short";
  //                   }
  //                 },
  //                 onSaved: (newValue) {
  //                   _authData["password"] = newValue!;
  //                 },
  //               ),
  //               if (this._authMode == AuthMode.SignUp)
  //                 TextFormField(
  //                   enabled: (this._authMode == AuthMode.SignUp),
  //                   decoration: InputDecoration(labelText: "Confirm Password"),
  //                   obscureText: true,
  //                   validator: (this._authMode == AuthMode.SignUp)
  //                       ? (value) {
  //                           if (value != this._passwordController.text) {
  //                             return "Password do not match";
  //                           }
  //                         }
  //                       : null,
  //                 ),
  //               SizedBox(
  //                 height: 20.0,
  //               ),
  //               if (this._isLoading)
  //                 CircularProgressIndicator()
  //               else
  //                 RaisedButton(
  //                   onPressed: this._submit,
  //                   child: Text((this._authMode == AuthMode.Login)
  //                       ? "LOGIN"
  //                       : "SIGN UP"),
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(30)),
  //                   padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
  //                   color: Theme.of(context).primaryTextTheme.button!.color,
  //                 ),
  //               FlatButton(
  //                 onPressed: this._switchAuthMode,
  //                 child: Text(
  //                     "${(this._authMode == AuthMode.Login) ? "SIGN UP" : "LOGIN"} INSTEAD"),
  //                 padding: EdgeInsets.symmetric(vertical: 4, horizontal: 30),
  //                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                 textColor: Theme.of(context).primaryColor,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       builder: (ctx, chi) => Container(
  //         // height: (this._authMode == AuthMode.SignUp) ? 320 : 260,
  //         height: this._heightAnimation!.value.height,
  //         constraints: BoxConstraints(
  //           // minHeight: (this._authMode == AuthMode.SignUp) ? 320 : 260,
  //           minHeight: this._heightAnimation!.value.height,
  //         ),
  //         width: deviceSize.width * 0.75,
  //         padding: EdgeInsets.all(16.0),
  //         child: chi,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 450),
        curve: Curves.easeIn,
        height: (this._authMode == AuthMode.SignUp) ? 320 : 260,
        // height: this._heightAnimation!.value.height,
        constraints: BoxConstraints(
          minHeight: (this._authMode == AuthMode.SignUp) ? 320 : 260,
          // minHeight: this._heightAnimation!.value.height,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "E-Mail"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains("@")) {
                      return "Invalid email";
                    }
                  },
                  onSaved: (newValue) {
                    _authData["email"] = newValue!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return "Password is too short";
                    }
                  },
                  onSaved: (newValue) {
                    _authData["password"] = newValue!;
                  },
                ),
                // if (this._authMode == AuthMode.SignUp)
                //   TextFormField(
                //     enabled: (this._authMode == AuthMode.SignUp),
                //     decoration: InputDecoration(labelText: "Confirm Password"),
                //     obscureText: true,
                //     validator: (this._authMode == AuthMode.SignUp)
                //         ? (value) {
                //             if (value != this._passwordController.text) {
                //               return "Password do not match";
                //             }
                //           }
                //         : null,
                //   ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 450),
                  constraints: BoxConstraints(
                      minHeight: this._authMode == AuthMode.SignUp ? 60 : 0,
                      maxHeight: this._authMode == AuthMode.SignUp ? 120 : 0),
                  child: FadeTransition(
                    opacity: this._opacityAnimation!,
                    child: SlideTransition(
                      position: this._slideAnimation!,
                      child: TextFormField(
                        enabled: (this._authMode == AuthMode.SignUp),
                        decoration:
                            InputDecoration(labelText: "Confirm Password"),
                        obscureText: true,
                        validator: (this._authMode == AuthMode.SignUp)
                            ? (value) {
                                if (value != this._passwordController.text) {
                                  return "Password do not match";
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                if (this._isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    onPressed: this._submit,
                    child: Text((this._authMode == AuthMode.Login)
                        ? "LOGIN"
                        : "SIGN UP"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    color: Theme.of(context).primaryTextTheme.button!.color,
                  ),
                FlatButton(
                  onPressed: this._switchAuthMode,
                  child: Text(
                      "${(this._authMode == AuthMode.Login) ? "SIGN UP" : "LOGIN"} INSTEAD"),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 30),
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
