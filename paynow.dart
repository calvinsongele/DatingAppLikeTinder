import 'package:flutter/material.dart';
import 'package:WeFreak/includes/dbqueries.dart';
import 'package:WeFreak/includes/validatesession.dart';
import 'package:WeFreak/includes/loader.dart';
import 'package:WeFreak/includes/toastmessage.dart';
import 'package:WeFreak/includes/bottomnav.dart';

class PayNow extends StatefulWidget {
  @override
  _PayNowState createState() => _PayNowState();
}

class _PayNowState extends State<PayNow> {
  // payment types are
  dynamic _email;
  Widget _descriptionWidget = Container();
  Widget _feedbackWidget = Container();
  String _tel;

  _getAccountPrices() async {
    return await DbQueries('plans', {'email':_email}).query();    
  }

  // ensure the user is logged in
  _validateLogin() async {
      ValidateSession sess = ValidateSession(context);
      sess.valSession();
      var email = await sess.returnEmail();
      Map telMap = await DbQueries('getuserdata', {'email':email}).query();
      
      String tel = telMap['user_tel'];
      setState(() {
        _email = email;
        _tel = tel;
      });
  }
  _getText() async {
    return await ValidateSession('context').getAValueInSession('pleasepay');
  }
  _processPayment(_planType, _amount, _duration) async {
    if (_tel.length != 12) {
      ToastMessage('Phone number should be 12 numbers. Example 254700000560. Edit it at Settings!').showMessageError();
    } else {
      // twende server for the rest
      Map _body = {'email': _email, 'tel': _tel, 'plan_type': _planType, 'amount': '$_amount', 'duration': _duration};
      var b = await DbQueries('stk_initiate', _body).query(pay: 'pay');  
      ToastMessage(b).showMessageSuccess();
    }
  }
  _explanationWidget(planTitle, planDesc, planPrice) {
    double _planPrice = double.parse(planPrice);
  
    var monthlyDiscount = 0.08 * (_planPrice * 7 * 4);
    var sixMonthsDiscount = 0.12 * (_planPrice * 7 * 4 * 6);

    var _weeklyPrice = (_planPrice * 7).ceil();
    var _monthlyPrice = ((_planPrice * 7 * 4) - monthlyDiscount).ceil();
    var _sixMonthsPrice = ((_planPrice * 7 * 4 * 6) - sixMonthsDiscount).ceil();
    setState(() {
      _descriptionWidget = Card(
        child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8),
           child: Column(
            children: <Widget> [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget> [
                  Text(planTitle, style: TextStyle(fontSize: 20,
                  fontFamily: 'Courier',  fontWeight: FontWeight.w700),
                  ),
                  RaisedButton.icon(
                    color: Colors.pink,
                    onPressed: () {
                      showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Center(
                    child: Container(
                      child: Card(

                        child: Column(
                          children: <Widget> [
                            _feedbackWidget,

                        Expanded(child: ListView(
                          padding: EdgeInsets.all(15),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: <Widget> [
                            Card(
                              color: Colors.lightBlue,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),

                                child: Column(
                                  //mainAxisSize: MainAxisSize.min,
                                children: <Widget> [
                                  Text('Weekly', style: TextStyle(color: Colors.white,fontSize: 19,
                                  fontFamily: 'Courier',  fontWeight: FontWeight.w800), ),
                                  SizedBox(height: 20),
                                  Text('Kes $_weeklyPrice',
                                  style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600),),
                                  SizedBox(height: 20),
                                  RaisedButton(
                                    color: Colors.pinkAccent,
                                    onPressed: (){ 
                                      _processPayment(planTitle, _weeklyPrice, 'a week');
                                    },
                                    child: Text('Pay Now', style: TextStyle(color: Colors.white, fontFamily: 'Courier',  fontWeight: FontWeight.w600),),
                                  ),
                                ],
                              ),  
                              ),
                            ),
                            Card(
                              color: Colors.lightBlue,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                children: <Widget> [
                                  Text('Monthly', style: TextStyle(color: Colors.white, fontSize: 19,
                                  fontFamily: 'Courier',  fontWeight: FontWeight.w700), ),
                                  SizedBox(height: 20),
                                  Text('Kes $_monthlyPrice',
                                  style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600),),
                                  SizedBox(height: 20),
                                  RaisedButton(
                                    color: Colors.pinkAccent,
                                    onPressed: (){ _processPayment(planTitle, _monthlyPrice, 'a month');},
                                    child: Text('Pay Now', style: TextStyle(color: Colors.white, fontFamily: 'Courier',  fontWeight: FontWeight.w700),),
                                  ),
                                ],
                              ),
                              ),
                            ),
                            Card(
                              color: Colors.lightBlue,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                children: <Widget> [
                                  Text('6 Months', style: TextStyle(color: Colors.white, fontSize: 19,
                                  fontFamily: 'Courier',  fontWeight: FontWeight.w800), ),
                                  SizedBox(height: 20),
                                  Text('Kes $_sixMonthsPrice',
                                  style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w700),),
                                  SizedBox(height: 20),
                                  RaisedButton(
                                    color: Colors.pinkAccent,
                                    onPressed: (){ _processPayment(planTitle, _sixMonthsPrice, '6 months');},
                                    child: Text('Pay Now', style: TextStyle(color: Colors.white, fontFamily: 'Courier',  fontWeight: FontWeight.w700),),
                                  ),
                                ],
                              ),
                              ),
                            ),
                            
                          ],
                        ),),
                         ],
                        ),


                      ),
                    ),
                  );
                   }
                );

                    }, 
                    icon: Icon(Icons.arrow_forward_ios_rounded), 
                    label: Text('Get $planTitle',style: TextStyle(color: Colors.white, fontFamily: 'Courier',  fontWeight: FontWeight.w700),)
                    ) ,
                ],
              ),
              Container(
                child: Text(planDesc, style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w600),),
              ),              
            ],
          ),
        ),         
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _validateLogin();
    //_getAccountPrices();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BottomNav().appBarPages('Payment Plans', context),
      body: SafeArea( 
        child:Container(
          child: FutureBuilder(
            future: _getAccountPrices(),
             builder: (BuildContext context, AsyncSnapshot snapshot) {
               
               if (snapshot.data == null) {
                  return Loader().spinLoader();
               } else {
                 return Column(
                      children: <Widget> [

                        Padding(
                          padding: EdgeInsets.all(15),
                          child: FutureBuilder(
                            future: _getText(),
                            builder: (BuildContext context, AsyncSnapshot snapshoty) {
                              if (snapshoty.data != null) {

                                if (snapshoty.data == 'used')
                                  return  Text('Your rewinds for today are used up!', textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, fontFamily: 'Courier',), );
                                else if (snapshoty.data == 'null')
                                  return  Text('Please subscribe to enjoy unlimited rewinding!', textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 24, fontFamily: 'Courier', fontWeight: FontWeight.w700), );
                                else if (snapshoty.data == 'sp-null')
                                  return  Text('Your superlikes for today are used up!', textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 24, fontFamily: 'Courier', fontWeight: FontWeight.w700), );
                                else if (snapshoty.data == 'sp-used')
                                  return  Text('Please subscribe to enjoy unlimited superlikes!', textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 24, fontFamily: 'Courier', fontWeight: FontWeight.w700), );
                                else 
                                  return
                                   Text('Subscribe and enjoy unlimited services', textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 24, fontFamily: 'Courier', fontWeight: FontWeight.w700), );
                              } else {
                                return Container();
                              }
                            },
                            ),
                         
                        ),
                        

                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget> [
                              for(int i = 0; i < snapshot.data.length; i++)
                              Card(
                                color: i == 1 ? Colors.orange : Colors.pink,
                                child: Container(
                                child: Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Column(
                                  children: [
                                    Text(snapshot.data[i]['plan_name'], style: TextStyle(color:Colors.white, fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 18),),
                                    SizedBox(height: 15),
                                    Text('Daily: ' + snapshot.data[i]['plan_price'], style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold,)),
                                    SizedBox(height: 15),
                                    IconButton(
                                      iconSize: 34,
                                      autofocus: true,
                                      focusColor: Colors.blue,
                                      icon: Icon(Icons.arrow_forward_outlined, 
                                      color: i == 1 ? Colors.pink : Colors.orange,
                                      ),
                                      onPressed: () {
                                        _explanationWidget(snapshot.data[i]['plan_name'], snapshot.data[i]['plan_desc'], snapshot.data[i]['plan_price']);
                                      },
                                    ),
                                  ],                      
                                ),
                                ),
                                ),
                              ),
                            ],
                          ),
                          ),
                        ),
                        // pla description and title will be here
                        Container(
                          child: _descriptionWidget,
                        ),
                      ],
                    );

               }

            }
          ),
        
      ),),


      
    );
  }
}