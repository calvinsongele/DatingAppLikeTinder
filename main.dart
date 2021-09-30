import 'package:flutter/material.dart';
// pages and includes
import 'package:WeFreak/home.dart';
import 'package:WeFreak/login.dart';
import 'package:WeFreak/likes.dart';
import 'package:WeFreak/messages.dart';
import 'package:WeFreak/userprofile.dart';
import 'package:WeFreak/signup.dart';
import 'package:WeFreak/settings.dart';
import 'package:WeFreak/editinfo.dart';
import 'package:WeFreak/includes/upload.dart';
import 'package:WeFreak/includes/checklogin.dart';
import 'package:WeFreak/chats/View/ChatPageView.dart';
import 'package:WeFreak/paynow.dart'; 
import 'package:WeFreak/viewuser.dart';
import 'package:WeFreak/lostpassword.dart';
import 'package:WeFreak/home_2.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/checklogin',
  routes: {
   // '/': (context) => Home(),
    '/': (context) => NewHome(),
    '/login': (context) => Login(),
    '/likes': (context) => Likes(),
    '/messages': (context) => Messages(),
    '/userprofile': (context) => UserProfile(),
    '/signup': (context) => Signup(),
    '/info': (context) => EditInfo(),
    '/settings': (context) => Settings(),
    '/upload': (context) => Upload(),
    '/checklogin': (context) => CheckLogin(),
    '/chat': (context) => ChatPageView(),
    '/paynow': (context) => PayNow(), 
    '/viewuser': (context) => ViewUser(),
    '/lostpassword': (context) => LostPassword(),
  },
));


