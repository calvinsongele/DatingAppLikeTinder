import 'package:flutter/material.dart';
import 'package:WeFreak/chats/Global/Colors.dart' as MyColors;
import 'package:WeFreak/chats/Widget/ChatListViewItem.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/chats/Global/Settings.dart' as Settings;
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:WeFreak/includes/validatesession.dart';

class ChatListPageView extends StatefulWidget {
  @override
  _ChatListPageViewState createState() => _ChatListPageViewState();
}

class _ChatListPageViewState extends State<ChatListPageView> {
   dynamic _email;

  _getChatListUsers(_email) async {
    return await DbQueries('get_messages', {'email': _email}).query();
  }
  // ensure the user is logged in
  _validateLogin() async {
    await ValidateSession(context).valSession();
    var email = await ValidateSession(context).returnEmail();
    setState(() => _email = email);
  }

  @override
  void initState() {
    super.initState();
    _validateLogin();
  }

  @override
  Widget build(BuildContext context) {
   
      return Container(
          decoration: BoxDecoration(
            color: Settings.isDarkMode
                ? MyColors.darkBackGround
                : MyColors.backGround,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
          ),
          child: FutureBuilder(
            future: _getChatListUsers(_email),
            builder: (BuildContext context, AsyncSnapshot snapshot) {

              //if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  return ListView(
                    children: <Widget>[
                      for (int i = 0; i < snapshot.data.length; i++) 
                        ChatListViewItem(
                          hasUnreadMessage: false,
                          image: NetworkImage(snapshot.data[i]['user_dp']),
                          lastMessage: snapshot.data[i]['um_message'],
                          name: snapshot.data[i]['user_names'],
                          newMesssageCount: 0,
                          time: "",
                          email: snapshot.data[i]['um_they_email'], 
                        ),
                    ],
                  );
                  
              //   } else {
              //   return Center(child: Padding(
              //     padding: EdgeInsets.all(12),
              //     child: Text('No chats currently! Continue swiping to find your match.',
              //   style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600),
              //   ),),);
              // }
              } else return Loader().spinLoader();
            }
        ),
      );
  }
}
