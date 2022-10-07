import 'package:flutter_pma/utils/redirect.dart';

class RedirectorImpl extends Redirector {

  @override
  void go(url) {}

  @override
  String? param(name){
    return '';
  }
  
}

Redirector getManager() =>RedirectorImpl();