import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_text_anchor/flutter_text_anchor.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:WeFreak/includes/toastmessage.dart';
import 'package:WeFreak/includes/urllauncher.dart';
import 'package:WeFreak/includes/dbqueries.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // vars
  String _email;
  var _userDetails;
  RangeValues _currentRangeValues;
  RangeValues _currentRangeValuesage;

  // ensure the user is logged in
   _validateLogin() async {
      ValidateSession sess = ValidateSession(context);
      sess.valSession();
      var email = await sess.returnEmail();
      setState(() => _email = email);
  }

  // location
  _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse &&
            permission == LocationPermission.always) {
            ToastMessage('Location already granted').showMessageSuccess();
            return;
        }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final _coordinates = Coordinates(position.latitude, position.longitude);
    var long = (_coordinates.longitude);
    var lat = _coordinates.latitude;
    String response = await DbQueries('editcoodinates', {"email": _email, "long": '$long', "lat": '$lat'}).query(); 

    if (response != 'success') ToastMessage(response).showMessageError(); 
    else ToastMessage(response).showMessageSuccess();
  }

  // fetch data from session Future
   _getUserData(_email) async {
     _userDetails = await DbQueries('getuserdata', {'email':_email}).query(); 

    _currentRangeValues = RangeValues(0, double.parse(_userDetails['user_distance_preference']));
    _currentRangeValuesage = RangeValues(double.parse(_userDetails['user_pref_age_range1']), double.parse(_userDetails['user_pref_age_range2']));
    return _userDetails; //_userDetails;
  }
 

  _saveDataToServer(_email, col, value) async {
    Map dataToSend = {
      "email": _email,
      "col": col,
      "value": value,
      "users_table": '1'
    };
    var response = await DbQueries('saveuserdata', dataToSend).query();

    if (response == 'success') ToastMessage('Field saved').showMessageSuccess();
    else ToastMessage('$response').showMessageError();
  }

  _saveDataToServerLocation(_email, col, value) async {
    var dataToSend = {"email": _email, "col": col, "value": value};
     var response = await DbQueries('saveuserdata', dataToSend).query();
    if (response == 'success')
      ToastMessage('Field saved').showMessageSuccess();
    else
      // log the user in
      ToastMessage('$response').showMessageError();
  }

  _changeGendertoIndex(gender) {
    int show;
    switch (gender) {
      case 'Women':
        show = 1;
        break;
      case 'Men':
        show = 0;
        break;
      default:
        show = 2;
        break;
    }
    return show;
  }

  @override
  void initState() {
    super.initState();
    _validateLogin();   
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: BottomNav().appBarPages('Edit Settings', context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        clipBehavior: Clip.none,
        child: Container(
          //padding: EdgeInsets.all(2.0),
          child: FutureBuilder(
              future: _getUserData(_email),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Loader().spinLoader();
                } else {
                  return Container(
                    // here
                    child: Column(
                      children: <Widget> [
                        Text(
                          'Account Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 10.0, height: 5.0),
                        Text('Phone Number', textAlign: TextAlign.left, style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                        TextFormField(
                          //maxLengthEnforced: true,
                          keyboardType: TextInputType.phone,
                          initialValue: snapshot.data['user_tel'],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                          ),
                          onChanged: (String value) {
                            if (value.length > 10) {
                              _saveDataToServer(_email, 'user_tel', value);
                            }
                          },
                        ),
                        Text('Remember one can use your phone to sign in',
                            style:TextStyle(fontSize: 17.0, color: Colors.grey, fontFamily: 'Courier',  fontWeight: FontWeight.w600) ),
                        SizedBox(width: 10.0, height: 10.0),
                        Text('Discovery Settings',
                            style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Location'),
                                FlatButton(
                                  child: Text('My Location',
                                      style:
                                          TextStyle(color: Colors.blueAccent, fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                                  onPressed: () {_getLocation();},
                                )
                              ],
                            ),
                          ),
                        ),
                        Text(
                            'Change your location to see members in other cities.',
                            style:
                                TextStyle(fontSize: 17.0, color: Colors.grey, fontFamily: 'Courier',  fontWeight: FontWeight.w600)),
                        SizedBox(width: 10.0, height: 10.0),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Global', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800),),
                                ToggleSwitch(
                                  initialLabelIndex:
                                      int.parse(snapshot.data['user_global']),
                                  minWidth: 80.0,
                                  cornerRadius: 20.0,
                                  activeBgColor: Colors.cyan,
                                  activeFgColor: Colors.white,
                                  inactiveBgColor: Colors.grey,
                                  inactiveFgColor: Colors.white,
                                  labels: ['NO', 'YES'],
                                  icons: [Icons.close, Icons.check],
                                  onToggle: (value) {
                                    _saveDataToServerLocation(_email,
                                        'user_global', value.toString());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                            'Going global allows you to see people nearby and from around the world.',
                            style:TextStyle(fontSize: 17.0, color: Colors.grey, fontFamily: 'Courier',  fontWeight: FontWeight.w600)),
                        SizedBox(width: 10.0, height: 10.0),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Maximum Distance', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700),),
                                RangeSlider(
                                  values: _currentRangeValues,
                                  min: 0,
                                  max: 160,
                                  divisions: 160,
                                  labels: RangeLabels(
                                    _currentRangeValues.start.round().toString(),
                                    _currentRangeValues.end.round().toString(),
                                  ),
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      _currentRangeValues = values;
                                      int va = _currentRangeValues.end.round() - _currentRangeValues.start.round();
                                      _saveDataToServerLocation(_email, 'user_distance_preference', va.toString());
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0, height: 10.0),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Show me', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                                ToggleSwitch(
                                  initialLabelIndex: _changeGendertoIndex(
                                      snapshot.data['user_interested_in']  ),
                                  minWidth: 80.0,
                                  cornerRadius: 20.0,
                                  activeBgColor: Colors.cyan,
                                  activeFgColor: Colors.white,
                                  inactiveBgColor: Colors.grey,
                                  inactiveFgColor: Colors.white,
                                  labels: ['Men', 'Women', 'Everyone'],
                                  // icons: [Icons.close, Icons.check],
                                  onToggle: (value) {
                                    var ugender;
                                    if (value == 0) ugender = 'Men';
                                    if (value == 1) ugender = 'Women';
                                    if (value == 2) ugender = 'Everyone';
                                    _saveDataToServerLocation(
                                        _email, 'user_interested_in', ugender);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0, height: 10.0),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('Age Range', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                                    Text("${_currentRangeValuesage.start.round()} - ${_currentRangeValuesage.end.round()}"),                                    
                                  ],
                                ),
                                RangeSlider(
                                      values: _currentRangeValuesage,
                                      min: 18,
                                      max: 70,
                                      divisions: 52,
                                      labels: RangeLabels(
                                        _currentRangeValuesage.start.round().toString(),
                                        _currentRangeValuesage.end.round().toString(),
                                      ),
                                      onChanged: (RangeValues values) {
                                        setState(() {
                                          _currentRangeValuesage = values;
                                        });
                                          String va = "${_currentRangeValuesage.start.round()} - ${_currentRangeValuesage.end.round()}";
                                          _saveDataToServerLocation(_email, 'user_pref_age_range', va);
                                      },
                                    ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0, height: 10.0),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Swipe Freaks', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                                ToggleSwitch(
                                  initialLabelIndex:int.parse(snapshot.data['user_swife_surge']),
                                  minWidth: 80.0,
                                  cornerRadius: 20.0,
                                  activeBgColor: Colors.cyan,
                                  activeFgColor: Colors.white,
                                  inactiveBgColor: Colors.grey,
                                  inactiveFgColor: Colors.white,
                                  labels: ['YES', 'NO'],
                                  icons: [Icons.check, Icons.close],
                                  onToggle: (value) {
                                    _saveDataToServerLocation(_email,'user_swife_surge', value.toString());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                            'Marking as No will prevent you from appearing for swiping to other users.',
                            style:TextStyle(fontSize: 17.0, color: Colors.grey, fontFamily: 'Courier',  fontWeight: FontWeight.w600)),
                        SizedBox(width: 10.0, height: 10.0),
                        Text('Contact Us',
                            style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),

                            child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextAnchor(
                                      textColor: Colors.black54,
                                      linkColor: Colors.pink,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18.0,
                                      text: ''' (Help & Support)[https://we-freak.com/contact-us].
                                            ''',
                                      onTapLink: (link) {
                                          UrlLauncher(link).launchUrl();
                                      },
                                    ),
                                    Text(''),
                                  ],

                                ),
                          ),
                        ),
                        SizedBox(width: 10.0, height: 10.0),
                        Text('Community',
                            style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget> [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextAnchor(
                                        textColor: Colors.black54,
                                        linkColor: Colors.pink,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 18.0,
                                        text: ''' (Community Guidelines)[https://we-freak.com/index/community].
                                              ''',
                                        onTapLink: (link) {
                                            UrlLauncher(link).launchUrl();
                                        },
                                    ),
                                    Text(''),
                                  ],

                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextAnchor(
                                      textColor: Colors.black54,
                                      linkColor: Colors.pink,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18.0,
                                      text: ''' (Safety Tips)[https://we-freak.com/index/safety-tips].
                                            ''',
                                      onTapLink: (link) {
                                          UrlLauncher(link).launchUrl();
                                      },
                                  ),
                                    Text(''),
                                  ],

                                ),
                              ],
                            ),
                          ),
                        ),
                        Text('Legal',
                            style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),

                            child:  Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextAnchor(
                                      textColor: Colors.black54,
                                      linkColor: Colors.pink,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 17.0,
                                      text: ''' (Privacy Policy)[https://we-freak.com/index/privacy].
                                            ''',
                                      onTapLink: (link) {
                                          UrlLauncher(link).launchUrl();
                                      },
                                    ),
                                     TextAnchor(
                                      textColor: Colors.black54,
                                      linkColor: Colors.pink,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 17.0,
                                      text: ''' (Terms & Conditions)[https://we-freak.com/index/terms].
                                            ''',
                                      onTapLink: (link) {
                                          UrlLauncher(link).launchUrl();
                                      },
                                    ),
                                  ],

                                ),
                          ),
                        ),
                        SizedBox(width: 10.0, height: 10.0),
                        Card(
                          
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: FlatButton(
                              child: Text('Show About WeFreak and Licences', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700)),
                              onPressed: () {
                                showAboutDialog(
                                  context: context,
                                  applicationIcon: Image.network('https://we-freak.com/public/assets/system/ic_launcher.png'),
                                  applicationName: 'WeFreak',
                                  applicationVersion: '1.1.0',
                                  applicationLegalese: '©2021 we-freak.com | EZE II',
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 15),
                                      child: Text('Built by Carlpha.com')
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0, height: 10.0),                        

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
