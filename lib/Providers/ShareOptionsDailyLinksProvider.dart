import 'package:flutter/material.dart';

class ShareOptionsDailyLinksProvider extends ChangeNotifier{
  String _shareOption = '';
  String get shareOption => _shareOption;
  void update(String option){
    _shareOption = option;
    notifyListeners();
  }
  void reset(){
    _shareOption = '';
    notifyListeners();
  }

}