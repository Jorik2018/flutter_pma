import 'package:registration_login/utils/list_item.dart';
import 'dart:html';

class Util {

  Util._();



  static const String name = "Registration and Login";
  static const String store = "Online Store\n For Everyone";
  static const String skip = "SKIP";
  static const String next = "NEXT";
  static const String gotIt = "GOT IT";
  static String remoteHost =window.location.href.contains("localhost")?"http://web.regionancash.gob.pe":"https://grupoipeys.com/x";

  static String userName ="";
  static String emailId ="";
  static String profilePic ="";
  static List<String> descriptionList = <String>[];
  static List<String> mediaList =  <String>[];
  static List<ListItem> listItems = <ListItem>[];

}
