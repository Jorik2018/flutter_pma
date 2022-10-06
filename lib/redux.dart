import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

dynamic counterReducer(dynamic state, dynamic action) {
  if (action['type'] == 'URL') {
    return action['value'];
  }
  return state;
}