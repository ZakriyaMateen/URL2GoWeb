import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier{



  double _fontSizeMultiplier = 1.0;
  double minMultiplier = 0.5;
  double maxMultiplier = 1.2;

  double get fontSizeMultiplier => _fontSizeMultiplier;

  void update(double value){
    _fontSizeMultiplier = value;
    notifyListeners();
  }

}