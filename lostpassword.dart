import 'package:flutter/material.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:WeFreak/includes/toastmessage.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'dart:math';

class LostPassword extends StatefulWidget {
  @override
  _LostPasswordState createState() => _LostPasswordState();
}

class _LostPasswordState extends State<LostPassword> {
  TextEditingController _phoneController = TextEditingController();
  double _resetNumber;
  bool _enterPhone = true;
  String _message = '';

  _submitPhone() {
    String _secureNo = (Random().nextInt(9).toString()) + (Random().nextInt(9).toString()) + (Random().nextInt(9).toString()) + (Random().nextInt(9).toString()) + (Random().nextInt(9).toString()) + (Random().nextInt(9).toString());
    DbQueries('sendOTP', {'tel': _phoneController.text, 'otp': _secureNo}).voidQuery();

    setState(() {
      _resetNumber = double.parse(_secureNo);
      _enterPhone = false;
    });
  }

  _resetPhone(_fromCustomer) async {

    if (_resetNumber == double.parse(_fromCustomer)) {
      var _feedback = await DbQueries('lostpassword', {'tel': _phoneController.text}).query();

      if (_feedback == 'Error') ToastMessage('No user with this phone number found.').showMessageError();
      else {
        //logg the user in
        ValidateSession('context').setSession('email', _feedback['user_email']);
        Navigator.pushReplacementNamed(context, '/');
      }
    } else ToastMessage('Incorrect OTP!').showMessageError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  BottomNav().appBarPages('Lost Password', context),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: _enterPhone == true ? Column(
          children: <Widget> [
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                icon: Icon(Icons.phone),
                hintText: 'Telephone *',
                labelText: 'Write your telephone number to reset password',
              ),
              onChanged: (String value) {
                 if (value.length == 12) {
                  
                 } else {
                   setState(() => _message = 'Your phone should between 10 to 12 characters eg: 254706031920 or 0706031920' );
                 }
              },
              validator: (String value) {
                return value.isEmpty ? 'Your name is required' : null;
              },
            ),
            RaisedButton(
              onPressed: () {
              if (_phoneController.text != '') {
                  _submitPhone();
              }
              },
              child: Text('Submit'),
            ),

            SizedBox(width: 10.0, height: 20.0), 
            Container(
              child: Text(_message, style: TextStyle(color: Colors.red, fontFamily: 'Courier',  fontWeight: FontWeight.w800),),
            ),
          ],
          )
          : Container(
            child: TextFormField(
              //maxLengthEnforced: true,
              //initialValue: snapshot.data['user_gender'],
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,   
                icon: Icon(Icons.star),
                hintText: 'OTP*',
                labelText: 'Enter the OTP sent to your phone',                             
              ),
              onChanged: (String value) {
                if (value.length == 6) {
                  _resetPhone(value);
                } else if (value.length > 6) {
                  ToastMessage('Must be six characters!').showMessageError();
                }
              },
            ),
          ),
      ),
    );
  }
}