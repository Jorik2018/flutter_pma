import 'dart:html';
import 'package:flutter_pma/utils/redirect.dart';

class RedirectorImpl extends Redirector {

  @override
  void go(url) {
    window.location.replace(url);
  }

  @override
  String? param(name){
    print(Uri.base.toString()); // http://localhost:8082/game.html?id=15&randomNumber=3.14
    print(Uri.base.query);  // id=15&randomNumber=3.14
    return Uri.base.queryParameters[name];
  }

}

Redirector getManager() =>RedirectorImpl();