import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pma/utils/list_item.dart';
import 'package:flutter_pma/utils/navigation_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_pma/utils/util.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginData {
  String email = '';
  String password = '';
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _fireBaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  String _message = 'Log in/out by pressing the buttons below.';
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _LoginData _data = new _LoginData();

  Future<User?> _googleSignInButton() async {
    GoogleSignInAccount? _googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _googleSignInAuth =
        await _googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: _googleSignInAuth.accessToken,
      idToken: _googleSignInAuth.idToken,
    );
    UserCredential _fireBaseUser =
        await _fireBaseAuth.signInWithCredential(credential);
    User? user = _fireBaseUser.user;
    // print("user name : ${_fireBaseUser.photoUrl}");
    if (user != null) {
      Util.userName = user.displayName ?? "";
      Util.emailId = user.email ?? "";
      Util.profilePic = user.photoURL ?? "";
    }
    NavigationRouter.switchToHome(context);
    return user;
  }

  Future<Null> _facebookLogin() async {
    /*final FacebookLoginResult result = await facebookSignIn.
        .logInWithReadPermissions(['email', 'public_profile', 'user_posts']);
    //,publish_actions,manage_pages,publish_pages,user_status,user_videos,user_work_history

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        accessToken.permissions;

        var graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,picture,last_name,email&access_token=${accessToken.token}'));
        Map<String, dynamic> user = jsonDecode(graphResponse.body);
        Map<String, dynamic> picture = user['picture'];
        Map<String, dynamic> data = picture['data'];
        Util.userName = user['name'];
        Util.emailId = user['email'];
        Util.profilePic = data['url'];
        var graphResponseFeed = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me/feed?fields=message&access_token=${accessToken.token}'));
        var data1 = jsonDecode(graphResponseFeed.body);
        // print(data1);

        // me?fields=id,name,feed{message,attachments}
        var graphResponseFeed1 = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=id,name,feed{attachments,message}&access_token=${accessToken.token}'));
        var data1l = jsonDecode(graphResponseFeed1.body);
        Map<String, dynamic> root = jsonDecode(graphResponseFeed1.body);
        Map<String, dynamic> feed = root['feed'];
        var fdata = feed['data'];

        for (var i = 0; i < fdata.length; i++) {
          var qq = fdata[i];
          // var pp = qq['attachments'];
          if (qq['attachments'] == null) {
            i++;
          } else {
            Map<String, dynamic> pp = qq['attachments'];
            var nn = pp['data'];
            for (var j = 0; j < nn.length; j++) {
              var mm = nn[j];
              var jj = mm['media'];
              var img = jj['image'];
              var src = img['src'];
              print(src);
              Util.descriptionList.add(mm['description']);
              Util.mediaList.add(img['src']);
              // Util.listItems.add(new ListItem(mm['description'], img['src']));
            }
          }
          NavigationRouter.switchToHome(context);
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }*/
  }

  Future<Null> _logOut() async {
    //await facebookSignIn.logOut();
    _showMessage('Logged out.');
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'The Password must be at least 8 characters.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (!(value != null && value.contains("@") && value.contains("."))) {
      return 'The E-mail Address must be a valid email address.';
    }
    return null;
  }

  void _submit() {
    if (this._formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save our form now.

      print('Printing the login data.');
      print('Email: ${_data.email}');
      print('Password: ${_data.password}');
    }
  }

/* void _performLogin() {
   // This is just a demo, so no actual login here.
   final snackbar = new SnackBar(
     content: new Text('Email: $_email, password: $_password'),
   );

   scaffoldKey.currentState.showSnackBar(snackbar);
 }*/
  @override
  Widget build(BuildContext context) {
    MediaQueryData media = MediaQuery.of(context);

    final Size screenSize = media.size;
    return new Scaffold(
      //key: this.scaffoldKey,
      appBar: new AppBar(
        title: new Text('Login'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: this._formKey,
            child: new ListView(
              children: <Widget>[
                new Container(
                    padding: new EdgeInsets.all(20.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlutterLogo(
                          size: 100.0,
                        ),
                      ],
                    )),
                new Container(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: new TextFormField(
                        keyboardType: TextInputType
                            .emailAddress, // Use email input type for emails.
                        decoration: new InputDecoration(
                            hintText: 'you@example.com',
                            labelText: 'E-mail Address',
                            icon: new Icon(Icons.email)),
                        validator: this._validateEmail,
                        onSaved: (String? value) {
                          this._data.email = value ?? '';
                        })),
                new Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: new TextFormField(
                      obscureText: true, // Use secure text for passwords.
                      decoration: new InputDecoration(
                          hintText: 'Password',
                          labelText: 'Enter your password',
                          icon: new Icon(Icons.lock)),
                      validator: this._validatePassword,
                      onSaved: (String? value) {
                        this._data.password = value ?? '';
                      }),
                ),
                new Container(
                  width: screenSize.width,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        height: 50.0,
                        margin: const EdgeInsets.only(left: 10.0, top: 30.0),
                        child: new ElevatedButton(
                          child: new Text(
                            'Login',
                            style: new TextStyle(color: Colors.white),
                          ),
                          onPressed: this._submit,
                        ),
                      ),
                      new Container(
                        height: 50.0,
                        margin: const EdgeInsets.only(left: 20.0, top: 30.0),
                        child: new ElevatedButton(
                          child: new Text(
                            'Registration',
                            style: new TextStyle(color: Colors.white),
                          ),
                          onPressed: _navigateRegistration
                        ),
                      )
                    ],
                  ),
                ),
                new Container(
                  width: screenSize.width,
                  child: new Column(
                    children: <Widget>[
                      new Container(
                        margin: const EdgeInsets.only(left: 10.0, top: 20.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              height: 50.0,
                              width: 210.0,
                              child: new ElevatedButton.icon(
                                label: new Text(
                                  'Login with Google+',
                                  style: new TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                icon: new Image.asset("assets/google_plus.png",
                                    width: 24.0, height: 24.0),
                                onPressed: () => _googleSignInButton()
                                    .then(
                                      (User? user) => print(user),
                                    )
                                    .catchError((e) => print(e))
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(left: 10.0, top: 20.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              height: 50.0,
                              width: 210.0,
                              child: new ElevatedButton.icon(
                                label: new Text(
                                  'Login with Facebook',
                                  style: new TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                icon: new Image.asset(
                                  "assets/facebook.png",
                                  width: 24.0,
                                  height: 24.0,
                                ),
                                // icon: const Icon(Icons.adjust, size: 28.0,color: Colors.white),

                                onPressed: this._facebookLogin
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  _navigateRegistration() {
    NavigationRouter.switchToRegistration(context);
  }
}
