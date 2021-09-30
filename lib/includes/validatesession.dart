import 'package:flutter_session/flutter_session.dart';
import 'package:flutter/material.dart';
class ValidateSession {
  dynamic context;
  ValidateSession(this.context);

  valSession() async {
    dynamic email = await FlutterSession().get("email");
    if ((email == null) || (email == 'null')) Navigator.pushReplacementNamed(context, '/login');
  }

  returnEmail<String>() async {
    dynamic email = await FlutterSession().get("email");
    if (email != null) return email; 
  }

  void setSession(String name, value) {
     FlutterSession().set("$name", value);
  }
  getAValueInSession(String sessionName) async {
    dynamic sessionValue = await FlutterSession().get(sessionName);
    if (sessionValue != null) return sessionValue; 
    return 00;
  }
  // end of class  
}