import 'package:flutter/material.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:flutter/services.dart';
import 'package:WeFreak/chats/View/ChatListPageView.dart';
import 'package:WeFreak/chats/Global/Settings.dart' as Settings;
//import 'package:WeFreak/chats/Global/Theme.dart' as Theme;

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

  // ensure the user is logged in
  _validateLogin() async {
      ValidateSession(context).valSession();
  }

  void _changeTheme() {
    setState(() {
      Settings.isDarkMode = Settings.isDarkMode ? false : true;
    });
    if (Settings.isDarkMode) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.grey[900],
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    Settings.changeTheme = _changeTheme;
    _validateLogin();
  }

  @override
  Widget build(BuildContext context) {
    /*return MaterialApp(
      title: 'WeFreak Chats',
      debugShowCheckedModeBanner: false,
      theme: Settings.isDarkMode ? Theme.darkTheme : Theme.lightTheme,
      home: ChatListPageView(),
      //bottomNavigationBar: bottomNav.nav(_currentIndex, context),
    );*/
    return Scaffold(
      appBar: BottomNav().appBarPages('Chats', context),
      body: ChatListPageView(),
       bottomNavigationBar: BottomNav().nav(2, context),
    );
  }
}
