import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:WeFreak/cards/photos.dart';


class NewHome extends StatefulWidget {
  @override
  _NewHomeState createState() => _NewHomeState();
}
class _NewHomeState extends State<NewHome> {
  // vars
  bool _usersTrue = true;  
  String _email;
  //List <dynamic> _usersList = List();
  final List<Map<String, dynamic>> _usersList = [  {'value': '','label': 'Wait for list' }];
  Widget _backg = Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.pinkAccent
        //child: Icon(Icons.favorite_rounded, color: Colors.black),
      );
  Widget _buildBackground(_photo) {  
    return PhotoBrowser(
      photoAssetPaths: [_photo], //_thisUser["user_dp"], //widget.profile.photos,
      visiblePhotoIndex: 0,
    );
  }
 Widget _buildProfileSynopsis(name, bio, userEmail, _distance) {
    Map _mapBody = {'userEmail': userEmail, 'name': name, 'distance': _distance};
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ])
            ),
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
           Expanded(
              child: Column(
               // crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/viewuser', arguments: _mapBody);
                    },
                    child: Text((name + ' $_distance' + 'km'), textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 21.0,
                    fontFamily: 'Courier',  fontWeight: FontWeight.w900),),
                  ),
                 Text(bio,
                      style: TextStyle(color: Colors.white, fontSize: 17.0,
                      fontFamily: 'Courier',  fontWeight: FontWeight.w600))
                ],
              ),
            ),
          //  Icon(
          //     Icons.info,
          //     color: Colors.white,
          //   )
          ],
        ),
      ),
    );
  }
    Widget _cardslist(int length) {
      return ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: length,
        itemBuilder: (BuildContext context, int index) {
          return _row(context, index);
        },
      );
    }
    _removeUser(index) {
      _usersList.remove(index);
    }
    _showSnackBar(context, Widget _snack, index, _usersList) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
        content: _snack,
        backgroundColor: Colors.grey[400],
        duration: Duration(seconds: 2),
        // action: SnackBarAction(
        //   label: 'REWIND',
        //   onPressed: () { _rewind(index, _usersList); 
        //   },
        // ),
      ));
    }

    Widget _row(context, index) {
      
      return Dismissible(
        key: Key(_usersList[index]['email']), //_usersList[index].toString()),
        dragStartBehavior: DragStartBehavior.down,
        onDismissed: (direction) {
          //print(direction); // endToStart // startToEnd
          if (direction == DismissDirection.endToStart) {

            var __text = (_usersList[index]['name'] + ' PASSED').toUpperCase();
            Widget _text = Text(__text, style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.w900, fontSize: 22 ) );
            _showSnackBar(context, _text, _usersList[index], _usersList);
          } else if (direction == DismissDirection.startToEnd) {
            var __text = (_usersList[index]['name'] + ' LIKED').toUpperCase();
            Widget _text = Text(__text, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w900 , fontSize: 22) );
            _showSnackBar(context, _text, _usersList[index], _usersList);
          }
          _removeUser(_usersList[index]);
        },
        background: _backg,
        child: Container(
          height: MediaQuery.of(context).size.width * 0.80,
        child: Column(
              children: <Widget>[
                
                AspectRatio(
                  aspectRatio: 5 / 4,
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
                
              Container(
                child: ListTile(
                  leading: Image.network(_usersList[index]['dp']),
                  title:  Text(_usersList[index]['name'] + ' ${_usersList[index]['distance']} km'),
                  subtitle: Text(_usersList[index]['bio']),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.favorite_rounded, color: Colors.blue),
                    tooltip: 'Superlike',
                    onPressed: (){},
                    ),
                    onTap: () {
                      Map _mapBody = {'userEmail': _usersList[index]['email'], 'name': _usersList[index]['name'], 'distance': _usersList[index]['distance']};
                      Navigator.pushNamed(context, '/viewuser', arguments: _mapBody);
                    },
                ),
              ),
                // _buildBackground(_usersList[index]['dp']),
                // _buildProfileSynopsis(_usersList[index]['name'].trim(), _usersList[index]['bio'], _usersList[index]['email'], '${_usersList[index]['distance']} km'),
            ],
          ),
        ),
      );
      // return Dismissible(
      //   key: Key(_usersList[index]['email']), //_usersList[index].toString()),
      //   dragStartBehavior: DragStartBehavior.down,
      //   onDismissed: (direction) {
      //     //print(direction); // endToStart // startToEnd
      //     if (direction == DismissDirection.endToStart) {

      //       var __text = (_usersList[index]['name'] + ' PASSED').toUpperCase();
      //       Widget _text = Text(__text, style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.w900, fontSize: 22 ) );
      //       _showSnackBar(context, _text, _usersList[index], _usersList);
      //     } else if (direction == DismissDirection.startToEnd) {
      //       var __text = (_usersList[index]['name'] + ' LIKED').toUpperCase();
      //       Widget _text = Text(__text, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w900 , fontSize: 22) );
      //       _showSnackBar(context, _text, _usersList[index], _usersList);
      //     }
      //     _removeUser(_usersList[index]);
      //   },
      //   background: _backg,
      //   child: Card(
      //     child: ListTile(
      //       leading: Image.network(_usersList[index]['dp']),
      //       title:  Text(_usersList[index]['name'] + ' ${_usersList[index]['distance']} km'),
      //       subtitle: Text(_usersList[index]['bio']),
      //       isThreeLine: true,
      //       trailing: IconButton(
      //         icon: Icon(Icons.favorite_rounded, color: Colors.blue),
      //         tooltip: 'Superlike',
      //         onPressed: (){},
      //         ),
      //         onTap: () {
      //           Map _mapBody = {'userEmail': _usersList[index]['email'], 'name': _usersList[index]['name'], 'distance': _usersList[index]['distance']};
      //            Navigator.pushNamed(context, '/viewuser', arguments: _mapBody);
      //         },
      //     ),
      //   ),

      // );
    }

    _readyBody() async {
      var _users = await DbQueries('getcardusers', {'email': _email}).query();
      if (_users == 'zero users') {        
         setState(() => _usersTrue = false);
      } else {
        _usersList.clear();
        for (int i = 0; i < _users.length; i++) {
          String _usersEmail = _users[i]['user_email'];
          String _usersName = _users[i]['user_names'] == null ? 'Nameless' : _users[i]['user_names'];
          String _usersBio = _users[i]['user_about'] == null ? ' ' : _users[i]['user_about'];
          String _distance = '22'; //((_users[i]['user_temp_dist'].toString()) == null) ? ' ' : (_users[i]['user_temp_dist'].toString());
          _usersList.add(
            {
              'email': _usersEmail,
              'name': _usersName,
              'bio': _usersBio,
              'distance': _distance,
              'dp': _users[i]['user_dp'],
            },
          );
        }
        
      }
      return _users;
    }
     _rewind(index, _usersList) async {
        setState(() {
          _usersList.insert(index);
        });
      // var _feedback = await DbQueries('rewindcards', {'email': _email}).query();
      // if ((_feedback == 'null') || (_feedback == 'used')) {
      //   ValidateSession('context').setSession('pleasepay', '$_feedback');
      //   Navigator.pushNamed(context, '/paynow');
      // } else {
      //   setState(() {
      //     _usersList.insert(index);
      //   });
      // }

     }

  
   Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.home,
          color: Colors.grey,
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
             future: _readyBody(), 
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data != null) {   

                  if (snapshot.data == 'zero users') {
                    return Container(
                      child: Column(
                        children: <Widget> [
                          SizedBox(height: 60.0),    
                          Loader().spinLoaderRippleLarge(),
                          Text('No one new around you!', style: TextStyle(color: Colors.black,
                          fontFamily: 'Courier',  fontWeight: FontWeight.w800
                          ),),
                        ],
                      ),
                    );
                  } else {
                    _usersTrue = true;
                    // display a list of dismissible users
                    return _cardslist(snapshot.data.length);
                  }
                } else {
                  return Container(
                    child: Column(
                      children: <Widget> [
                        SizedBox(height: 60.0),    
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
