import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_text_anchor/flutter_text_anchor.dart';
import 'package:WeFreak/includes/urllauncher.dart';
import 'package:WeFreak/includes/bottomnav.dart';

//void main() => runApp(Login());

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  // few required vars
  bool _isLoggedIn = false;
  Map userData;
  final FacebookLogin fbLogin = FacebookLogin();
  String gender;
  String userEmail;
  String dob;


  // assyc function to start session on new users
  // _startSession(name, id, email, picUrl, dob, gender) async {    

  //   // save data to online server
  //   var dataToSend = {
  //     "email": email,
  //     "name": name,
  //     "fb_id": id,
  //     "dob": dob,
  //     "gender": gender,
  //     "tel": '',
  //     "picture": picUrl,
  //     "type": "login"
  //   };
    
  //   var response = await DbQueries('newuser', dataToSend).query();

  //   if (response == 'success') {
  //      // start session
  //     var session = FlutterSession();
  //     await session.set("name", name);
  //     await session.set("email", email);
  //     //call the rerouting function
  //     Navigator.pushReplacementNamed(context, '/');
  //   } else {
  //    ToastMessage('$response').showMessageError();
  //   }
  // }

  // login with facebook function
  // _loginWithFb() async {
  //   final result = await fbLogin.logInWithReadPermissions(['email']);

  //   switch (result.status) {
  //     case FacebookLoginStatus.loggedIn:
  //       final token = result.accessToken.token;
  //       final fbResponse = await http.get(
  //           'https://graph.facebook.com/v2.12/me?fields=name,picture,email,gender,birthday,first_name&access_token=$token');
  //       final profile = jsonDecode(fbResponse.body);
  //       // change state after successful login        
  //       setState(() {
  //         userData = profile;
  //         _isLoggedIn = true;
  //         var picUrl = userData['picture']['data']['url'];

  //         gender = userData['gender'] != null ? userData['gender'] : 'Male';
  //         dob = userData['birthday'] != null ? userData['birthday'] : '2002-01-01';

  //         if (userData['email'] != null)
  //           userEmail = userData['email'];
  //         else {
  //           int randomNumber = Random().nextInt(100000);
  //           int rand2 = Random().nextInt(1000);
  //           userEmail = userData['first_name'] + rand2.toString() + randomNumber.toString() + '@gmail.com';
  //         }
  //         // send data to server
  //         _startSession(userData['name'], userData['id'], userEmail,
  //             picUrl, dob, gender);
  //       });
  //       break;
  //     case FacebookLoginStatus.cancelledByUser:
  //       setState(() => _isLoggedIn = false);
  //       break;
  //     case FacebookLoginStatus.error:
  //       setState(() => _isLoggedIn = false);
  //       break;
  //   }
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar:  BottomNav().appBarPages('Login', context),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: _isLoggedIn
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //Image.network(userData['picture']['data']['url']),
                    //'https://we-freak.com/public/assets/system/default_dp.jpg'),
                    //Text(userData['name'] + ' ' + userData['id']),
                    OutlineButton(
                      onPressed: () { Navigator.pushReplacementNamed(context, '/');},
                      child: Center(child: Text('Logging you in',
                      style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600)  
                      ),),
                    ),
                  ],
                )
              : Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget> [
                      // FlatButton(
                      //   color: Color(0xFF42A5F5),
                      //   onPressed: () {
                      //     _loginWithFb();
                      //   },
                      //   child: Text('Login with Facebook', style: TextStyle(color: Colors.white70, fontSize: 25)),
                      // ),
                      RaisedButton(
                        color: Color.fromARGB(255, 255, 20, 147),
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text('Create new account', style: TextStyle(color: Colors.white70, fontSize: 24, fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/lostpassword');
                        },
                        child: Text('Have account already?', style: TextStyle(color: Colors.grey, fontSize: 20)),
                      ),
                      SizedBox(width: 10.0, height: 20.0),
                      Center(
                        child: TextAnchor(
                        textColor: Colors.black54,
                        linkColor: Colors.pink,
                        fontWeight: FontWeight.w300,
                        fontSize: 18.0,
                        text:
                            ''' By signing up, you agree to our (terms and conditions)[https://we-freak.com/index/terms].
              ''',
                        onTapLink: (link) {
                          UrlLauncher(link).launchUrl();
                        },
                      ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
