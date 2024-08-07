import 'package:flutter/material.dart';

class ShareOptionsProviderSublist extends ChangeNotifier{
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