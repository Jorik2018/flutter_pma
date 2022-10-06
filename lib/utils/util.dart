import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_pma/utils/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';


//import 'dart:html';

class Util {

  Util._();

  static const String name = "Registration and Login";
  static const String store = "Online Store\n For Everyone";
  static const String skip = "SKIP";
  static const String next = "NEXT";
  static const String gotIt = "GOT IT";
  static String remoteHost =
      'http://web.regionancash.gob.pe'; //"https://grupoipeys.com/x";

  static String userName = "";
  static String emailId = "";
  static String profilePic = "";
  static List<String> descriptionList = <String>[];
  static List<String> mediaList = <String>[];
  static List<ListItem> listItems = <ListItem>[];
}

class FormBuilder {

  Map o={};

  Map expanded={};

  Map controllerMap = {};

  FormBuilder(this.o);

  Widget dropdownButton(
      List _options, String key, void Function(void Function()) setState,
      {List Function(Object)? adapter,void Function(Object?)? onChanged}) {
        var value=o[key]??'';
        var v=null;
        _options.forEach((element) {
          if (adapter != null) {
            List l = element is String ? ['', element] : adapter(element);
            element=l[0];
          }
          if(value==element){
            v=element;
          }
        });
    return DropdownButton(
      value: v,
      items: _options.map((o) {
        if (adapter != null) {
          List l = o is String ? ['', o] : adapter(o);
          return new DropdownMenuItem(value: l[0], child: new Text(l[1]));
        } else
          return new DropdownMenuItem(value: o, child: new Text(o));
      }).toList(),
      onChanged: (e) {
        setState(() {
          o[key] = e;
          if(onChanged!=null)onChanged(e);
        });
      }, //setter,
      isExpanded: true,
    );
  }

  List<Widget> radioGroup(
      List<String> options, String key, void Function(void Function()) setState,
      {void Function(List<Widget>, Object?, int)? addWidget}) {
  
    return (options.asMap().entries).expand((entry) {
      int index = entry.key;
      
      var item = entry.value;
      List<Widget> widgets = [];
      widgets.add(ListTile(
        title: Text(item),
        leading: Radio(
            groupValue: o![key]??'',
            value: item,
            onChanged:  (e) {
              setState(() {
                o![key] = e??'';
              });
            },
            splashRadius: 35,
            toggleable: true,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ));
      if (addWidget != null) {
        //addWidget(widgets, o![key], index);
      }
      return widgets.toList();
    }).toList();
  }

  Widget numberField(Function setState, String name) {
    TextEditingController? controller = controllerMap[name];
    if (controller == null) {
      controllerMap[name] = (controller = TextEditingController());
    }
    if(o[name]!=null){
      var cursorPos =controller.selection.base.offset;
      controller.text = o[name];
      controller.value = controller.value.copyWith(
        text: controller.text,
        selection: TextSelection(
        baseOffset: cursorPos>-1?cursorPos:controller.text.length, 
        extentOffset: cursorPos>-1?cursorPos:controller.text.length)
      );
    }
    return TextFormField(
      controller: controller,
      onChanged: (value) {
        setState(() {
          o[name] = value;
        });
      },
      decoration: InputDecoration(
        hintText: "Enter your number here...", border: OutlineInputBorder()
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly
      ],
    );
  }

  Widget textField(Function setState, String name,
      {TextAlign textAlign = TextAlign.left,
      bool readOnly = false,
      Function()? onTap}) {
    TextEditingController? controller = controllerMap[name];
    if (controller == null) {
      controllerMap[name] = (controller = TextEditingController());
    }
    if(o[name]!=null){
      var cursorPos =controller.selection.base.offset;
      controller.text = o[name];
      controller.value = controller.value.copyWith(
        text: controller.text,
        selection: TextSelection(
        baseOffset: cursorPos>-1?cursorPos:controller.text.length, 
        extentOffset: cursorPos>-1?cursorPos:controller.text.length)
      );
    }
    return TextFormField(
      textAlign: textAlign,
      controller: controller,
      onChanged: (value) {
        setState(() {
          o[name] = value;
        });
      },
      decoration: InputDecoration(
          hintText: "Enter your text here....", border: OutlineInputBorder()),
      readOnly: readOnly,
      onTap: onTap,
      validator: (String? value) {
        return "validateDNIInput(value)";
      }
    );
  }
HashMap<String,Object> toMap(){
return HashMap.from(o.map((key, value)=> 
                             MapEntry(key,value)
                          ));
}




TextStyle bold20Style = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  List<ExpansionPanel> expansionPanel(List panels) {
    int index = -1;
    return (panels.map<ExpansionPanel>((e) {
      index++;
      return ExpansionPanel(
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(e['title'], style: bold20Style),
          );
        },
        isExpanded: expanded[index] != null && expanded[index],
        body: Padding(
            padding: EdgeInsets.all(15.0),
            child: e['items'] != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: e['items'].cast<Widget>())
                : Text('Empty!')),
      );
    })).toList();
  }

  void setO(Function setState, Object? value, String? name) {
    setState(() {
      o[name] = value;
    });
  }

  void Function(String)? setter(Function setState, name) {
    return (Object? value) {
      setState(() {
        o[name] = value;
      });
    };
  }

  List<Widget> checkboxGroup(List<String> options, String valueName,
    void Function(void Function()) setState,
      {
      void Function(List<Widget>, Object?, int)? addWidget}) {
    return (options.asMap().entries).expand((entry) {
      int index = entry.key;
      var item = entry.value;
      String valueName2 = valueName + (index + 1).toString();
      List<Widget> widgets = [];
      Object? value = o[valueName2];
      widgets.add(CheckboxListTile(
          title: Text(item),
          controlAffinity: ListTileControlAffinity.leading,
          value: value != null && value.toString() == 'true',
          onChanged: (Object? value) {
            setState(() {
              o[valueName2] = value;
            });
          }));
      if (addWidget != null) {
        addWidget(widgets, value, index);
      }
      return widgets.toList();
    }).toList();
  }

  Widget dateField(
    BuildContext context,
    String key, void Function(void Function()) setState, {
    TextAlign textAlign = TextAlign.center,
    String? type,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    TextEditingController dateinput = TextEditingController();
    Object? value=o![key];
    return TextFormField(
      controller: dateinput..text = value != null ? value.toString() : '',
      textAlign: textAlign,
      decoration: InputDecoration(
          icon: Icon(Icons.calendar_today), labelText: "Enter Date"),
      readOnly: true,
      onTap: () async {
        DateTime? old;
        try{
          old=DateFormat('yyyy-MM-dd').parse(o![key]);
        }catch(e){
          print(e);
        }
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: old!=null?old:DateTime.now(),
            firstDate: DateTime(
                2000), //DateTime.now() - not to allow to choose before today.
            lastDate: DateTime(2101));
        if(pickedDate==null)pickedDate=old;
        Object value =
            pickedDate != null ? DateFormat('yyyy-MM-dd').format(pickedDate) : '';
        
      
        setState(() {
          o![key] = value;
        });
     
      },
    );
  }


}
