import 'package:flutter/material.dart';

class ShareListProviderSublist extends ChangeNotifier{
  String _sharingUrl = '';
  String get sharingUrl => _sharingUrl;
  List<Map<String,dynamic>> _shareList = [];
  List<Map<String,dynamic>> get shareList => _shareList;

  void setSharingUrl (String sharingUrl){
    _sharingUrl = sharingUrl;
    notifyListeners();
  }

  void update(Map<String, dynamic> map) {
    bool alreadyExists = _shareList.any((existingMap) {
      // Compare the values of existingMap and map
      return map.entries.every((entry) =>
      existingMap[entry.key] == entry.value);
    });

    // Only add the map if it doesn't already exist in _shareList
    if (!alreadyExists) {
      _shareList.add(map);
      notifyListeners();
    }
    // notifyListeners();
  }
  void flipIsSelected(int index){
    _shareList[index]['isSelected']=!_shareList[index]['isSelected'];
    notifyListeners();
  }
  void reset(){
    _sharingUrl = '';
    _shareList = [];
    notifyListeners();
  }
}