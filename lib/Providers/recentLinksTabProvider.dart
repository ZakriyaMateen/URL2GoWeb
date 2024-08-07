import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Properties/Colors.dart';
class RecentLinksTabProvider extends ChangeNotifier {
  List<bool> _allUnreadNew = [true, false, false];

  List<bool> get allUnreadNew => _allUnreadNew;

  void setSelectedIndex(int index) {
    for (int i = 0; i < _allUnreadNew.length; i++) {
      if(_allUnreadNew[i]=false);
    }
    _allUnreadNew[index]=true;

    // print(_allUnreadNew);

    notifyListeners();
  }
}