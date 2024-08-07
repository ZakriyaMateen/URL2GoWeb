import 'package:flutter/cupertino.dart';

class CategoryProviderMessenger extends ChangeNotifier {
  List<bool> _categoryBoolList = [];
  String _title='';
  // Add this method to initialize categoryBoolList with the given count
  void initializeList(int count) {
    _categoryBoolList = List.generate(count, (_) => false);
    notifyListeners();
  }

  void reset (){
    _categoryBoolList = [];
    _title = '';
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    for (int i = 0; i < _categoryBoolList.length; i++) {
      _categoryBoolList[i]=false;// Set only the selected index to true
    }
    _categoryBoolList[index]=true;
    notifyListeners();
  }

  // Your existing add method remains unchanged
  void add(bool v) {
    _categoryBoolList.add(v);
  }
  void setTitle(String v){
    _title=v;
    notifyListeners();
  }

  List<bool> get categoryBoolList => _categoryBoolList;
  String get title => _title;
}
