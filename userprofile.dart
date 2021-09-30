import 'package:flutter/material.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'dart:async';
import 'package:in_app_update/in_app_update.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // vars
  String _email;
  AppUpdateInfo _updateInfo;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  bool _flexibleUpdateAvailable = false;
  String _updateInfomessage = "Your version is the latest";

    // ensure the user is logged in
  _validateLogin() async {
      ValidateSession sess = ValidateSession(context);
      sess.valSession();
      var email = await sess.returnEmail();
      setState(() => _email = email);
  }

  // fetch data from session
  Future _getUserData(_email) async {
    return await DbQueries('getuserdata', {'email':_email}).query(); 
  }
  
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    try{
      InAppUpdate.checkForUpdate().then((info) {
        setState(() {
          _updateInfo = info;
          _updateInfomessage = "Your app needs updation";
        });
        if (_updateInfo.updateAvailable == true) {
          InAppUpdate.performImmediateUpdate().catchError((e) => _showSnackBar(context, e));
        }
      }).catchError((e) => _showSnackBar(context, e) );

    } catch(e) {
      _showSnackBar(context, e);
    }
  }

    _showSnackBar(context, _snack) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
        content: Text(_snack.toString()) ,
        backgroundColor: Colors.grey[400],
        duration: Duration(seconds: 2),
      ));
    }
  void _showError(dynamic exception) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(exception.toString())));
  }

  Widget _updateinfoWidget() {
    //if (_updateInfo.updateAvailable == true) {
     return Card(
       child: Padding(
         padding: EdgeInsets.all(5),
         child: Column(
           children: [
             Text('Update info: $_updateInfomessage'),
             
              RaisedButton(
                child: Text(_updateInfo.updateAvailable == true ? 'Perform flexible update' : 'Check for updates'),
                onPressed: _updateInfo?.updateAvailable == true
                    ? () {
                      
                          try{
                            InAppUpdate.checkForUpdate().then((info) {                             
                              InAppUpdate.performImmediateUpdate().catchError((e) => _showSnackBar(context, e));
                            }).catchError((e) => _showSnackBar(context, e));

                          } catch(e) {
                            _showSnackBar(context, e);
                          }
                      }
                    : null,
              ),
           ],
         ),
       ),
     );
    //} else return Container();
  }


  @override
  void initState() {
    super.initState();
    _validateLogin();
    ValidateSession('context').setSession('pleasepay', 'somerandomthindnotexisting');
    checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        key: _scaffoldKey,
      appBar: BottomNav().appBarPages('Profile', context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        clipBehavior: Clip.none,
        child: Container(
          //padding: EdgeInsets.all(2.0),
          child: FutureBuilder(
              future: _getUserData(_email), 
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Loader().spinLoader();//Center(child: Text('Loading...'));
                } else {
                  return Container(     
                    padding: EdgeInsets.all(13.0),           
                    // here
                    child: Column(
                      children: <Widget> [
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(snapshot.data['user_dp']),
                        ),
                        SizedBox(width: 10.0, height: 10.0),                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget> [
                             IconButton(
                              iconSize: 50.0,
                              icon: Icon(Icons.settings),
                              color: Colors.grey,
                              onPressed: () {Navigator.pushNamed(context, '/settings');},
                            ),
                            IconButton(
                              iconSize: 45.0,
                              icon: Icon(Icons.add_a_photo),
                              color: Colors.pinkAccent,
                              onPressed: () {Navigator.pushNamed(context, '/upload'); },
                            ),
                            IconButton(
                              iconSize: 50.0,
                              icon: Icon(Icons.edit),
                              color: Colors.grey,
                              onPressed: () {Navigator.pushNamed(context, '/info');},
                            ),
                          ],
                        ), 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget> [
                            Text('Settings', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                            Text('Add media', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                            Text('Edit Info', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                          ],
                        ), 

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.0),
                          child: Center(
                            child: RaisedButton(
                              color: Colors.pink,
                              child: Text('Subscriptions', style: TextStyle(color: Colors.white, fontSize: 22,
                              fontFamily: 'Courier',  fontWeight: FontWeight.w700),),
                              onPressed: () {Navigator.pushNamed(context, '/paynow');},
                            ),
                          ),
                        ), 

                       _updateinfoWidget(),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.0),
                          child: Center(
                            child: RaisedButton(
                              color: Colors.pink,
                              child: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 22,
                              fontFamily: 'Courier',  fontWeight: FontWeight.w700),),
                              onPressed: () {
                                ValidateSession('context').setSession('email', 'null');
                                Navigator.pushNamed(context, '/login');
                              },
                            ),
                          ),
                        ), 
                      ],
                    ),
                   
                    //end 
                  );
                }
              }),
        ),
      ),
       bottomNavigationBar: BottomNav().nav(3, context),
    );
  }
}

