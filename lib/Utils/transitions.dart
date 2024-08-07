import 'package:flutter/material.dart';

enum TransitionType {
  slideRightToLeft,
  slideLeftToRight,
  slideTopToBottom,
  slideBottomToTop,
  fade,
  scale,
}

void navigateWithTransition(BuildContext context, Widget screen, TransitionType transitionType) {
  PageRouteBuilder pageRouteBuilder;

  switch (transitionType) {
    case TransitionType.slideRightToLeft:
      pageRouteBuilder = PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero).animate(animation),
            child: child,
          );
        },
      );
      break;
    case TransitionType.slideLeftToRight:
      pageRouteBuilder = PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset.zero).animate(animation),
            child: child,
          );
        },
      );
      break;
    case TransitionType.slideTopToBottom:
      pageRouteBuilder = PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero).animate(animation),
            child: child,
          );
        },
      );
      break;
    case TransitionType.slideBottomToTop:
      pageRouteBuilder = PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero).animate(animation),
            child: child,
          );
        },
      );
      break;
    case TransitionType.fade:
      pageRouteBuilder = PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      );
      break;
    case TransitionType.scale:
      pageRouteBuilder = PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: child,
          );
        },
      );
      break;
  }

  Navigator.of(context).push(pageRouteBuilder);
}
