import 'package:flutter/material.dart';
class BottomNav {

  // rerouting function
  reroutePages(index, context) {
   switch (index) {
      case 1:
        Navigator.pushNamed(context, '/likes');
        break;
      case 2:
        Navigator.pushNamed(context, '/messages');
        break;
      case 3:
        Navigator.pushNamed(context, '/userprofile');
        break;
      default:
        Navigator.pushNamed(context, '/');
    }
  }

Widget appBarPages(_title, context) {
    return AppBar(
      // actions: [
      //   IconButton(
      //         icon: Icon(
      //           Icons.arrow_back,
      //           color: Colors.white,
      //         ),
      //         onPressed: () {
      //           Navigator.pop(context, true);
      //         },
      //       ),
      // ],
        title: Text('$_title', style: TextStyle(fontFamily: 'Courier',  fontWeight: FontWeight.w800)),
        backgroundColor: Colors.pink[300],
      );
}

  Widget nav(indexC, context) {
    return BottomNavigationBar(
        currentIndex: indexC,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.pink[300],
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: ("Home"),
              backgroundColor: Colors.pink[300]),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: ("Likes"),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.comment),
              label: "Message",
              backgroundColor: Colors.pink[250]),
          BottomNavigationBarItem(
              icon: Icon(Icons.stars),
              label: ("Profile"),
              backgroundColor: Colors.pink[250]),
        ],
        onTap: (index) {
          reroutePages(index, context);
        },
      );

  }
}