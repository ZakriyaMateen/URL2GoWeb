import 'package:flutter/material.dart';

class ShowHideSublistProvider extends ChangeNotifier{
  bool _showCategoryRow = false;
  bool get showCategoryRow => _showCategoryRow;

  void update(bool hide_OR_show){
    _showCategoryRow = hide_OR_show;
    notifyListeners();
  }
}