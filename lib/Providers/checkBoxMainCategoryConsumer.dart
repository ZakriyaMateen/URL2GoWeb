import 'package:flutter/material.dart';
class CheckBoxMainCategoryConsumer extends ChangeNotifier {
  Map<String, List<CheckBoxData>> _checkBoxMap = {};

  Map<String, List<CheckBoxData>> get checkBoxMap => _checkBoxMap;

  void initializeCheckBoxList(String date, int length) {
    _checkBoxMap.putIfAbsent(date, () => List.generate(length, (index) => CheckBoxData(index: index, url: '', docId: '', isChecked: false)));
    notifyListeners();
  }

  List<CheckBoxData>? getCheckBoxList(String date) {
    return _checkBoxMap[date];
  }

  void updateCheckBoxList(String date, int index, String url, String docId) {
    if (_checkBoxMap[date] != null && index < _checkBoxMap[date]!.length) {
      _checkBoxMap[date]![index] = CheckBoxData(index: index, url: url, docId: docId, isChecked: !_checkBoxMap[date]![index].isChecked);
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

