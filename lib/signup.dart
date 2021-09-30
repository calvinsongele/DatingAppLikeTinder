import 'package:flutter/material.dart';
import 'package:flutter_text_anchor/flutter_text_anchor.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:WeFreak/includes/urllauncher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:WeFreak/includes/toastmessage.dart';
import 'package:WeFreak/includes/bottomnav.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  //form controllers
  String genderValue = 'Male';
  TextEditingController nameController; 
  TextEditingController emailController;
  TextEditingController telController; 
  TextEditingController dobController;
  TextEditingController genderController; //imgController;

    _action(_dec) async {
        if (_dec == 'locsettings') {
          await Geolocator.openAppSettings();
        } else if (_dec == 'location'){
          await Geolocator.openLocationSettings();
        } else {
           await Geolocator.requestPermission();
        }

    }
    _showSnackBar(context, _snack, _dec) async {
      Scaffold.of(context).showSnackBar(
        SnackBar(
        content: Text('$_snack'),
        backgroundColor: Colors.grey[400],
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Accept Location Request',
          onPressed: () { 
            _action(_dec);
          },
        ),
      ));
    }
  // submit to server function
  _submitUser() async {
    // save data to online server
    var _coordinates = await _getLocation();
    if (_coordinates == null) {
        bool serviceEnabled;
        LocationPermission permission;
        String _iserror = 'none';
        String _errorMsg = "";

        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showSnackBar(context, 'Please open your location services and resubmit the form', 'location'); 
        }

        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          _showSnackBar(context, 'Please allow this app to access your locaton', 'locsettings');
        }

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission != LocationPermission.whileInUse &&
              permission != LocationPermission.always) {
              _showSnackBar(context, 'Please allow this app to access your locaton', 'request again');
          }
        }

    } else {
    var long = (_coordinates.longitude);
    var lat = _coordinates.latitude;
      Map dataToSend = {
        "name": nameController.text,
        "email": emailController.text,
        "tel": telController.text,
        "gender": genderValue,
        "dob": dobController.text,
        "fb_id":'1',
        "type": "signup",
        "long": '$long',
        "lat": '$lat'
      };
      String response = await DbQueries('newuser', dataToSend).query();  
      if (response != 'success') {
        ToastMessage(response).showMessageError();
      } else {
        // log the user in
        ToastMessage(response).showMessageSuccess();

        //redirect to home after success
        FlutterSession().set("email", emailController.text);
        Navigator.pushReplacementNamed(context, '/');

      }
    }
  }

   // location
  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${position.latitude}');
    final coordinates = Coordinates(position.latitude, position.longitude);
    //var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    //var first = addresses.first.locality;
    return coordinates;
  }


  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    emailController = TextEditingController();
    telController = TextEditingController();
    dobController = TextEditingController();
    genderController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  BottomNav().appBarPages('WeFreak Login', context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        clipBehavior: Clip.none,
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'John Doe',
                    labelText: 'Name *',
                  ),
                  onSaved: (String value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String value) {
                    return value.isEmpty ? 'Your name is required' : null;
                  },
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    hintText: 'johndoe@yahoo.com',
                    labelText: 'Email *',
                  ),
                  onFieldSubmitted: (String value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String value) {
                    return value.isEmpty ? 'Your email is required' : null;
                  },
                ),
                TextFormField(
                  controller: telController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.call),
                    hintText: '+44 1632 960183',
                    labelText: 'Telephone *',
                  ),
                  validator: (String value) {
                    return value.isEmpty ? 'Your phone is required' : null;
                  },
                ),
                TextFormField(
                  controller: dobController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: "Date of birth",
                    hintText: "Ex. Insert your dob",
                  ),
                  onTap: () async {
                    DateTime date = DateTime(1900);
                    FocusScope.of(context).requestFocus(new FocusNode());

                    date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100));

                    dobController.text = date.toIso8601String();
                  },
                ),
                SizedBox(width: 10.0, height: 20.0), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget> [
                    Icon(Icons.person_outline_rounded),
                    Text('Gender'),
                    ToggleSwitch(
                      initialLabelIndex: (0),
                      minWidth: 82.0,
                      cornerRadius: 20.0,
                      activeBgColor: Colors.cyan,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      labels: ['Male', 'Female'],
                      onToggle: (value) {
                        String state;
                        if (0 == value) state = 'Male';
                        else state = 'Female';
                        setState(() => genderValue = state);
                      },
                    ),
                 ],

                ),

                    
                SizedBox(width: 10.0, height: 20.0),        
                RaisedButton(
                  color: Color.fromARGB(255, 255, 100, 255),
                  onPressed: () {
                   _submitUser();
                  },
                  child: Text('Submit', style: TextStyle(color: Colors.white, fontSize: 23),),
                ),
                 SizedBox(width: 10.0, height: 20.0),

                 Row(
                   children: <Widget> [
                     Text('checkbox'),
                     TextAnchor(
                        textColor: Colors.black54,
                        linkColor: Colors.pink,
                        fontWeight: FontWeight.w300,
                        fontSize: 18.0,
                        text: ''' By signing up, you agree to our (terms and conditions)[https://we-freak.com/privacyandterms].
                              ''',
                        onTapLink: (link) {
                            UrlLauncher(link).launchUrl();
                        },
                      ),

                   ],
                 ),
              ],
               
            ),
          ),
          
        ),
      ),
    );
  }
}
