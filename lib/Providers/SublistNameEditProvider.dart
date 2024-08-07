import 'package:flutter/material.dart';

class SublistNameEditProvider extends ChangeNotifier{
  List<bool> _sublistNameSelectedIndex = [];
  List<bool> get sublistNameSelectedIndex => _sublistNameSelectedIndex;

  void initialize (){
    _sublistNameSelectedIndex.add(false);
  }
  void reset(){
    for(int i=0;i<_sublistNameSelectedIndex.length;i++){
      _sublistNameSelectedIndex[i]=false;
    }
  }

  void flip(int index){
    _sublistNameSelectedIndex[index]=!_sublistNameSelectedIndex[index];
    notifyListeners();
  }
  void turnOff(int index){
    _sublistNameSelectedIndex[index]=false;
    notifyListeners();
  }
}