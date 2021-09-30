import 'package:flutter/material.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:flutter/rendering.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/dbqueries.dart';

class Likes extends StatefulWidget {
  @override
  _LikesState createState() => _LikesState();
}

class _LikesState extends State<Likes> {
  // vars
  dynamic _email;
  dynamic _isPaid = false;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

   // check payment status
   _validatePayment() async {
     
     var email = await ValidateSession(context).returnEmail();
     var feedback = await DbQueries('subs_status', {'email': email}).query();
     setState(() {
       _isPaid = feedback['payment'];
     });
   }

  // ensure the user is logged in
  _validateLogin() async {
      ValidateSession(context).valSession();
      var email = await ValidateSession(context).returnEmail();
      setState(() => _email = email);
  }

  // get messages plus users 
  _getMatches(_email) async { 
    var resp = await DbQueries('matching_couples', {'email':_email}).query(); 
      return resp;
  }
    // get messages plus users 
  _getMyLikers(_email) async {
    var resp = await DbQueries('they_like_me', {'email':_email}).query();  
      return resp;
  }

  Widget _paidTexts() {
    var output;
    if (_isPaid == true)
      output = Padding(padding:EdgeInsets.all(12),child:Center(child:Text('Go ahead and send them love messages!', style: TextStyle(fontSize: 20),),));

    else output = Padding(padding:EdgeInsets.all(12),child:Center(child:Text('Upgrade to see people who have liked you!', style: TextStyle(fontSize: 20,
    fontFamily: 'Courier', fontWeight: FontWeight.w900
      ), ),));
    return output;
  }
 

  void _showError(dynamic error) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(error.toString())));
  }

  @override
  void initState() {
    super.initState();
    _validateLogin();
    _validatePayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
      appBar:  BottomNav().appBarPages('Likes', context),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('New Matches', style: TextStyle(fontSize: 20, 
            fontFamily: 'Courier',  fontWeight: FontWeight.w900
            ),
            ),
          ),
          
          // we are goung to have two sections
        // 1. section one are matching people        
          Expanded(
          // the first
          //should be endless scroll view across displaying rounded profile plus name
          child: FutureBuilder(
             future: _getMatches(_email), 
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {

                  if (snapshot.hasData) {
                    if (snapshot.data != 'none') {
                    return ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: <Widget> [
                        for (int i = 0; i < snapshot.data.length; i++)
                        Container(
                          child: Column(
                            children: <Widget> [
                              CircleAvatar(
                                radius: 30, 
                                backgroundImage: NetworkImage(snapshot.data[i]['user_dp']),
                              ),
                            
                              FlatButton(
                                onPressed: (){
                                  //print(snapshot.data[i]['user_email']);
                                  ValidateSession(context).setSession('person_chatted', snapshot.data[i]['user_email']);
                                  Navigator.pushNamed(context, '/chat', arguments: {'email': snapshot.data[i]['user_email']});
                                },
                                child: Text(snapshot.data[i]['user_names'].split(' ')[0], 
                                style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600)
                                ),
                              ),
                            
                            ],),
                        ),
                      ],
                    );
                  } else return Center(child:Text('No new matches',
                   style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600
                   ),),
                   );
                  } else return Center(child:Text('No new matches',
                   style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600)
                  ),
                  );                  

                } else return Loader().spinLoader();
              }
          ),
          ),

          Card(
            child: _paidTexts(),
          ),
          
          Expanded(
            // 2. section 2 are those who like us
            child: FutureBuilder(
             future: _getMyLikers(_email), 
              builder: (BuildContext context, AsyncSnapshot snapshot) {

                if (snapshot.connectionState == ConnectionState.done) {
                     if (snapshot.data != null) {
                        if (snapshot.data != 'none') {
                        return ListView(
                          shrinkWrap: true,
                          children: <Widget> [
                            for (int i = 0; i < snapshot.data.length; i++)
                            Card(
                              child: ListTile(
                                leading: Image.network((_isPaid == true ? snapshot.data[i]['user_dp'] : 'https://we-freak.com/public/assets/uploads/default_dp.jpg')),
                                title: Text(_isPaid == true ? snapshot.data[i]['user_names'] : 'Name hidden',
                                 style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600)),
                                onTap: () {
                                
                                  if (_isPaid == true) {
                                    ValidateSession(context).setSession('person_chatted', snapshot.data[i]['user_email']);
                                    Navigator.pushNamed(context, '/chat', arguments: {'email': snapshot.data[i]['user_email']});
                                  } else 
                                    Navigator.pushNamed(context, '/paynow');
                                },
                                ),
                            ),

                          ],                         
                        );
                      } else return Center(child:Text('No likes yet!',
                       style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600)),);  
                    } else return Center(child:Text('No likes yet!',
                       style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600)),); 

                } else  return Loader().spinLoader();

              }
            ),
          ),
        ],
      ),

        
        
      

       bottomNavigationBar: BottomNav().nav(1, context),
    );
  }
}