import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
class Loader {

  spinLoader() {
    return Center(
      child: SpinKitFadingCircle(
        color: Colors.pink,
        size: 50.0,
      )
    );
  }
   spinLoaderHeart() {
    return Center(
      child: SpinKitPumpingHeart(
        color: Colors.pink,
        size: 50.0,
      )
    );
  }
  spinLoaderRipple() {
    return Center(
      child: SpinKitRipple(
        color: Colors.pink,
        size: 50.0,
      )
    );
  }
   spinLoaderRippleLarge() {
    return Center(
      child: SpinKitRipple(
        color: Colors.pink,
        size: 200.0,
      )
    );
  }
  
}