import 'package:flutter/material.dart';

class DateProvider extends ChangeNotifier {
  DateTime _selectedDateTimeGlobal = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  DateTime _currentDate = DateTime.now(); // Add this line

  DateTime get selectedDate => _selectedDate;
  DateTime get selectedDateTimeGlobal => _selectedDateTimeGlobal;
  DateTime get currentDate => _currentDate; // Add this getter


  void updateSelectedDate(DateTime newDate) {

    _selectedDate = newDate;

    notifyListeners();
  }

  void updateSelectedDateGlobal(DateTime selectedDate) {
    _selectedDateTimeGlobal = selectedDate;
    notifyListeners();
  }

  void updateCurrentDate(DateTime newCurrentDate) {
    _currentDate = newCurrentDate;
    notifyListeners();
  }
}
