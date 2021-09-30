import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:geolocator/geolocator.dart';
import 'package:age/age.dart';

import 'package:WeFreak/cards/cards.dart';
import 'package:WeFreak/cards/matches.dart';
import 'package:WeFreak/cards/profiles.dart';
import 'package:WeFreak/cards/photos.dart';


class NewHome extends StatefulWidget {
  @override
  _NewHomeState createState() => _NewHomeState();
}
class _NewHomeState extends State<NewHome> {
  // vars
  String _email;
  final List<Map<String, dynamic>> _usersList = [  {'value': '','label': 'Wait for list' }];
  Widget _backg = Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Loader().spinLoaderRippleLarge(),
        //Image.network('https://we-freak.com/public/assets/system/love.jpg', repeat: ImageRepeat.repeat),
      );
  Widget _backg2 = Container(
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Loader().spinLoaderRippleLarge(),
    //Image.network('https://we-freak.com/public/assets/system/broken-heart.jpg', repeat: ImageRepeat.repeat),
  );
    Widget _cardslist(int length) {
      if ((_usersList.length == 0) )
        return Container(
          child: Loader().spinLoaderRippleLarge(),
        );

      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        itemCount: _usersList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: _row(context, index, _usersList.length),
          );
        },
      );
    }
    _removeUser(index) {
      setState(() => _usersList.removeAt(index) );
    }
    _showSnackBar(context, Widget _snack, _row, _usersList, index) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
        content: _snack,
        backgroundColor: Colors.grey[400],
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'REWIND',
          onPressed: () { 
            _rewind(_row, index); 
          },
        ),
      ));
    }

    String _clipText(String _text, int _number) {
      if (_text.isEmpty) {
        return '';
      }
     // return _text.substring(0, _number);
      var _arr = _text.split(' ');
      String _return;
      _return = '';
      for (int i = 0; i < _number; i++) {
        if (i < _arr.length ) {
          if (i == (_number - 1)) {
            _return += _arr[i] + '...';
          } else _return += _arr[i] + ' ';

          if (i == (_number - 1) ) break;
        }
      }
      return _return;
    }
    _superLike(_email) async {
    
      dynamic _myEmail = await ValidateSession("context").getAValueInSession('email'); //email
      var _feedback = await DbQueries('beforesuperlike', {'they_email': '$_email', 'decision': 'SuperLike', 'email': _myEmail}).query();
  
      if (_feedback == 'sp-null' || _feedback == 'sp-used') {
        ValidateSession('context').setSession('pleasepay', '$_feedback');        
        Navigator.pushNamed(context, '/paynow' );
      } else {
        return 'okay';
      }
      
  }
  
  void _nope(_email) async {
      dynamic _myEmail = await ValidateSession("context").getAValueInSession('email'); //its an email
      DbQueries('reject_a_person', {'they_email': '$_email', 'decision': 'Nope', 'email': _myEmail}).voidQuery();
  }
  
  void _like(_email) async {
      dynamic _myEmail = await ValidateSession("context").getAValueInSession('userID'); //email
      DbQueries('like_a_person', {'they_email': '$_email', 'decision': 'Like', 'email': _myEmail}).voidQuery();
    
  } 
    Widget _row(context, index, length) {
        if ((index == null) || (index == length) || (index == null))
          return Container(
            child: Column (
              children: <Widget> [
                // SizedBox(height: 60.0),    
                Loader().spinLoaderRippleLarge(),
                Text('No one new around you!', style: TextStyle(color: Colors.black,
                fontFamily: 'Courier',  fontWeight: FontWeight.w800
                ),),
              ],
            ),
          );
      
      return Dismissible(
        key: Key(UniqueKey().toString()),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {

            var __text = (_usersList[index]['name'] + ' PASSED').toUpperCase();
            Widget _text = Text(__text, style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.w900, fontSize: 22 ) );
            _nope(_usersList[index]['email']);
            _showSnackBar(context, _text, _usersList[index], _usersList, index);
          } else if (direction == DismissDirection.startToEnd) {
            var __text = (_usersList[index]['name'] + ' LIKED').toUpperCase();
            Widget _text = Text(__text, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w900 , fontSize: 22) );
            _like(_usersList[index]['email']);
            _showSnackBar(context, _text, _usersList[index], _usersList, index);
          }
          _removeUser(index);
        },
        background: _backg,
        secondaryBackground: _backg2,
        child: Card(
          elevation: 50,
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,//grey[300],
            border: Border.all(
              color: Colors.pink[100],
             // width: 1,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
              children: <Widget>[
                
                AspectRatio(
                  aspectRatio: 487 / 451,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter,
                        image: NetworkImage(_usersList[index]['dp']),
                      ),
                    ),
                  ),
                ),
                
              ListTile(
                  title:  Text(_usersList[index]['name'] + "\r\n" + 'Age: ${_usersList[index]['age']}' + "\r\n" + 'Distance: ${_usersList[index]['distance']}',
                  style:TextStyle(textBaseline: TextBaseline.alphabetic, fontSize: 17.0, fontFamily: 'Courier',  fontWeight: FontWeight.w500)),
                  subtitle: Text(''),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.favorite_rounded, color: Colors.blue),
                    tooltip: 'Superlike',
                    onPressed: () {
                      var __text = (_usersList[index]['name'] + ' SUPERLIKED').toUpperCase();
                      Widget _text = Text(__text, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w900 , fontSize: 22) );
                      if (_superLike(_usersList[index]['email']))
                      _showSnackBar(context, _text, _usersList[index], _usersList, index);
                      _removeUser(index);
                    },
                    ),
                    onTap: () {
                      Map _mapBody = {'userEmail': _usersList[index]['email'], 'name': _usersList[index]['name'], 'distance': _usersList[index]['distance'], 'age': _usersList[index]['age']};
                      Navigator.pushNamed(context, '/viewuser', arguments: _mapBody);
                    },
                ),
              
              _usersList[index]['bio'] == '' ? Container() :
              Container(child: Text('Bio: ' + _clipText(_usersList[index]['bio'], 12),style:TextStyle(textBaseline: TextBaseline.alphabetic, fontSize: 17.0, fontFamily: 'Courier',  fontWeight: FontWeight.w500) ),),
              _usersList[index]['city'] == '' ? Container() :
              Container(child: Text('Lives in ' + _usersList[index]['city'], textAlign: TextAlign.justify, style:TextStyle(fontSize: 17.0, fontFamily: 'Courier',  fontWeight: FontWeight.w500, color: Colors.pinkAccent ),), ),
              SizedBox(height: 4),
              _usersList[index]['interests'] == '' ? Container(child: Text(_usersList[index]['name'].split(' ')[0] + ' enjoys meeting new people and has been actively looking forward to engage', style:TextStyle(fontSize: 17.0, fontFamily: 'Courier',  fontWeight: FontWeight.w500))) :
              Container(child: Text(_clipText('Interested in ' + _usersList[index]['interests'], 12), style:TextStyle(fontSize: 17.0, fontFamily: 'Courier',  fontWeight: FontWeight.w500) )),
            ],
          ),
        ),
        ),
      );
    }
    _readyBody(_email) async {
      var loggedin = await DbQueries('individualuser', {'email': _email}).query();
      double _startlat = double.parse(loggedin['user_latitude']);
      double _startlong = double.parse(loggedin['user_longitude']);


      var _users = await DbQueries('getcardusers', {'email': _email}).query();
      if (_users == 'zero users') {        
      } else {
        _usersList.clear();
        for (int i = 0; i < _users.length; i++) {
          String _usersEmail = _users[i]['user_email'];
          String _usersName = _users[i]['user_names'] == null ? '' : _users[i]['user_names'] ;
          String _usersBio = _users[i]['user_about'] == null ? '' : _users[i]['user_names'] ;
          String _distance = '';
        double _endlat = double.parse(_users[i]['user_latitude']);
        double _endlong = double.parse(_users[i]['user_longitude']);

        if ( (loggedin['user_longitude'] == '') || (loggedin['user_latitude'] == '') || (_users[i]['user_longitude'] == '') || (_users[i]['user_latitude'] == '' ) ) {
        } else {
          double distanceInMeters = Geolocator.distanceBetween( _startlat, _startlong, _endlat, _endlong);
           _distance = (distanceInMeters / 1000).toStringAsFixed(0) + 'km';
        }
        int _age = int.parse(_users[i]['user_age']);
        String __age;
        __age = ( (_age > 90) || (_age < 1) ) ? '' : '$_age years';

          _usersList.add(
            {
              'email': _usersEmail,
              'name': _usersName,
              'bio': _usersBio,
              'distance': _distance,
              'dp': _users[i]['user_dp'],
              'age': __age,
              'city': _users[i]['user_city'] ?? '',
              'interests': _users[i]['user_passions'] ?? '',
            },
          );
        }
        
      }
      return _users;
    }
     _age(_birthday) {
    //   if (_birthday == '') {
    //     return '';
    //   } 
    //   // example 1992-11-16
       int _year = int.parse(_birthday.split('-')[0]);
      print("============== $_year ==================");
    //   int _month =  int.parse(_birthday.split('-')[2]);
    //   int _day =  int.parse(_birthday.split('-')[4]);
    _year = 1990;
      DateTime birthday = DateTime(_year, 12, 05);
      DateTime today = DateTime.now(); //
      AgeDuration _age;
      _age = Age.dateDifference(fromDate: birthday, toDate: today, includeToDate: false);
      return _age;
    }
     _rewind(_row, index) async {
      var _feedback = await DbQueries('rewindcards', {'email': _email}).query();
      print(_feedback);
      if ((_feedback == 'null') || (_feedback == 'used')) {
        ValidateSession('context').setSession('pleasepay', '$_feedback');
        Navigator.pushNamed(context, '/paynow');
      } else {
        setState(() {
          _usersList.insert(index, _row);
        });
      }

     }

  
   Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.home,
          color: Colors.pink,
          size: 30.0,
        ),
        onPressed: () {},
      ),
      title: Text(
        'WeFreak', style: TextStyle(color: Colors.pink, fontFamily: 'Courier',  fontWeight: FontWeight.w800),
    
      ),
    );
  }



  // ensure the user is logged in
  _validateLogin() async {
      ValidateSession sess = ValidateSession(context);
      sess.valSession(); // handles logging out if there is no session
      String email = await sess.returnEmail();
      setState(() => _email = email);
  }
  @override
  void initState() {
    super.initState();
    _validateLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),//_appbar(),
      body: Container(
        child: FutureBuilder(
             future: _readyBody(_email), 
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data != null) {   

                  if (snapshot.data == 'zero users') {
                    return Container(
                      child: Column(
                        children: <Widget> [
                         // SizedBox(height: 60.0),    
                          Loader().spinLoaderRippleLarge(),
                          Text('No one new around you!', style: TextStyle(color: Colors.black,
                          fontFamily: 'Courier',  fontWeight: FontWeight.w800
                          ),),
                        ],
                      ),
                    );
                  } else {
                    // display a list of dismissible users
                    return _cardslist(snapshot.data.length);
                  }
                } else {
                  return Container(
                    child: Column(
                      children: <Widget> [
                      //  SizedBox(height: 60.0),    
                        Loader().spinLoaderRippleLarge(),
                      ],
                    ),
                  );
                }
              }
        ),
      ),
      bottomNavigationBar: BottomNav().nav(0, context),
    );
  }
}
