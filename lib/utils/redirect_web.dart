import 'dart:html';
import 'package:flutter_pma/utils/redirect.dart';

class RedirectorImpl extends Redirector {

  @override
  void go(url) {
    window.location.replace(url);
  }

}

Redirector getManager() =>RedirectorImpl();