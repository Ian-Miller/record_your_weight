import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyRoute<T> extends MaterialPageRoute<T> {
  MyRoute(WidgetBuilder builder) : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
          .animate(animation),
      child: child,
    );
  }
}
