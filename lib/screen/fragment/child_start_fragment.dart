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
        'title': 'Datos personales del ni??o o ni??a',
        'items': [
          Text("DNI/partida de nacimiento/CUI", style: boldStyle),
          fb.numberField(setState, 'code'),
          Text("Nombre del ni??o/a", style: boldStyle),
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
          Text("Regi??n", style: boldStyle),
          fb.dropdownButton(
            ['--Seleccionar Opci??n--',...regions],'p5_7',setState,
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
              ['--Seleccionar Opci??n--',...provinces],'p5_8',setState,
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
                ['--Seleccionar Opci??n--',...districts],'p5_9',setState,
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
        'title': 'Ubicaci??n de la vivienda',
        'items': [
          Text("Geolocalizaci??n:", style: boldStyle),
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
                  ['Avenida', 'Calle', 'Jir??n', 'Sin eje vial'],
                  'p9',setState)),
          Text("Direcci??n Actual:", style: boldStyle),
          fb.textField(setState, 'p10'),
          Text("Referencia de la Direcci??n:", style: boldStyle),
          fb.textField(setState, 'p11'),
          Row(
            children: <Widget>[
              Expanded(child: Text("Corregir Informaci??n")),
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
          Text("??Desea ingresar informaci??n de un cuidador?", style: boldStyle),
          Column(
              children:
                  fb.radioGroup(["Si", "No"], 'p25', setState)),
          Text("DNI del cuidador/a", style: boldStyle),
          fb.numberField(setState, 'p26'),
          Text("Parentesco con el ni??o/a", style: boldStyle),
          Column(
              children: fb.radioGroup(
                  ["T??a/o", "Abuela/o", "Prima/o", "Hermana/o", "Otro"],
                  'p27',
                  setState,
                  addWidget: (widgets, value, index) => {
                        if (index == 4 &&
                            (value != null && value.toString() == 'Otro'))
                          {
                            widgets.add(fb.textField(setState, 'p28'))
                          }
                      })),
          Text("??Cuenta con un n??mero de celular de contacto?",
              style: boldStyle),
          Column(
              children:
                  fb.radioGroup(["Si", "No"], 'p29', setState)),
          if(fb.o['p29'] == 'Si')... [
                  Text("N??mero de celular", style: boldStyle),
                  fb.numberField(setState, 'p30'),
                  Text("??A qui??n pertenece este celular?", style: boldStyle),
                  Column(
                      children: fb.radioGroup(["Madre", "Padre", "Cuidador/a"],
                          'p31', setState)),
                  Text("??Su celular es smartphone?", style: boldStyle),
                  Column(
                      children: fb.radioGroup(
                          ["Si", "No"], 'p32', setState))
                ]
        ]
      },
      {
        'title': 'Informaci??n sobre la vivienda',
        'items': [
          Text("??Cuenta con red de agua?", style: boldStyle),
          ...fb.checkboxGroup([
            'Red p??blica dentro de la vivienda',
            'Red p??blica fuera de la vivienda',
            'Manantial',
            'R??o/acequia',
            'Pil??n/Grifo p??blico',
            'Cami??n cisterna',
            'Pozo en la casa/patio',
            'Agua de lluvia',
            'Pozo p??blico',
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
          Text("????Cuenta con red de desag??e?", style: boldStyle),
          ...fb.checkboxGroup([
            'Red p??blica dentro de la vivienda',
            'Letrina p??blica',
            'Red p??blica fuera de la vivienda',
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
          
          Text("??Cu??ntas habitaciones usan en su hogar s??lo para dormir?",
              style: boldStyle),
          fb.numberField(setState, 'p37'),
          Text("??Cu??ntos miembros tiene su hogar?", style: boldStyle),
          fb.numberField(setState, 'p38'),
          Text("??Cu??ntos miembros del hogar tienen menos de 5 a??os?",
              style: boldStyle),
          Text("Ni??os:"),
          fb.numberField(setState, 'p39_1'),
          Text("Ni??as:"),
          fb.numberField(setState, 'p39_2'),
          Text("??Cu??l es su grado de instrucci??n?", style: boldStyle),
          Column(
              children: fb.radioGroup([
            'Sin educaci??n',
            'Primaria incompleta',
            'Primaria completa',
            'Secundaria incompleta',
            'Secundaria completa',
            'Superior t??cnico incompleto',
            'Superior t??cnico completo'
          ], 'p40', setState)),
          Text("??Cu??l es su lengua materna?", style: boldStyle),
          Column(
              children: fb.radioGroup(
                  ["Quechua", "Espa??ol", "Otro (especifique)"],
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
          Text("??Cu??l es su lengua habitual?", style: boldStyle),
          Column(
              children: fb.radioGroup(
                  ["Quechua", "Espa??ol", "Otro (especifique)"],
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
              "??Actualmente, ??su hogar recibe asistencia de alg??n programa social?",
              style: boldStyle),
          Column(
              children:
                  fb.radioGroup(["Si", "No"], 'p45', setState)),
          ...("o['p45']" == 'Si'
              ? [
                  /*Text("??De cu??l de los siguientes programas sociales?",
                      style: boldStyle),
                  ...fb.checkboxGroup([
                    'PRONOEI o QALIWARMA',
                    'Programa "J??venes Productivos"',
                    'Comedor popular',
                    'Vaso de leche',
                    'Wawa Wasi/Cuna Mas',
                    'Programa Trabaja Per??',
                    'Programa JUNTOS',
                    'Centro de Emergencia Mujer - CEM',
                    'Programa Beca 18',
                    'Programa "Impulsa Per??"',
                    'Programa de Alfabetizaci??n (PNA/DIALFA, antes PRONAMA)',
                    'Programa Bono Gas (FISE)',
                    'Pensi??n 65'
                  ], 'p46_',
                      onChanged: (value, name) => setO(setState, value, name))*/
                ]
              : []),
          Text("??Alg??n miembro del hogar presenta alg??n tipo de discapacidad?",
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
                    'Musculoesquel??tica (f??sica)',
                    'Intelectual',
                    'Visceral (Asociadas a enfermedades. Por ejemplo: S??ndrome de Down, insuficiencia renal, enfermedades del dolor)',
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
          Text("Parentesco con el ni??o/a", style: boldStyle),
          Column(
              children: fb.radioGroup([
            'Madre',
            'Padre',
            'T??a/o',
            'Abuela/o',
            'Prima/o',
            'Hermana/o',
            'Otro'
          ], 'p50', setState)),
          ...("o['p47']" == 'Si'
              ? [
                  Text("??Cuenta con el carnet de CONADIS?", style: boldStyle),
                  ...fb.radioGroup(
                      ['Si', 'No'],'p51', setState)
                ]
              : [])
        ]
      },
      {
        'title': 'Informaci??n sobre discapacidad',
        'items': [
          Text("??El ni??o/ni??a presenta alg??n tipo de discapacidad?",
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
                    'Musculoesquel??tica (f??sica)',
                    'Intelectual',
                    'Visceral (Asociadas a enfermedades. Por ejemplo: S??ndrome de Down, insuficiencia renal, enfermedades del dolor)',
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
                  Text("??Cuenta con el carnet de CONADIS?", style: boldStyle),
                  ...fb.radioGroup(
                      ['Si', 'No'], 'p55', setState)
                ]
              : [])
        ]
      },
      {
        'title': 'Informaci??n sobre los controles del ni??o o ni??a',
        'items': [
          Text("En estos momentos, ??cuenta con la tarjeta CRED de su ni??o/a?",
              style: boldStyle),
          ...fb.radioGroup([
            'Si',
            'Si, pero en la tarjeta no hay registro de ning??n control',
            'No'
          ], 'p56', setState),
          Text("??Tiene su control CRED al d??a, seg??n su carnet?",
              style: boldStyle),
          Text("Fecha del ??ltimo control"),
          fb.textField(setState, 'p57_1'),
          Text("Fecha del ??ltimo control"),
          fb.textField(setState, 'p57_2'),
          Text("??A qu?? Establecimiento de Salud asiste?", style: boldStyle),
          fb.textField(setState, 'p58'),
          Text("Otro (especifique)"),
          fb.textField(setState, 'p59'),
          Text("Peso del ??ltimo control", style: boldStyle),
          fb.numberField(setState, 'p60'),
          Text("Talla del ??ltimo control", style: boldStyle),
          fb.numberField(setState, 'p61'),
        ]
      },
      {
        'title': 'Informaci??n sobre dosaje de hemoglobina',
        'items': [
          Text("Fecha del ??ltimo dosaje de hemoglobina", style: boldStyle),
          fb.dateField(context, 'p62', setState),
          Text("??En caso se haya realizado en otra instituci??n, ??d??nde?",
              style: boldStyle),
          fb.textField(setState, 'p63'),
          Text("??Cu??l fue el valor obtenido? (valor ajustado por altura)",
              style: boldStyle),
          fb.numberField(setState, 'p64'),
          Text("??Ha recibido sobres de sangrecita en el ??ltimo mes?",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p65', setState)
        ]
      },
      {
        'title': 'Suplementaci??n',
        'items': [
          Text(
              "??El ni??o/a ha recibido alg??n tipo de suplemento de hierro por el Establecimiento de Salud?",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p66', setState),
          Text(
              "??El ni??o/a est?? consumiendo el suplemento entregado por el Establecimiento de Salud?",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p67', setState),
          Text(
              "??Est?? consumiendo otro tipo de suplemento? (comprado, regalado, etc.)",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p68', setState,
              addWidget: (widgets, value, index) => {
                    if (index == 1 &&
                        (value != null && value.toString() == 'Si'))
                      {
                        widgets.add(Text(
                            "??Qu?? suplemento? (Puede indicar el nombre comercial)",
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
              "En los ??ltimas 15 d??as su ni??o/a ha tenido alguno de estos s??ntomas o dolencias",
              style: boldStyle),
          ...fb.checkboxGroup([
            'Tos',
            'Nariz tapada/moco l??quido',
            'Dolor de garganta',
            'Ronquera',
            'Dolor de o??do o secreciones del o??do',
            'Fiebre',
            'Respiraci??n agitada',
            'Hundimiento de la piel entre costillas',
            'Ninguno',
            'No sabe / no responde'
          ], 'p70_',setState),
          Text("??En los ??ltimos 15 d??as, ??Su ni??o/a ha tenido diarrea?",
              style: boldStyle),
          ...fb.radioGroup(['Si', 'No'], 'p71', setState),
          Text("La pr??xima visita ser?? el:", style: boldStyle),
          fb.dateField(context,'p72', setState),
        ]
      },
    ];

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.id==null?'Ficha Inicio de Ni??o':'Ficha Seguimiento de Ni??o'),
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