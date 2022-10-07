import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pma/utils/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Util {

  Util._();

  static const String name = "Registration and Login";
  static const String store = "Online Store\n For Everyone";
  static const String skip = "SKIP";
  static const String next = "NEXT";
  static const String gotIt = "GOT IT";
  static String API_URL = dotenv.env['API_URL']!;

  static String userName = "";
  static String emailId = "";
  static String profilePic = "";
  static List<String> descriptionList = <String>[];
  static List<String> mediaList = <String>[];
  static List<ListItem> listItems = <ListItem>[];
}

class HTTP{

  Map<String,String> headers= {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  };

  Future<http.Response> get(String url,{Map<String,String>? headers}){

    return http.get(Uri.parse(Util.API_URL  + url),headers:headers!=null?headers:this.headers);
  }

  Future<http.Response> post(String url,Object body,{String? config,Map<String,String>? headers}){
    if(body is FormBuilder){
      body=json.encode((body as FormBuilder).toMap());
    }else if(!(body is String)){
      body=json.encode(body);
    }
    return http.post(Uri.parse(Util.API_URL  + url),body:body.toString(),headers:headers!=null?headers:this.headers);

  }

}

HTTP http2=HTTP();

class FormBuilder {

  Map _o={};

  Map expanded={};

  Map controllerMap = {};

  FormBuilder(Map o){_o=o;}

  void set o(Map o0) {
  this._o=o0;
  expanded={};
  controllerMap = {};
  }

    Map get o {
return _o;
  }

  Widget dropdownButton(
      List _options, String key, void Function(void Function()) setState,
      {List Function(Object)? adapter,void Function(Object?)? onChanged}) {
        var value=_o[key]??'';
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
      items: _options.map((_o) {
        if (adapter != null) {
          List l = _o is String ? ['', _o] : adapter(_o);
          return new DropdownMenuItem(value: l[0], child: new Text(l[1]));
        } else
          return new DropdownMenuItem(value: _o, child: new Text(_o));
      }).toList(),
      onChanged: (e) {
        setState(() {
          _o[key] = e;
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
            groupValue: _o![key]??'',
            value: item,
            onChanged:  (e) {
              setState(() {
                _o![key] = e??'';
              });
            },
            splashRadius: 35,
            toggleable: true,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ));
      if (addWidget != null) {
        //addWidget(widgets, _o![key], index);
      }
      return widgets.toList();
    }).toList();
  }

  Widget numberField(Function setState, String name) {
    TextEditingController? controller = controllerMap[name];
    if (controller == null) {
      controllerMap[name] = (controller = TextEditingController());
    }
    if(_o[name]!=null){
      var cursorPos =controller.selection.base.offset;
      controller.text = _o[name];
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
          _o[name] = value;
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
    if(_o[name]!=null){
      var cursorPos =controller.selection.base.offset;
      controller.text = _o[name];
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
          _o[name] = value;
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
return HashMap.from(_o.map((key, value)=> 
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
      _o[name] = value;
    });
  }

  void Function(String)? setter(Function setState, name) {
    return (Object? value) {
      setState(() {
        _o[name] = value;
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
      Object? value = _o[valueName2];
      widgets.add(CheckboxListTile(
          title: Text(item),
          controlAffinity: ListTileControlAffinity.leading,
          value: value != null && value.toString() == 'true',
          onChanged: (Object? value) {
            setState(() {
              _o[valueName2] = value;
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
    Object? value=_o![key];
    return TextFormField(
      controller: dateinput..text = value != null ? value.toString() : '',
      textAlign: textAlign,
      decoration: InputDecoration(
          icon: Icon(Icons.calendar_today), labelText: "Enter Date"),
      readOnly: true,
      onTap: () async {
        DateTime? old;
        try{
          old=DateFormat('yyyy-MM-dd').parse(_o![key]);
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
          _o![key] = value;
        });
     
      },
    );
  }


}
