import 'package:flutter/material.dart';

class CheckBoxConsumer extends ChangeNotifier {
  Map<String, List<CheckBoxData>> _checkBoxMap = {};

  Map<String, List<CheckBoxData>> get checkBoxMap => _checkBoxMap;

  void reset() {
    _checkBoxMap.clear(); // Clear the map instead of assigning an empty map
    notifyListeners();
  }

  void initializeCheckBoxList(String date, int length) {
    _checkBoxMap.putIfAbsent(date, () => List.generate(length, (index) => CheckBoxData(index: index, url: '', docId: '', isChecked: false)));
    notifyListeners();
  }

  List<CheckBoxData> getCheckBoxList(String date) {
    return _checkBoxMap[date] ?? []; // Handle null case by returning an empty list
  }

  void updateCheckBoxList(String date, int index, String url, String docId) {
    final checkBoxList = _checkBoxMap[date];
    if (checkBoxList != null && index < checkBoxList.length) {
      checkBoxList[index] = CheckBoxData(index: index, url: url, docId: docId, isChecked: !checkBoxList[index].isChecked);
      // print(_checkBoxMap);
      notifyListeners();
    }
  }

  void printt() {
    // print(_checkBoxMap);
  }
}

class CheckBoxData {
  int index;
  String url;
  String docId;
  bool isChecked;

  CheckBoxData({required this.index, required this.url, required this.docId, this.isChecked = false});

  @override
  String toString() {
    return 'CheckBoxData(index: $index, url: $url, docId: $docId, isChecked: $isChecked)';
  }
}
