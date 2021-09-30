import 'package:flutter/material.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:WeFreak/includes/toastmessage.dart';

class ViewUser extends StatefulWidget {
  @override
  _ViewUserState createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  String _theyEmail;
  String _name;
  Widget _reportUserWidget = Container();
  TextEditingController _reportReason = TextEditingController();


  _getThisUser() async {
    return await DbQueries('getuserdata', {'email':_theyEmail}).query(); 
  }

   _submitReason() async {
     String _reason = _reportReason.text;
     if (_reason.isNotEmpty) {
      var response = await DbQueries('reportuser', {'email':_theyEmail, 'reason': '$_reason'}).query(); 
      ToastMessage(response).showMessageSuccess();
     }
   }
  
  _widgetReportUser() {
    setState((){
      _reportUserWidget = Container(
        child: Column(
          children: <Widget> [
            TextFormField(
            controller: _reportReason,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              icon: Icon(Icons.warning),
              hintText: 'Reason',
              labelText: 'Why are you reporting this user? *',
            ),
            onSaved: (String value) {
              // This optional block of code can be used to run
              // code when the user saves the form.
            },
            validator: (String value) {
              return value.isEmpty ? 'Your reason is required' : null;
            },
          ),
          RaisedButton(
            onPressed: () {_submitReason();},
            child: Text('Submit'),
          ),

          ],
        ),
      );
    });
    
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // receive the email    
    Map _emailMap = ModalRoute.of(context).settings.arguments;
    var _list =  _emailMap.values.toList();
    _theyEmail = _list[0];
    _name = _list[1];
    String _distance = _emailMap['distance']; 
    String _age = _emailMap['age'];

    return Scaffold(
      appBar:  BottomNav().appBarPages('View ' + _name, context),
      body: Container(
        child: FutureBuilder(
          future: _getThisUser(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {

             if (snapshot.data == null) {
                  return Loader().spinLoader();
                } else {
                 String _passions = snapshot.data['user_passions'] == null ? '' : snapshot.data['user_passions'];
                 String _bio = snapshot.data['user_about'] == null ? '' : snapshot.data['user_about'];
                  return SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget> [
                            Center(
                              child: 
                                AspectRatio(
                                  aspectRatio: 487 / 451,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        alignment: FractionalOffset.topCenter,
                                        image: NetworkImage(snapshot.data['user_dp']),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(_name + ' ' + _age + ' , $_distance', 
                                style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800),),
                              ),
                            ),
                            _passions.isEmpty ? Container() :
                            Text('Interests', textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                            _passions.isEmpty ? Container() :
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(_passions, style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600)),
                              ),
                            ),
                            _bio.isEmpty ? Container() :
                            Text('Bio', textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Courier', )),
                            _bio.isEmpty ? Container() :
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(_bio, style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600)),
                              ),
                            ),
                            SizedBox(height: 15),
                             Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: RaisedButton(
                                  onPressed: () {_widgetReportUser();
                                  },
                                  child: Text('Report $_name', style: TextStyle(color: Colors.red, fontFamily: 'Courier',  fontWeight: FontWeight.w600),),
                                  ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Card(
                              child: Padding(padding: EdgeInsets.all(6), child: _reportUserWidget,),
                            ),
                          
                        ],
                      ),
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