import 'package:flutter/material.dart';

class WidgetSlider {

  static Future<void> switchScreen(BuildContext context, Widget destination, SwitchWidgetDirection direction) {

    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {

          Offset begin = const Offset(0.0, 0.0);
          
          if (direction == SwitchWidgetDirection.left) {

            begin = const Offset(-1.0, 0.0);
          }
          else if (direction == SwitchWidgetDirection.right) {

            begin = const Offset(1.0, 0.0);
          }

          var end = Offset.zero;
          var curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  static Future<void> switchScreenSimple(BuildContext context, Widget destination) {
    
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}

enum SwitchWidgetDirection {

  left,
  right,
}