import 'package:flutter/material.dart';
import 'package:WeFreak/chats/Global/Colors.dart' as MyColors;
import 'package:WeFreak/chats/Global/Settings.dart' as Settings;
import 'package:WeFreak/chats/Widget/ReceivedMessageWidget.dart';
import 'package:WeFreak/chats/Widget/SendedMessageWidget.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:WeFreak/includes/validatesession.dart';

class ChatPageView extends StatefulWidget {
  final String username;

  const ChatPageView({
    Key key,
    this.username,
  }) : super(key: key);

  @override
  _ChatPageViewState createState() => _ChatPageViewState();
}

class _ChatPageViewState extends State<ChatPageView> {

  TextEditingController _text = TextEditingController();
  ScrollController _scrollController = ScrollController();
  var childList = <Widget>[];
  dynamic _email;
  dynamic _theyEmail;
  var _id;

  _getTheChats(_email, _theyEmail) async {
    var data = await DbQueries('chatting_with_who', {'email':_email, 'they_email': _theyEmail}).query();
    return data;
  }
  // ensure the user is logged in
  _validateLogin() async {
      ValidateSession(context).valSession();
      var email = await ValidateSession(context).returnEmail();
      setState(() => _email = email);
  }
  _sendTextChat(_theyEmail, _id) async {
    var _message = _text.text;
    // send to server
    DbQueries('chatting_func', {'email':_email, 'they_email': _theyEmail, 'message': _message}).query();

    // push to ui
    childList.add(Align(
      alignment: Alignment(1, 0),
      child: SendedMessageWidget(
        content: _message,
        time: 'now',
        isImage: false,
      ),
    ));

    var _newMessages = await DbQueries('newlymessages', {'email':_email, 'they_email': _theyEmail, 'message': _message, 'id': _id}).query();
    
      for(int i = 0; i < _newMessages.length; i++) {

        if ((_newMessages.length - 1) == i ) {
          //_id = _newMessages[i]['um_ID'];
          setState(() => _id = _newMessages[i]['um_ID']);
        }
        childList.add(Align(
          alignment: Alignment(-1, 0),
          child: ReceivedMessageWidget(
            content: _newMessages[i]['um_message'],
            time: '',
            isImage: false,
          ),
        ));
      }
  }

  _initialChat() async {

    _theyEmail = await ValidateSession(context).getAValueInSession('person_chatted');
    _email = await ValidateSession(context).returnEmail();
    var _userData = await DbQueries('get_onetoone_chats', {'email':_email, 'they_email': _theyEmail}).query();
     if (_userData == null) {
      childList.add(Align(
        alignment: Alignment(1, 0),
        child: SendedMessageWidget(
          content: 'Hey! Send your match a welcome message. They are waiting!',
          time: '',
          isImage: false,
        ),
      ));
    } else {
      for(int i = 0; i < _userData.length; i++) {

        if ((_userData.length - 1) == i ) {
          //_id = _userData[i]['um_ID'];
          setState(() => _id = _userData[i]['um_ID']);
        }

        if (_email == _userData[i]['um_my_email']) {
          childList.add(Align(
            alignment: Alignment(1, 0),
            child: SendedMessageWidget(
              content: _userData[i]['um_message'],
              time: '',
              isImage: false,
            ),
          ));
        } else {
          childList.add(Align(
            alignment: Alignment(-1, 0),
            child: ReceivedMessageWidget(
              content: _userData[i]['um_message'],
              time: '',
              isImage: false,
            ),
          ));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _validateLogin();
    _initialChat();

  }

  @override
  Widget build(BuildContext context) {
    
     Map _emailMap = ModalRoute.of(context).settings.arguments;
      var _list =  _emailMap.values.toList();
      dynamic _theyEmail = _list[0];
     // _initialChat(_email, _theyEmail);
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            fit: StackFit.loose,
            children: <Widget>[
              FutureBuilder(
                future: _getTheChats(_email, _theyEmail),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.start,
                          // mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            SizedBox(
                              height: 65,
                              child: Container(
                                color: Colors.pink[300],
                                // color: Settings.isDarkMode
                                //     ? Colors.pink
                                //     : MyColors.pink,
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          widget.username ?? snapshot.data['user_names'],
                                          softWrap: true,
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 15,
                                              fontFamily: 'Courier',  fontWeight: FontWeight.w600),
                                        ),
                                        /*Text(
                                          "online",
                                          style: TextStyle(
                                              color: Colors.white60, fontSize: 12),
                                        ),*/
                                      ],
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                      child: Container(
                                        child: ClipRRect(
                                          child: Container(
                                              child: SizedBox(
                                                child: Image.network(snapshot.data['user_dp'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              color: MyColors.orange),
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        height: 55,
                                        width: 55,
                                        padding: const EdgeInsets.all(0.0),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5.0,
                                                  spreadRadius: -1,
                                                  offset: Offset(0.0, 5.0))
                                            ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.black54,
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "https://we-freak.com/public/assets/system/chat-background-1.jpg"),
                                      fit: BoxFit.cover,
                                      colorFilter: Settings.isDarkMode
                                          ? ColorFilter.mode(
                                              Colors.grey[850], BlendMode.hardLight)
                                          : ColorFilter.linearToSrgbGamma()),
                                ),
                                child: SingleChildScrollView(
                                    controller: _scrollController,
                                    //reverse: true,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: childList,
                                     // childList,
                                    )),
                              ),
                            ),
                            Divider(height: 0, color: Colors.black26),
                            Container(
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextField(
                                  maxLines: 20,
                                  controller: _text,
                                  decoration: InputDecoration(
                                    suffixIcon: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.send),
                                          onPressed: () {
                                            _text.clear();
                                            _sendTextChat(_theyEmail, _id);

                                          },
                                        ),
                                        // IconButton(
                                        //   icon: Icon(Icons.image),
                                        //   onPressed: () {},
                                        // ),
                                      ],
                                    ),
                                    border: InputBorder.none,
                                    hintText: "Enter your message",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );

                    
                } else return Center(child:Text('An error occurred! Please contact us.'),);                  

                  } else return Loader().spinLoader();

                }
              ),

            ],
          ),
        ),
      ),
    );
  }
}
