import 'package:flutter/material.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/bottomnav.dart';

import 'package:WeFreak/cards/cards.dart';
import 'package:WeFreak/cards/matches.dart';
import 'package:WeFreak/cards/profiles.dart';
import 'package:WeFreak/includes/validatesession.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {
  // vars
  bool _usersTrue = true;  
  String _email;
  
   MatchEngine matchEngine = MatchEngine(
      matches: profileCardsList.map(
        (Profile profile) {
            return Match(profile: profile);
    }).toList());

    _readyBody() async {
      var _user = await DbQueries('getcardusers', {'email': _email}).query();
      if (_user == 'zero users') {        
         setState(() => _usersTrue = false);
      }
      return _user;
    }
     _rewind() async {
      var _feedback = await DbQueries('rewindcards', {'email': _email}).query();
      

      if (_feedback == 'null' || _feedback == 'used') {
        ValidateSession('context').setSession('pleasepay', '$_feedback');
        Navigator.pushReplacementNamed(context, '/paynow');
      } else {
        Navigator.pushReplacementNamed(context, '/viewuser', arguments: _feedback);
      }

     }

    Widget _buildBottomBar(context) {
    return BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.orange),
                onPressed: () {
                  //rewind
                  _rewind();
                },
              ),
              IconButton(
                
                 icon: Icon(Icons.clear, color: Colors.red),
                onPressed: () {                  
                  matchEngine.currentMatch.nope(_email);
                },
              ),
              IconButton(
                 icon: Icon(Icons.star, color: Colors.blue),
                onPressed: () {
                  matchEngine.currentMatch.superLike(context, _email);
                },
              ),
              IconButton(
                 icon: Icon(Icons.favorite, color: Colors.blue),
                onPressed: () {
                  matchEngine.currentMatch.like(_email);
                },
              ),
              // new IconButton(
              //    icon: Icon(Icons.lock, color: Colors.purple),
              //   onPressed: () {},
              // ),
            ],
          ),
        ));
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
        onPressed: () {
          Navigator.popAndPushNamed(context, '/');
        },
      ),
      title: Text(
        'WeFreak', style: TextStyle(color: Colors.pink, fontFamily: 'Courier',  fontWeight: FontWeight.w800),
    
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.star,
            color: Colors.grey,
            size: 25.0,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/likes');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.chat_bubble,
            color: Colors.grey,
            size: 25.0,
          ),
          onPressed: () {
           Navigator.pushReplacementNamed(context, '/messages');
          },
        ),
         IconButton(
          icon: Icon(
            Icons.person,
            color: Colors.grey,
            size: 25.0,
          ),
          onPressed: () {
           Navigator.pushReplacementNamed(context, '/userprofile');
          },
        ),
      ],
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
                if (snapshot.connectionState == ConnectionState.done) {   

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
                    return CardStack(
                        matchEngine: matchEngine, contexty: context, globEmail: _email,
                        );
                  }
                } else {
                  return Container(
                    child: Column(
                      children: <Widget> [
                        SizedBox(height: 60.0),    
                        Loader().spinLoaderRippleLarge(),
                        Text('No one new around you!', style: TextStyle(color: Colors.black, fontFamily: 'Courier',  fontWeight: FontWeight.w800),),
                      ],
                    ),
                  );
                }
              }
        ),
      ),
      bottomNavigationBar: _usersTrue == true ? _buildBottomBar(context) : BottomNav().nav(0, context),
    );
  }
}
