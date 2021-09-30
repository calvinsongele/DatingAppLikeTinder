import 'package:flutter/material.dart';

class HomeNavs {
  var context;

  HomeNavs(this.context);

   Widget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.home,
          color: Colors.grey,
          size: 30.0,
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
      ),
      title: Text(
        'WeFreak', style: TextStyle(color: Colors.pink, fontFamily: 'Courier',  fontWeight: FontWeight.w800, fontStyle: FontStyle.italic ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.star,
            color: Colors.grey,
            size: 25.0,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/likes');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.chat_bubble,
            color: Colors.grey,
            size: 25.0,
          ),
          onPressed: () {
           Navigator.pushNamed(context, '/messages');
          },
        ),
         IconButton(
          icon: Icon(
            Icons.person,
            color: Colors.grey,
            size: 25.0,
          ),
          onPressed: () {
           Navigator.pushNamed(context, '/userprofile');
          },
        ),
      ],
    );
  }

  
    Widget buildBottomBar() {
    return BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.orange),
                onPressed: () {},
              ),
              IconButton(
                 icon: Icon(Icons.clear, color: Colors.red),
                onPressed: () {
                  
                  //matchEngine.currentMatch.nope();
                },
              ),
              IconButton(
                 icon: Icon(Icons.star, color: Colors.blue),
                onPressed: () {
                 /// matchEngine.currentMatch.superLike();
                },
              ),
              IconButton(
                 icon: Icon(Icons.favorite, color: Colors.blue),
                onPressed: () {
                  //matchEngine.currentMatch.like();
                },
              ),
              // new IconButton(
              //    icon: Icon(Icons.lock, color: Colors.purple),
              //   onPressed: () {},
              // ),
            ],
          ),
        ));
  }
  


}