import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/dbqueries.dart';



class CheckLogin extends StatefulWidget {
  @override
  _CheckLoginState createState() => _CheckLoginState();   
}

class _CheckLoginState extends State<CheckLogin> {  

   // fetch data from session
  _fetchDataFromSession() async {
    dynamic email = await FlutterSession().get("email");

    if ((email == null) || (email == 'null')) {       
       Navigator.pushReplacementNamed(context, '/login'); //the user should login
    } else {
      DbQueries('userlogsintoday', {'email': email}).voidQuery();  
      Navigator.pushReplacementNamed(context, '/'); // the user logs in
    }
  }

  @override
  void initState() {
    super.initState();
     _fetchDataFromSession();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        //  margin: EdgeInsets.all(25.0),
          
            child: Loader().spinLoader(),
           // child: Draggable(child: null, feedback: null),
        
        ),
      
    );
  }
}