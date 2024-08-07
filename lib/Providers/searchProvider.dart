import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier{
  String _searchText = '';
  String  get searchText => _searchText;

  void update(String searchText){
    _searchText = searchText;
    notifyListeners();
  }
}