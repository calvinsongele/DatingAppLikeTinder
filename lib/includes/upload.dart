import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:WeFreak/includes/bottomnav.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'dart:math';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  String status = '';
  File _file;
  String base64Image;
  String errorMessage = '';
  String _email;
  final picker = ImagePicker();
  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

   _validateLogin() async {
      ValidateSession sess = ValidateSession(context);
      sess.valSession();
      var email = await sess.returnEmail();
      setState(() => _email = email);
  }

  _chooseImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _file = File(pickedFile.path);
    });
    setStatus('');
  }
  Widget _showImage() {
    if (_file == null) {
      return Text('No image selected.', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),);
    } else {
      setState(() {
        base64Image = base64Encode(_file.readAsBytesSync());
      });
      return Flexible(
            child: Image.file(_file, 
            fit: BoxFit.fill),
          );
    }
  }
  setStatus(String message) {
    setState(() {
      status = message;
    });
  }
  _uploadImage() async {
     setStatus('Uploading image...');
    if (null == _file) {
       setStatus('You did not pick an image');
      return;
    }
    String _secureNo = (Random().nextInt(9).toString()) + (Random().nextInt(9).toString()) + (Random().nextInt(9).toString()) + (Random().nextInt(9).toString()) + (Random().nextInt(9).toString()) + (Random().nextInt(9).toString());
    var _filename = getRandomString(20) + _secureNo + '.jpeg';
    var response = await DbQueries('uploadImages', {'email':_email, 'image': base64Image, 'filename': _filename}).query(); 
    
      if (response == 'success') {
          setStatus('Image uploaded');
      } else setStatus('An error occurred while uploading your image.');
  }

  @override
  void initState() {
    super.initState();
    _validateLogin();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BottomNav().appBarPages('Upload Files', context),
      body: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget> [
            OutlineButton(
              onPressed: () {_chooseImage();},
              child: Text('Choose Image'),
            ),
            SizedBox(height: 20.0),
            _showImage(),
            SizedBox(height: 20.0),
            OutlineButton(
              onPressed: () {_uploadImage();},
              child: Text('Upload this Image'),
            ),
            SizedBox(height: 20.0),
            Text(status, textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),

            SizedBox(height: 20.0),

          ],
        ),
      ),
      
    );
  }
}