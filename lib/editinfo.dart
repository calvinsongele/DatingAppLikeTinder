import 'package:flutter/material.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/dbqueries.dart';


class EditInfo extends StatefulWidget {
  @override
  _EditInfoState createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  // vars
  String _email;
  //var _userDetails;
  String _url;
  // String bb = FlutterSession().get("email");

  // ensure the user is logged in
    _validateLogin() async {
      ValidateSession sess = ValidateSession(context);
      sess.valSession();
      var email = await sess.returnEmail();
      setState(() => _email = email);
  }

  // fetch data from session
  Future _getUserData(_email) async {
    return await DbQueries('getuserdata', {'email': _email}).query();
  }

  _saveDataToServer(_email, col, value) async {
     _url = 'https://we-freak.com/flutterapp/saveuserdata';
    var dataToSend = {"email": _email, "col": col, "value": value};
    var response = await http.post(_url, body: dataToSend);
    if (JSON.jsonDecode(response.body) == 'success') {
    
      Fluttertoast.showToast(
          msg: 'Field saved',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 30,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      // log the user in
      Fluttertoast.showToast(
          msg: JSON.jsonDecode(response.body),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 30,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  // rerouting function
   BottomNav bottomNav = BottomNav();

  @override
  void initState() {
    super.initState();
    _validateLogin();
    //fetchDataFromServer(_email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BottomNav().appBarPages('Edit Profile', context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        clipBehavior: Clip.none,
        child: Container(
          padding: EdgeInsets.all(2.0),
          child: FutureBuilder(
              future: _getUserData(_email),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Loader().spinLoader();
                } else {
                  return Container(
                    child: Column(
                      children: <Widget> [
                        Column(
                          children: <Widget> [
                            Text('About ' + snapshot.data['user_names'].split(' ')[0],
                             style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600) ),
                            TextFormField(
                              maxLength: 500,
                              //maxLengthEnforced: true,
                              initialValue: snapshot.data['user_about'],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                
                              ),
                              onFieldSubmitted: (String value) {
                               _saveDataToServer(_email, 'user_about', value);
                              },
                            ),
                            Text('Passions',  style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                            TextFormField(
                              //maxLengthEnforced: true,
                              initialValue: snapshot.data['user_passions'],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                
                              ),
                              onFieldSubmitted: (String value) {
                               _saveDataToServer(_email, 'user_passions', value);
                              },
                            ),
                             Text('Job Title',
                              style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                            TextFormField(
                              //maxLengthEnforced: true,
                              initialValue: snapshot.data['user_job_title'],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                
                              ),
                              onFieldSubmitted: (String value) {
                               _saveDataToServer(_email, 'user_job_title', value);
                              },
                            ),
                             Text('Company',
                              style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                            TextFormField(
                              //maxLengthEnforced: true,
                              initialValue: snapshot.data['user_company'],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                
                              ),
                              onFieldSubmitted: (String value) {
                               _saveDataToServer(_email, 'user_company', value);
                              },
                            ),
                             Text('School',
                              style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                            TextFormField(
                              //maxLengthEnforced: true,
                              initialValue: snapshot.data['user_school'],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                
                              ),
                              onFieldSubmitted: (String value) {
                               _saveDataToServer(_email, 'user_school', value);
                              },
                            ),
                            Text('Living In',
                             style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                            TextFormField(
                              //maxLengthEnforced: true,
                              initialValue: snapshot.data['user_city'],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,                                
                              ),
                              onChanged: (String value) {
                               _saveDataToServer(_email, 'user_city', value);
                              },
                            ),
                            Text('Gender',
                             style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                            TextFormField(
                              //maxLengthEnforced: true,
                              initialValue: snapshot.data['user_gender'],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,                                
                              ),
                              onFieldSubmitted: (String value) {
                               _saveDataToServer(_email, 'user_gender', value);
                              },
                            ),
                           Text('Control Your Profile',
                            style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                           SizedBox(width: 10.0, height: 5.0),
                           SingleChildScrollView(
                             scrollDirection: Axis.horizontal,
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text("Don't Show My Age ",
                                style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w500)),
                               ToggleSwitch(
                                initialLabelIndex: int.parse(snapshot.data['user_show_age']),
                                minWidth: 80.0,
                                cornerRadius: 20.0,
                                activeBgColor: Colors.cyan,
                                activeFgColor: Colors.white,
                                inactiveBgColor: Colors.grey,
                                inactiveFgColor: Colors.white,
                                labels: ['YES', 'NO'],
                                icons: [Icons.check, Icons.close],
                                onToggle: (value) {
                                  _saveDataToServer(_email, 'user_show_age', value.toString());
                                },
                              ),
                             ],
                           ),),
                            SizedBox(width: 10.0, height: 10.0),
                           Column(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text("Make My Distance Invisible", 
                                style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w400)),
                               ToggleSwitch(
                                initialLabelIndex: int.parse(snapshot.data['user_show_distance']),
                                minWidth: 70.0,
                                cornerRadius: 20.0,
                                activeBgColor: Colors.cyan,
                                activeFgColor: Colors.white,
                                inactiveBgColor: Colors.grey,
                                inactiveFgColor: Colors.white,
                                labels: ['YES', 'NO'],
                                icons: [Icons.check, Icons.close],
                                onToggle: (value) {
                                  _saveDataToServer(_email, 'user_show_distance', value.toString());
                                },
                              ),
                             ],
                           ),

                          ],
                        ),
                      ],
                    ),
                  );
                }
              }),
        ),
      ),
       bottomNavigationBar: bottomNav.nav(3, context),
    );
  }
}

