
import 'package:http/http.dart' as http;
import 'dart:convert';
class DbQueries {

  String _phpmethod;
  Map _body;

  DbQueries(this._phpmethod, this._body);

  query({String pay = 'null'}) async {
    //if (pay != 'pay') wefreakweb(_phpmethod,_body);
    var response = await http.post('https://we-freak.com/flutterapp/' + _phpmethod, body:_body);
    return jsonDecode(response.body); 
  }

  wefreakweb(_phpmethod, _body) {
    http.post('https://we-freak.com/flutterapp/' + _phpmethod, body:_body);
  }
  void voidQuery() {
    http.post('https://wefreak.instarcom.co/flutterapp/' + _phpmethod, body:_body);
  }
  
  
}