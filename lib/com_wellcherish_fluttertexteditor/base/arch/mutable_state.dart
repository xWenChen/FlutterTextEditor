
import 'package:flutter/material.dart';

class MutableState<T> with ChangeNotifier  {
  T _data;

  MutableState(this._data);

  T get value => _data;

  set value(T newValue) {
    if (_data != newValue) {
      _data = newValue;
      notifyListeners();
    }
  }
}