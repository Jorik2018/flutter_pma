import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pma/utils/util.dart';

class ChildStartFragment extends StatefulWidget {

  Function? navigateTo;

  String? id;

  ChildStartFragment({this.navigateTo,this.id});

  @override
  _ChildStartFragmentState createState() => new _ChildStartFragmentState();

}

FormBuilder fb=FormBuilder({'p72': '2023-12-12'});

Map ctrl = {};

Function setterC = (Function setState, name) {
  return (Object? value) {
    setState(() {
      ctrl[name] = value;
    });
  };
};



class _ChildStartFragmentState extends State<ChildStartFragment> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController dateinput = TextEditingController();
  TextStyle boldStyle = TextStyle(fontWeight: FontWeight.bold);
  
  ButtonStyle buttonStyle = TextButton.styleFrom(
      padding: const EdgeInsets.all(16.0),
      primary: Colors.white,
      backgroundColor: Colors.blue,
      textStyle: const TextStyle(fontSize: 20));
  
  Position? _position;

  @override
  void initState() {
    super.initState();
    if(widget.id!=null){
      http2.get('/api/minsa/children/'+widget.id!).then((response) {
        var data = jsonDecode(response.body);
        if(data['p5_8']!=null){
          _getDistricts(data['p5_8']).then((result)=>{
            setState(() {
              districts=(result['data'] as List).toList();
              fb.o=data;
            })
          });
        }
        if(data['p5_7']!=null){
          _getProvinces(data['p5_7']).then((result)=>{
            setState(() {
              provinces=(result['data'] as List).toList();
              fb.o=data;
            })
          });
        }else
          setState(() {
            fb.o=data;
          });
      });
    }else{
      fb.o={'p5_7':'02'};
    }
  }

  @override
  void dispose() {}

  Future _getRegions() async {
    http.Response response =await http2.get('/admin/directory/api/region/0/0',headers:{});
    var result= jsonDecode(response.body);
    return result;
  }

  Future _getProvinces(Object regionId) async {
    http.Response response =await http2.get('/admin/directory/api/province/0/0?regionId='+regionId.toString(),headers:{});
    var result= jsonDecode(response.body);
    return result;
  }

  Future _getDistricts(Object regionId) async {
    http.Response response =await http2.get('/admin/directory/api/district/0/0?provinceId='+regionId.toString(),headers:{});
    var result= jsonDecode(response.body);
    return result;
  }

  void _getCurrentLocation() async {
    Position position = await _determinePosition();
    setState(() {
      fb.o['lat'] = position.latitude;
      fb.o['lon'] = position.longitude;
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  List regions=[];

  List provinces=[];

  List districts=[];

  _ChildStartFragmentState() {
    _getRegions().then((region)=>{
      setState(() {
        regions=(region['data'] as List).toList();
      })
    });
  }

  @override
  Widget build(BuildContext context) {

    List panels = [
      {
        'title': 'Datos personales del niño o niña',
        'items': [
          Text("DNI/partida de nacimiento/CUI", style: boldStyle),
          fb.numberField(setState, 'code'),
          Text("Nombre del niño/a", style: boldStyle),
          fb.textField(setState, 'p1'),
          Text("Apellido paterno:", style: boldStyle),
          Row(children: <Widget>[
            Expanded(child: fb.textField(setState, 'p2')),
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    /// _isEnable = true;
                  });
                })
          ]),
          Text("Apellido materno", style: boldStyle),
          fb.textField(setState, 'p3'),
          Text("Sexo", style: boldStyle),
          Column(children: fb.radioGroup([
            'Masculino', 
            'Femenino'
          ], 'p4', setState)),
          Text("Fecha nacimiento", style: boldStyle),
          fb.dateField(context, 'birthday', setState),
          Text("Tipo de seguro al que se encuentra afiliado/a",
              style: boldStyle),
          Column(children: fb.radioGroup([
            'SIS',
            'ESSALUD',
            'FAP',
            'PNP',
            'Privado',
            'No tiene seguro'
          ], 'p6', setState)),
          Text("Región", style: boldStyle),
          fb.dropdownButton(
            ['--Seleccionar Opción--',...regions],'p5_7',setState,
            adapter:(item){
              item=item as Map;
              return [item['code'],item['name']];
            },
            onChanged:(e){
              _getProvinces(e!=null?e:'99').then((result)=>{
                setState(() {
                  provinces=(result['data'] as List).toList();
                })
              });
            }
          ),
          if(fb.o['p5_7']!=null)...[
            Text("Provincia", style: boldStyle),
            fb.dropdownButton(
              ['--Seleccionar Opción--',...provinces],'p5_8',setState,
              adapter:(item){
                item=item as Map;
                return [item['code'],item['name']];
              },
              onChanged:(e){
                _getDistricts(e!=null?e:'99').then((result)=>{
                  setState(() {
                    districts=(result['data'] as List).toList();
                  })
                });
              }
            ),
            if(fb.o['p5_8']!=null)...[
              Text("Distrito", style: boldStyle),
              fb.dropdownButton(
                ['--Seleccionar Opción--',...districts],'p5_9',setState,
                adapter:(item){
                  item=item as Map;
                  return [item['name'],item['name']];
                }
              )
            ]
          ]
        ]
      },
      {
        'title': 'Ubicación de la vivienda',
        'items': [
          Text("Geolocalización:", style: boldStyle),
          /*fb.textField(
              o['lat'] != null && o['lon'] != null
                  ? (o['lat'].toString() + ',' + o['lon'].toString())
                  : "",
              (value) {},
              textAlign: TextAlign.center,
              readOnly: true, onTap: () {
            context.push(
                '/map/' + o['lat'].toString() + '/' + o['lon'].toString());
          } //widget.navigateTo!(5,options:o)
              ),*/
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton.icon(
                icon: Icon(Icons.location_on_rounded),
                style: buttonStyle,
                onPressed: () async {
                  _getCurrentLocation();
                },
                label: const Text('Obtener Coordenadas'))
          ]),
          Text("Eje Vial:", style: boldStyle),
          Column(
              children: fb.radioGroup(
                  ['Avenida', 'Calle', 'Jirón', 'Sin eje vial'],
                  'p9',setState)),
          Text("Dirección Actual:", style: boldStyle),
          fb.textField(setState, 'p10'),
          Text("Referencia de la Dirección:", style: boldStyle),
          fb.textField(setState, 'p11'),
          Row(
            children: <Widget>[
              Expanded(child: Text("Corregir Información")),
              Switch(
                value: ctrl['change-location'] != null &&
                    ctrl['change-location'] == true,
                onChanged: setterC(setState, 'change-location'),
              ),
            ],
          )
        ]
      },
      {
        'title': 'Datos de la madre, padre o cuidador/a',
        'items': [
          Text("Nombres del padre", style: boldStyle),
          fb.textField(setState, 'p13'),
          Text("Apellido paterno del padre", style: boldStyle),
          fb.textField(setState, 'p14'),
          Text("Apellido materno del padre", style: boldStyle),
          fb.textField(setState, 'p15'),
          Text("DNI del padre", style: boldStyle),
          fb.numberField(setState, 'p16'),
          Text("Nombres de la madre", style: boldStyle),
          fb.textField(setState, 'p17'),
          Text("Apellido paterno de la madre", style: boldStyle),
          fb.textField(setState, 'p18'),
          Text("Apellido materno de la madre", style: boldStyle),
          fb.textField(setState, 'p19'),
          Text("Fecha de nacimiento de la madre", style: boldStyle),
          fb.dateField(context, 'p20', setState),
          Text("DNI de la madre", style: boldStyle),
          fb.numberField(setState, 'p21'),
          Text("Nombres de la madre", style: boldStyle),
          fb.textField(setState, 'p22'),
          Text("Apellido paterno de la madre", style: boldStyle),
          fb.textField(setState, 'p23'),
          Text("Apellido materno de la madre", style: boldStyle),
          fb.textField(setState, 'p24'),
          Text("¿Desea ingresar información de un cuidador?", style: boldStyle),
          Column(
              children:
                  fb.radioGroup(["Si", "No"], 'p25', setState)),
          Text("DNI del cuidador/a", style: boldStyle),
          fb.numberField(setState, 'p26'),
          Text("Parentesco con el niño/a", style: boldStyle),
          Column(
              children: fb.radioGroup(
                  ["Tía/o", "Abuela/o", "Prima/o", "Hermana/o", "Otro"],
                  'p27',
                  setState,
                  addWidget: (widgets, value, index) => {
                        if (index == 4 &&
                            (value != null && value.toString() == 'Otro'))
                          {
                            widgets.add(fb.textField(setState, 'p28'))
                          }
                      })),
          Text("¿Cuenta con un número de celular de contacto?",
              style: boldStyle),
          Column(
              children:
                  fb.radioGroup(["Si", "No"], 'p29', setState)),
          if(fb.o['p29'] == 'Si')... [
                  Text("Número de celular", style: boldStyle),
                  fb.numberField(setState, 'p30'),
                  Text("¿A quién pertenece este celular?", style: boldStyle),
                  Column(
                      children: fb.radioGroup(["Madre", "Padre", "Cuidador/a"],
                          'p31', setState)),
                  Text("¿Su celular es smartphone?", style: boldStyle),
                  Column(
                      children: fb.radioGroup(
                          ["Si", "No"], 'p32', setState))
                ]
        ]
      },
      {
        'title': 'Información sobre la vivienda',
        'items': [
          Text("¿Cuenta con red de agua?", style: boldStyle),
          ...fb.checkboxGroup([
            'Red pública dentro de la vivienda',
            'Red pública fuera de la vivienda',
            'Manantial',
            'Río/acequia',
            'Pilón/Grifo público',
            'Camión cisterna',
            'Pozo en la casa/patio',
            'Agua de lluvia',
            'Pozo público',
            'Agua embotellada',
            'Otro (especifique)',
            'No sabe/no responde'
          ], 'p33_',setState,
              addWidget: (widgets, value, index) => {
                    if (index == 10 &&
                        (value != null && value.toString() == 'true'))
                      {
                        widgets.add(TextFormField(
                            minLines: 1,
                            onChanged: fb.setter(setState, 'p33_11_1'),
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: "Enter your text here...",
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline))
                      }
                  }),
          Text("¿¿Cuenta con red de desagüe?", style: boldStyle),
          ...fb.checkboxGroup([
            'Red pública dentro de la vivienda',
            'Letrina pública',
            'Red pública fuera de la vivienda',
            'No hay servicio',
            'Letrina exclusiva',
            'Otro (especifique)'
          ], 'p35_',
              setState,
              addWidget: (widgets, value, index) => {
                    if (index == 5 &&
                        (value != null && value.toString() == 'true'))
                      {
                        widgets.add(TextFormField(
                            minLines: 1,
                            onChanged: fb.setter(setState, 'p35_6_1'),
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: "Enter your text here...",
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline))
                      }
                  }),
          
          Text("¿Cuántas habitaciones usan en su hogar sólo para dormir?",
              style: boldStyle),
          fb.numberField(setState, 'p37'),
          Text("¿Cuántos miembros tiene su hogar?", style: boldStyle),
          fb.numberField(setState, 'p38'),
          Text("¿Cuántos miembros del hogar tienen menos de 5 años?",
              style: boldStyle),
          Text("Niños:"),
          fb.numberField(setState, 'p39_1'),
          Text("Niñas:"),
          fb.numberField(setState, 'p39_2'),
          Text("¿Cuál es su grado de instrucción?", style: boldStyle),
          Column(
              children: fb.radioGroup([
            'Sin educación',
            'Primaria incompleta',
            'Primaria completa',
            'Secundaria incompleta',
            'Secundaria completa',
            'Superior técnico incompleto',
            'Superior técnico completo'
          ], 'p40', setState)),
          Text("¿Cuál es su lengua materna?", style: boldStyle),
          Column(
              children: fb.radioGroup(
                  ["Quechua", "Español", "Otro (especifique)"],
                  'p41',
                  setState,
                  addWidget: (widgets, value, index) => {
                        if (index == 2 &&
                            (value != null &&
                                value.toString() == 'Otro (especifique)'))
                          {
                            widgets.add(TextFormField(
                                minLines: 1,
                                onChanged: fb.setter(setState, 'p42'),
                                maxLines: null,
                                decoration: InputDecoration(
                                    hintText: "Enter your text here...",
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline))
                          }
                      })),
          Text("¿Cuál es su lengua habitual?", style: boldStyle),
          Column(
              children: fb.radioGroup(
                  ["Quechua", "Español", "Otro (especifique)"],
                  'p43',
                  setState,
                  addWidget: (widgets, value, index) => {
                        if (index == 2 &&
                            (value != null &&
                                value.toString() == 'Otro (especifique)'))
                          {
                            widgets.add(TextFormField(
                                minLines: 1,
                                onChanged: fb.setter(setState, 'p44'),
                                maxLines: null,
                                decoration: InputDecoration(
                                    hintText: "Enter your text here...",
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline))
                          }
                      })),
          Text(
              "¿Actualmente, ¿su hogar recibe asistencia de algún programa social?",
              style: boldStyle),
          Column(
              children:
                  fb.radioGroup(["Si", "No"], 'p45', setState)),
          ...("o['p45']" == 'Si'
              ? [
                  /*Text("¿De cuál de los siguientes programas sociales?",
                      style: boldStyle),
                  ...fb.checkboxGroup([
                    'PRONOEI o QALIWARMA',
                    'Programa "Jóvenes Productivos"',
                    'Comedor popular',
                    'Vaso de leche',
                    'Wawa Wasi/Cuna Mas',
                    'Programa Trabaja Perú',
                    'Programa JUNTOS',
                    'Centro de Emergencia Mujer - CEM',
                    'Programa Beca 18',
                    'Programa "Impulsa Perú"',
                    'Programa de Alfabetización (PNA/DIALFA, antes PRONAMA)',
                    'Programa Bono Gas (FISE)',
                    'Pensión 65'
                  ], 'p46_',
                      onChanged: (value, name) => setO(setState, value, name))*/
                ]
              : []),
          Text("¿Algún miembro del hogar presenta algún tipo de discapacidad?",
              style: boldStyle),
          Column(
              children:
                  fb.radioGroup(["Si", "No"], 'p47', setState)),
          ...(fb.o['p47'] == 'Si'
              ? [
                  Text("Tipo de discapacidad", style: boldStyle),
                  ...fb.checkboxGroup([
                    'Visual',
                    'Auditiva',
                    'Musculoesquelética (física)',
                    'Intelectual',
                    'Visceral (Asociadas a enfermedades. Por ejemplo: Síndrome de Down, insuficiencia renal, enfermedades del dolor)',
                    'Otro (especifique)'
                  ], 'p48_',setState,
                      addWidget: (widgets, value, index) => {
                            if (index == 5 &&
                                (value != null && value.toString() == 'true'))
                              {
                                widgets.add(TextFormField(
                                    minLines: 1,
                                    onChanged: fb.setter(setState, 'p49'),
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        hintText: "Enter your text here...",
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline))
                              }
                          })
                ]
              : []),
          Text("Parentesco con el niño/a", style: boldStyle),
          Column(
              children: fb.radioGroup([
            'Madre',
            'Padre',
            'Tía/o',
            'Abuela/o',
            'Prima/o',
            'Hermana/o',
            'Otro'
          ], 'p50', setState)),
          ...("o['p47']" == 'Si'
              ? [
                  Text("¿Cuenta con el carnet de CONADIS?", style: boldStyle),
                  ...fb.radioGroup(
                      ['Si', 'No'],'p51', setState)
                ]
              : [])
        ]
      },
      {
        'title': 'Información sobre discapacidad',
        'items': [
          Text("¿El niño/niña presenta algún tipo de discapacidad?",
              style: boldStyle),
          Column(
              children:
                  fb.radioGroup(["Si", "No"], 'p52',setState)),
          ...(fb.o['p52'] == 'Si'
              ? [
                  Text("Tipo de discapacidad", style: boldStyle),
                  ...fb.checkboxGroup([
                    'Visual',
                    'Auditiva',
                    'Musculoesquelética (física)',
                    'Intelectual',
                    'Visceral (Asociadas a enfermedades. Por ejemplo: Síndrome de Down, insuficiencia renal, enfermedades del dolor)',
                    'Otro (especifique)'
                  ], 'p53_',setState,
                      addWidget: (widgets, value, index) => {
                            if (index == 5 &&
                                (value != null && value.toString() == 'true'))
                              {
                                widgets.add(TextFormField(
                                    minLines: 1,
                                    onChanged: fb.setter(setState, 'p54'),
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        hintText: "Enter your text here...",
                                        border: OutlineInputBorder()),
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline))
                              }
                          }),
                  Text("¿Cuenta con el carnet de CONADIS?", style: boldStyle),
                  ...fb.radioGroup(
                      ['Si', 'No'], 'p55', setState)
                ]
              : [])
        ]
      },
      {
        'title': 'Información sobre los controles del niño o niña',
        'items': [
          Text("En estos momentos, ¿cuenta con la tarjeta CRED de su niño/a?",
              style: boldStyle),
          ...fb.radioGroup([
            'Si',
            'Si, pero en la tarjeta no hay registro de ningún control',
            'No'
          ], 'p56', setState),
          Text("¿Tiene su control CRED al día, según su carnet?",
              style: boldStyle),
          Text("Fecha del último control"),
          fb.textField(setState, 'p57_1'),
          Text("Fecha del último control"),
          fb.textField(setState, 'p57_2'),
          Text("¿A qué Establecimiento de Salud asiste?", style: boldStyle),
          fb.textField(setState, 'p58'),
          Text("Otro (especifique)"),
          fb.textField(setState, 'p59'),
          Text("Peso del último control", style: boldStyle),
          fb.numberField(setState, 'p60'),
          Text("Talla del último control", style: boldStyle),
          fb.numberField(setState, 'p61'),
        ]
      },
      {
        'title': 'Información sobre dosaje de hemoglobina',
        'items': [
          Text("Fecha del último dosaje de hemoglobina", style: boldStyle),
          fb.dateField(context, 'p62', setState),
          Text("¿En caso se haya realizado en otra institución, ¿dónde?",
              style: boldStyle),
          fb.textField(setState, 'p63'),
          Text("¿Cuál fue el valor obtenido? (valor ajustado por altura)",
              style: boldStyle),
          fb.numberField(setState, 'p64'),
          Text("¿Ha recibido sobres de sangrecita en el último mes?",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p65', setState)
        ]
      },
      {
        'title': 'Suplementación',
        'items': [
          Text(
              "¿El niño/a ha recibido algún tipo de suplemento de hierro por el Establecimiento de Salud?",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p66', setState),
          Text(
              "¿El niño/a está consumiendo el suplemento entregado por el Establecimiento de Salud?",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p67', setState),
          Text(
              "¿Está consumiendo otro tipo de suplemento? (comprado, regalado, etc.)",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p68', setState,
              addWidget: (widgets, value, index) => {
                    if (index == 1 &&
                        (value != null && value.toString() == 'Si'))
                      {
                        widgets.add(Text(
                            "¿Qué suplemento? (Puede indicar el nombre comercial)",
                            style: boldStyle)),
                        widgets.add(TextFormField(
                            minLines: 1,
                            onChanged: fb.setter(setState, 'p69'),
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: "Enter your text here...",
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline))
                      }
                  }),
        ]
      },
      {
        'title': 'Signos de alarma',
        'items': [
          Text(
              "En los últimas 15 días su niño/a ha tenido alguno de estos síntomas o dolencias",
              style: boldStyle),
          ...fb.checkboxGroup([
            'Tos',
            'Nariz tapada/moco líquido',
            'Dolor de garganta',
            'Ronquera',
            'Dolor de oído o secreciones del oído',
            'Fiebre',
            'Respiración agitada',
            'Hundimiento de la piel entre costillas',
            'Ninguno',
            'No sabe / no responde'
          ], 'p70_',setState),
          Text("¿En los últimos 15 días, ¿Su niño/a ha tenido diarrea?",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p71', setState),
          Text("La próxima visita será el:", style: boldStyle),
          fb.dateField(context,'p72', setState),
        ]
      },
    ];

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.id==null?'Ficha Inicio de Niño':'Ficha Seguimiento de Niño'),
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 5.0,
      ),
      body: new Form(
          key: _formKey,
          child: Column(children: [
            Expanded(
                child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpansionPanelList(
                            animationDuration: Duration(milliseconds: 300),
                            expansionCallback: (int index, bool isExpanded) {
                              setState(() {
                                fb.expanded[index] = !isExpanded;
                              });
                            },
                            children: [...fb.expansionPanel(panels)])
                      ])),
            )),
            Padding(
                padding: EdgeInsets.all(10.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                        }
                        Widget cancelButton = TextButton(
                          child: Text("Cancel"),
                          onPressed: () {},
                        );
                        Widget continueButton = TextButton(
                          child: Text("Continue"),
                          onPressed: () {},
                        );

                        // set up the AlertDialog
                        AlertDialog alert = AlertDialog(
                          title: Text("AlertDialog"),
                          content: Text(
                              "Would you like to continue learning how to use Flutter alerts?"),
                          actions: [
                            cancelButton,
                            continueButton,
                          ],
                        );

                        // show the dialog
                        /*showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );*/

                        setState(() {
                          http2.post('/api/minsa/children',fb).then((response){
                              var result= json.decode(response.body);
                              if(fb.o['_id']==null){
                                if(result['_id']!=null)
context.replace('/children/'+result['_id']['\$oid']+'/edit');
else
context.replace('/children');
                              }
                              
                            });
                        });
                      },
                      label: const Text('Grabar'),
                      icon: Icon(Icons.save))
                ]))
          ])),
    );
  }
}