
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
class ToastMessage {
  String _message;

  ToastMessage(this._message);

  showMessageSuccess() {
    Fluttertoast.showToast(
      msg: '$_message',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 25,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 24.0
    );
  }
   showMessageError() {
    Fluttertoast.showToast(
      msg: '$_message',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 25,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 24.0
    );
  }

  
}