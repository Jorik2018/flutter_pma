import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
//https://www.kindacode.com/article/flutter-hive-database/

class ChildStartFragment extends StatefulWidget {

Function? navigateTo;

    ChildStartFragment({this.navigateTo});

    @override
    _ChildStartFragmentState createState() => new _ChildStartFragmentState();
}

Map o = {'p72':'2023-12-12'};
Map ctrl={};
//o['p27']='2023-12-12';


Function setO=(Function setState,Object? value,String? name){
    setState(() {
        o[name]=value;
    });
};

Function  setterC = (Function setState,name){
    return (Object? value){
        setState(() {
            ctrl[name]=value;
        });
    };
};

Function  setter = (Function setState,name){
    return (Object? value){
        setState(() {
            o[name]=value;
        });
    };
};

Function  _TextField=(Object? value,Function(Object?) onChanged,
{TextAlign textAlign=TextAlign.left,
bool readOnly=false,
Function()? onTap
}){
    TextEditingController dateinput = TextEditingController();
    return TextFormField(
      textAlign: textAlign,
        controller: dateinput..text=value!=null?value.toString():'',
        onChanged: onChanged,
        decoration: InputDecoration(hintText: "Enter your text here...",border: OutlineInputBorder()),
        inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
        ],
        readOnly: readOnly,
        onTap: onTap,
    );
};

Function  _NumberField=(Object? value,Function(Object?) onChanged){
    TextEditingController dateinput = TextEditingController();
    return TextFormField(
        controller: dateinput..text=value!=null?value.toString():'',
        onChanged: onChanged,
        decoration: InputDecoration(hintText: "Enter your number here...",border: OutlineInputBorder()),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
        ],
    );
};

Function  _DateField=(
        BuildContext context,
        Object? value,Function(Object?) onChanged,{
          TextAlign textAlign=TextAlign.center,
        String? type,
        DateTime? firstDate,
        DateTime? lastDate,
        
    }){
    TextEditingController dateinput = TextEditingController();
    return TextFormField(
        controller: dateinput..text=value!=null?value.toString():'',
        textAlign: textAlign,
        decoration: InputDecoration( 
            icon: Icon(Icons.calendar_today),
            labelText: "Enter Date" 
        ),
        readOnly: true,
        onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context, 
                initialDate: DateTime.now(),
                firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime(2101)
            );
            Object value=pickedDate != null?DateFormat('yyyy-MM-dd').format(pickedDate):'';
            onChanged(value);
        },
    );
};

class _ChildStartFragmentState extends State<ChildStartFragment> {

    final _formKey = GlobalKey<FormState>();
    TextEditingController dateinput = TextEditingController(); 
    TextStyle boldStyle=TextStyle(fontWeight: FontWeight.bold);
    TextStyle bold20Style=TextStyle(fontWeight: FontWeight.bold,fontSize: 20);
    ButtonStyle buttonStyle=TextButton.styleFrom(
      padding: const EdgeInsets.all(16.0),
      primary: Colors.white,
      backgroundColor: Colors.blue,
      textStyle: const TextStyle(fontSize: 20)
    );
    final _shoppingBox = Hive.box('shopping_box');
    Position? _position;

    List<Widget> _RadioGroup(List<String> options, Object value,void Function(Object?)? getter,
        {void Function(List<Widget>,Object?,int)? addWidget}) {
        return (options.asMap().entries).expand((entry){
            int index = entry.key;
            var item = entry.value;
            List<Widget> widgets=[];
            widgets.add(ListTile(
                title: Text(item),
                leading: Radio(
                    groupValue: value,
                    value: item,
                    onChanged: getter,
                    /*hoverColor: Colors.yellow,
                    activeColor: Colors.pink,
                    focusColor: Colors.purple,
                    fillColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                        return Colors.orange;
                        } else if (states.contains(MaterialState.selected)) {
                        return Colors.teal;
                        } if (states.contains(MaterialState.focused)) {
                        return Colors.blue;
                        } else {
                        return Colors.black12;
                        }
                    }),
                    overlayColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                        if (states.contains(MaterialState.hovered)) {
                            return Colors.lightGreenAccent;
                        } if (states.contains(MaterialState.focused)) {
                            return Colors.brown;
                        } else {
                            return Colors.white;
                        }
                    }),*/
                    splashRadius: 35,
                    toggleable: true,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
            ));
            if(addWidget!=null){
                addWidget(widgets,value,index);
            }
            return widgets.toList();
        }).toList();
    }

    List<Widget> _CheckboxGroup(
        List<String> options, 
        String valueName,
        {
            required Object? Function(String) getValue,
            void Function(Object?,String?)? onChanged,
            void Function(List<Widget>,Object?,int)? addWidget
        }) {
        return (options.asMap().entries).expand((entry){
            int index = entry.key;
            var item = entry.value;
            String valueName2=valueName+(index+1).toString(); 
            List<Widget> widgets=[];
            Object? value=getValue(valueName2);
            widgets.add(CheckboxListTile(
                title: Text(item),
                controlAffinity: ListTileControlAffinity.leading,
                value: value!=null&&value.toString()=='true',
                onChanged: (Object? value) {
                    onChanged!(value,valueName2);
                }
            ));
            if(addWidget!=null){
                addWidget(widgets,value,index);
            }
            return widgets.toList();
        }).toList();
    }

    List<ExpansionPanel> _ExpansionPanel(List panels) {
        int index=-1;
        return (panels.map<ExpansionPanel>((e){
            index++;
            return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                        title: Text(e['title'],style:bold20Style),
                    );
                },
                isExpanded:o[index]!=null&&o[index],
                body:Padding(
                    padding: EdgeInsets.all(15.0),
                    child: e['items']!=null?Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:e['items'].cast<Widget>()
                    ):
                    Text('Empty!')
                ),
            );
        })).toList();
    }

    Widget _DropdownButton(List options, Object value,void Function(Object?)? setter){
        return DropdownButton(
          value: value,
          items:['--Seleccionar Opción--',...options].map(
              (code) =>new DropdownMenuItem(value: code, child: new Text(code))
          ).toList(),
          onChanged:setter,
          isExpanded: true,
      );
    }

    void _getCurrentLocation() async {
        Position position = await _determinePosition();
        setState(() {
            o['lat'] = position.latitude;
            o['lon'] = position.longitude;
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
            return Future.error('Location permissions are permanently denied, we cannot request permissions.');
        }
        return await Geolocator.getCurrentPosition();
    }

    @override
    Widget build(BuildContext context) {
        
        List panels=[
            {
                'title':'Datos personales del niño o niña',
                'items':[
                    Text("DNI/partida de nacimiento/CUI",style:boldStyle),
                    _NumberField(
                        o['code'],
                        setter(setState,'code')
                    ),
                    Text("Nombre del niño/a",style:boldStyle),
                    _TextField(
                        o['p1'],
                        setter(setState,'p1')
                    ),
                    Text("Apellido paterno:",style:boldStyle),
                    Row(children: <Widget>[
                        Expanded(child:_TextField(
                            o['p2'],
                            setter(setState,'p2')
                        )),
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                                setState(() {
                                /// _isEnable = true;
                                });
                            }
                        )
                    ]),
                    Text("Apellido materno",style:boldStyle),
                    _TextField(
                        o['p3'],
                        setter(setState,'p3')
                    ),
                    Text("Sexo",style:boldStyle),
                    Column(
                        children:_RadioGroup(
                            [
                                'Masculino',
                                'Femenino'
                            ],
                            o['p4'],
                            setter(setState,'p4')
                        )
                    ),
                    Text("Fecha nacimiento",style:boldStyle),
                    _DateField(
                        context,
                        o['birthday'],
                        setter(setState,'birthday')
                    ),
                    Text("Tipo de seguro al que se encuentra afiliado/a",style:boldStyle),
                    Column(
                        children:_RadioGroup(
                            [
                                'SIS',
                                'ESSALUD',
                                'FAP',
                                'PNP',
                                'Privado',
                                'No tiene seguro'
                            ],
                            o['p6'],
                            setter(setState,'p6')
                        )
                    ),
                    Text("Región",style:boldStyle),
                    //Row(children:[Expanded(
                      //  child:
                        _DropdownButton(
                            ['AAA','BBBB','CCCC'],
                            o['p5_7'],
                            setter(setState,'p5_7')
                        )
                    //)])
                ]
            },
            {
                'title':'Ubicación de la vivienda',
                'items':[
                Text("Geolocalización:",style:boldStyle),
                _TextField(
                  o['lat']!=null&&o['lon']!=null?
                  (o['lat'].toString()+','+o['lon'].toString()):"",
                  (value){},
                  textAlign:TextAlign.center,
                  readOnly:true,
                  onTap:()=>widget.navigateTo!(5,options:o)
                ),
                Row(
                  mainAxisAlignment:MainAxisAlignment.end,
                  children:[
                    TextButton.icon(
                      icon:Icon(Icons.location_on_rounded),
                      style: buttonStyle,
                      onPressed: () async { _getCurrentLocation();},
                      label: const Text('Obtener Coordenadas')
                    )
                  ]
                ),
                Text("Eje Vial:",style:boldStyle),
                Column(
                    children:_RadioGroup(
                        [
                            'Avenida',
                            'Calle',
                            'Jirón',
                            'Sin eje vial'
                        ],
                        o['p9'],
                        setter(setState,'p9')
                    )
                ),
                Text("Dirección Actual:",style:boldStyle),
                _TextField(
                    o['p10'],
                    setter(setState,'p10')
                ),
                Text("Referencia de la Dirección:",style:boldStyle),
                _TextField(
                    o['p11'],
                    setter(setState,'p11')
                ),
                Row(
                    children: <Widget>[
                        Expanded(child: Text("Corregir Información")),
                        Switch(
                            value: ctrl['change-location']!=null&&ctrl['change-location']==true,
                            onChanged:setterC(setState,'change-location'),
                        ),
                    ],
                )

              ]
            },
            {
                'title':'Datos de la madre, padre o cuidador/a',
                'items':[
                    Text("Nombres del padre",style:boldStyle),
                    _TextField(
                        o['p13'],
                        setter(setState,'p13')
                    ),
                    Text("Apellido paterno del padre",style:boldStyle),
                    _TextField(
                        o['p14'],
                        setter(setState,'p14')
                    ),
                    Text("Apellido materno del padre",style:boldStyle),
                    _TextField(
                        o['p15'],
                        setter(setState,'p15')
                    ),
                    Text("DNI del padre",style:boldStyle),
                    _NumberField(
                        o['p16'],
                        setter(setState,'p16')
                    ),
                    Text("Nombres de la madre",style:boldStyle),
                    _TextField(
                        o['p17'],
                        setter(setState,'p17')
                    ),
                    Text("Apellido paterno de la madre",style:boldStyle),
                    _TextField(
                        o['p18'],
                        setter(setState,'p18')
                    ),
                    Text("Apellido materno de la madre",style:boldStyle),
                    _TextField(
                        o['p19'],
                        setter(setState,'p19')
                    ),
                    Text("Fecha de nacimiento de la madre",style:boldStyle),
                    _DateField(
                        context,
                        o['p20'],
                        setter(setState,'p20')
                    ),
                    Text("DNI de la madre",style:boldStyle),
                    _NumberField(
                        o['p21'],
                        setter(setState,'p21')
                    ),
                    Text("Nombres de la madre",style:boldStyle),
                    _TextField(
                        o['p22'],
                        setter(setState,'p22')
                    ),
                    Text("Apellido paterno de la madre",style:boldStyle),
                    _TextField(
                        o['p2'],
                        setter(setState,'p23')
                    ),
                    Text("Apellido materno de la madre",style:boldStyle),
                    _TextField(
                        o['p24'],
                        setter(setState,'p24')
                    ),
                    Text("¿Desea ingresar información de un cuidador?",style:boldStyle),
                    Column(
                        children:_RadioGroup(
                            [
                                "Si",
                                "No"
                            ], 
                            o['p25'],
                            setter(setState,'p25')
                        )
                    ),
                    Text("DNI del cuidador/a",style:boldStyle),
                    _NumberField(
                        o['p26'],
                        setter(setState,'p26')
                    ),
                    Text("Parentesco con el niño/a",style:boldStyle),
                    Column(
                        children:_RadioGroup(
                            [
                              "Tía/o",
                              "Abuela/o",
                              "Prima/o",
                              "Hermana/o",
                              "Otro"
                            ], 
                            o['p27'],
                            setter(setState,'p27'),
                            addWidget:(widgets,value,index)=>{
                                if(index==4&&(value!=null&&value.toString()=='Otro')){
                                    widgets.add(_TextField(
                                        value:o['p28'],
                                        onChanged: setter(setState,'p28')
                                    ))
                                }
                            }
                        )
                    ),
                    Text("¿Cuenta con un número de celular de contacto?",style:boldStyle),
                    Column(
                        children:_RadioGroup(
                            [
                                "Si",
                                "No"
                            ], 
                            o['p29'],
                            setter(setState,'p29')
                        )
                    ),
                    ...o['p29']=='Si'?[
                      Text("Número de celular",style:boldStyle),
                      _NumberField(
                          o['p30'],
                          setter(setState,'p30')
                      ),
                      Text("¿A quién pertenece este celular?",style:boldStyle),
                      Column(
                          children:_RadioGroup(
                              [
                                  "Madre",
                                  "Padre",
                                  "Cuidador/a"
                              ], 
                              o['p31'],
                              setter(setState,'p31')
                          )
                      ),
                      Text("¿Su celular es smartphone?",style:boldStyle),
                      Column(
                          children:_RadioGroup(
                              [
                                  "Si",
                                  "No"
                              ], 
                              o['p32'],
                              setter(setState,'p32')
                          )
                      )
                    ]:[]
                ]
            },
            {
              'title':'Información sobre la vivienda',
              'items':[
                Text("¿Cuenta con red de agua?",style:boldStyle),
                    ..._CheckboxGroup(
                        [
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
                        ],
                        'p33_',
                        getValue:(valueName)=>o[valueName],
                        onChanged:(value,name)=>setO(setState,value,name),
                        addWidget:(widgets,value,index)=>{
                            if(index==10&&(value!=null&&value.toString()=='true')){
                                widgets.add(TextFormField(
                                    minLines: 1,
                                    onChanged: setter(setState,'p33_11_1'),
                                    maxLines: null,
                                    decoration: InputDecoration(hintText: "Enter your text here...",border: OutlineInputBorder()),
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline
                                ))
                            }
                        }
                    ),
                    Text("¿¿Cuenta con red de desagüe?",style:boldStyle),
                    ..._CheckboxGroup(
                        [
                            'Red pública dentro de la vivienda',
                            'Letrina pública',
                            'Red pública fuera de la vivienda',
                            'No hay servicio',
                            'Letrina exclusiva',
                            'Otro (especifique)'
                        ],
                        'p35_',
                        getValue:(valueName)=>o[valueName],
                        onChanged:(value,name)=>setO(setState,value,name),
                        addWidget:(widgets,value,index)=>{
                            if(index==5&&(value!=null&&value.toString()=='true')){
                                widgets.add(TextFormField(
                                    minLines: 1,
                                    onChanged: setter(setState,'p35_6_1'),
                                    maxLines: null,
                                    decoration: InputDecoration(hintText: "Enter your text here...",border: OutlineInputBorder()),
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline
                                ))
                            }
                        }
                    ),
                    Text("¿Cuántas habitaciones usan en su hogar sólo para dormir?",style:boldStyle),
                    _NumberField(
                      o['p37'],
                      setter(setState,'p37')
                    ),
                    Text("¿Cuántos miembros tiene su hogar?",style:boldStyle),
                    _NumberField(
                      o['p38'],
                      setter(setState,'p38')
                    ),
                    Text("¿Cuántos miembros del hogar tienen menos de 5 años?",style:boldStyle),
                    Text("Niños:"),
                    _NumberField(
                      o['p39_1'],
                        setter(setState,'p39_1')
                    ),
                    Text("Niñas:"),
                    _NumberField(
                      o['p39_2'],
                        setter(setState,'p39_2')
                    ),
                    Text("¿Cuál es su grado de instrucción?",style:boldStyle),
                    Column(
                        children:_RadioGroup(
                            [
                                'Sin educación',
                                'Primaria incompleta',
                                'Primaria completa',
                                'Secundaria incompleta',
                                'Secundaria completa',
                                'Superior técnico incompleto',
                                'Superior técnico completo'
                            ],
                            o['p40'],
                            setter(setState,'p40')
                        )
                    ),
                    Text("¿Cuál es su lengua materna?",style:boldStyle),
                    Column(
                        children:_RadioGroup(
                            [
                                "Quechua",
                                "Español",
                                "Otro (especifique)"
                            ], 
                            o['p41'],
                            setter(setState,'p41'),
                            addWidget:(widgets,value,index)=>{
                                if(index==2&&(value!=null&&value.toString()=='Otro (especifique)')){
                                    widgets.add(TextFormField(
                                        minLines: 1,
                                        onChanged: setter(setState,'p42'),
                                        maxLines: null,
                                        decoration: InputDecoration(hintText: "Enter your text here...",border: OutlineInputBorder()),
                                        keyboardType: TextInputType.multiline,
                                        textInputAction: TextInputAction.newline
                                    ))
                                }
                            }
                        )
                    ),
                    Text("¿Cuál es su lengua habitual?",style:boldStyle),
                    Column(
                        children:_RadioGroup(
                            [
                                "Quechua",
                                "Español",
                                "Otro (especifique)"
                            ], 
                            o['p43'],
                            setter(setState,'p43'),
                            addWidget:(widgets,value,index)=>{
                                if(index==2&&(value!=null&&value.toString()=='Otro (especifique)')){
                                    widgets.add(TextFormField(
                                        minLines: 1,
                                        onChanged: setter(setState,'p44'),
                                        maxLines: null,
                                        decoration: InputDecoration(hintText: "Enter your text here...",border: OutlineInputBorder()),
                                        keyboardType: TextInputType.multiline,
                                        textInputAction: TextInputAction.newline
                                    ))
                                }
                            }
                        )
                    ),
                    Text("¿Actualmente, ¿su hogar recibe asistencia de algún programa social?",style:boldStyle),                            
                    Column(
                        children:_RadioGroup(
                            [
                                "Si",
                                "No"
                            ], 
                            o['p45'],
                            setter(setState,'p45')
                        )
                    ),
                    ...(
                        o['p45']=='Si'?
                        [
                            Text("¿De cuál de los siguientes programas sociales?",style:boldStyle),
                            ..._CheckboxGroup(
                                [
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
                                ],
                                'p46_',
                                getValue:(valueName)=>o[valueName],
                                onChanged:(value,name)=>setO(setState,value,name)
                            )
                        ]:
                        []
                    ),
                    Text("¿Algún miembro del hogar presenta algún tipo de discapacidad?",style:boldStyle),                            
                    Column(
                        children:_RadioGroup(
                            [
                                "Si",
                                "No"
                            ], 
                            o['p47'],
                            setter(setState,'p47')
                        )
                    ),
                    ...(
                        o['p47']=='Si'?
                        [
                            Text("Tipo de discapacidad",style:boldStyle),
                            ..._CheckboxGroup(
                                [
                                    'Visual',
                                    'Auditiva',
                                    'Musculoesquelética (física)',
                                    'Intelectual',
                                    'Visceral (Asociadas a enfermedades. Por ejemplo: Síndrome de Down, insuficiencia renal, enfermedades del dolor)',
                                    'Otro (especifique)'
                                ],
                                'p48_',
                                getValue:(valueName)=>o[valueName],
                                onChanged:(value,name)=>setO(setState,value,name),
                                addWidget:(widgets,value,index)=>{
                                    if(index==5&&(value!=null&&value.toString()=='true')){
                                        widgets.add(TextFormField(
                                            minLines: 1,
                                            onChanged: setter(setState,'p49'),
                                            maxLines: null,
                                            decoration: InputDecoration(hintText: "Enter your text here...",border: OutlineInputBorder()),
                                            keyboardType: TextInputType.multiline,
                                            textInputAction: TextInputAction.newline
                                        ))
                                    }
                                }
                            )
                        ]:
                        []
                    ),
                    Text("Parentesco con el niño/a",style:boldStyle),
                    Column(
                        children:_RadioGroup(
                            [
                                'Madre',
                                'Padre',
                                'Tía/o',
                                'Abuela/o',
                                'Prima/o',
                                'Hermana/o',
                                'Otro'
                            ], 
                            o['p50'],
                            setter(setState,'p50')
                        )
                    ),
                    ...(
                        o['p47']=='Si'?
                        [
                            Text("¿Cuenta con el carnet de CONADIS?",style:boldStyle),
                            ..._RadioGroup(
                                [
                                    'Si',
                                    'No'
                                ], 
                                o['p51'],
                                setter(setState,'p51')
                            )
                        ]:
                        []
                    )
              ]
            },
            {
                'title':'Información sobre discapacidad',
                'items':[
                    Text("¿El niño/niña presenta algún tipo de discapacidad?",style:boldStyle),                            
                    Column(
                        children:_RadioGroup(
                            [
                                "Si",
                                "No"
                            ], 
                            o['p52'],
                            setter(setState,'p52')
                        )
                    ),
                    ...(
                        o['p52']=='Si'?
                        [
                            Text("Tipo de discapacidad",style:boldStyle),
                            ..._CheckboxGroup(
                                [
                                    'Visual',
                                    'Auditiva',
                                    'Musculoesquelética (física)',
                                    'Intelectual',
                                    'Visceral (Asociadas a enfermedades. Por ejemplo: Síndrome de Down, insuficiencia renal, enfermedades del dolor)',
                                    'Otro (especifique)'
                                ],
                                'p53_',
                                getValue:(valueName)=>o[valueName],
                                onChanged:(value,name)=>setO(setState,value,name),
                                addWidget:(widgets,value,index)=>{
                                    if(index==5&&(value!=null&&value.toString()=='true')){
                                        widgets.add(TextFormField(
                                            minLines: 1,
                                            onChanged: setter(setState,'p54'),
                                            maxLines: null,
                                            decoration: InputDecoration(hintText: "Enter your text here...",border: OutlineInputBorder()),
                                            keyboardType: TextInputType.multiline,
                                            textInputAction: TextInputAction.newline
                                        ))
                                    }
                                }
                            ),
                            Text("¿Cuenta con el carnet de CONADIS?",style:boldStyle),
                            ..._RadioGroup(
                                [
                                    'Si',
                                    'No'
                                ], 
                                o['p55'],
                                setter(setState,'p55')
                            )
                        ]:
                        []
                    )
                ]
            },
            {
                'title':'Información sobre los controles del niño o niña',
                'items':[
                    Text("En estos momentos, ¿cuenta con la tarjeta CRED de su niño/a?",style:boldStyle),
                    ..._RadioGroup(
                        [
                            'Si',
                            'Si, pero en la tarjeta no hay registro de ningún control',
                            'No'
                        ], 
                        o['p56'],
                        setter(setState,'p56')
                    ),
                    Text("¿Tiene su control CRED al día, según su carnet?",style:boldStyle),
                    Text("Fecha del último control"),
                    _TextField(
                        o['p57_1'],
                        setter(setState,'p57_1')
                    ),
                    Text("Fecha del último control"),
                    _TextField(
                        o['p57_2'],
                        setter(setState,'p57_2')
                    ),
                    Text("¿A qué Establecimiento de Salud asiste?",style:boldStyle),
                    _TextField(
                        o['p58'],
                        setter(setState,'p58')
                    ),
                    Text("Otro (especifique)"),
                    _TextField(
                        o['p59'],
                        setter(setState,'p59')
                    ),
                    Text("Peso del último control",style:boldStyle),
                    _NumberField(
                        o['p60'],
                        setter(setState,'p60')
                    ),
                    Text("Talla del último control",style:boldStyle),
                    _NumberField(
                        o['p61'],
                        setter(setState,'p61')
                    ),
                ]
            },
            {
                'title':'Información sobre dosaje de hemoglobina',
                'items':[
                    Text("Fecha del último dosaje de hemoglobina",style:boldStyle),
                    _DateField(
                        context,
                        o['p62'],
                        setter(setState,'p62')
                    ),
                    Text("¿En caso se haya realizado en otra institución, ¿dónde?",style:boldStyle),
                    _TextField(
                        o['p63'],
                        setter(setState,'p63')
                    ),
                    Text("¿Cuál fue el valor obtenido? (valor ajustado por altura)",style:boldStyle),
                    _NumberField(
                        o['p64'],
                        setter(setState,'p64')
                    ),
                    Text("¿Ha recibido sobres de sangrecita en el último mes?",style:boldStyle),
                    ..._RadioGroup(
                        [
                            'Si',
                            'No'
                        ], 
                        o['p65'],
                        setter(setState,'p65')
                    )
                ]
            },
            {
                'title':'Suplementación',
                'items':[
                    Text("¿El niño/a ha recibido algún tipo de suplemento de hierro por el Establecimiento de Salud?",style:boldStyle),
                    ..._RadioGroup(
                        [
                            'Si',
                            'No'
                        ], 
                        o['p66'],
                        setter(setState,'p66')
                    ),
                    Text("¿El niño/a está consumiendo el suplemento entregado por el Establecimiento de Salud?",style:boldStyle),
                    ..._RadioGroup(
                        [
                            'Si',
                            'No'
                        ], 
                        o['p67'],
                        setter(setState,'p67')
                    ),
                    Text("¿Está consumiendo otro tipo de suplemento? (comprado, regalado, etc.)",style:boldStyle),
                    ..._RadioGroup(
                        [
                            'Si',
                            'No'
                        ], 
                        o['p68'],
                        setter(setState,'p68'),
                        addWidget:(widgets,value,index)=>{
                            if(index==1&&(value!=null&&value.toString()=='Si')){
                                widgets.add(Text("¿Qué suplemento? (Puede indicar el nombre comercial)",style:boldStyle)),
                                widgets.add(TextFormField(
                                    minLines: 1,
                                    onChanged: setter(setState,'p69'),
                                    maxLines: null,
                                    decoration: InputDecoration(hintText: "Enter your text here...",border: OutlineInputBorder()),
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline
                                ))
                            }
                        }
                    ),
                ]
            },
            {
                'title':'Signos de alarma',
                'items':[
                    Text("En los últimas 15 días su niño/a ha tenido alguno de estos síntomas o dolencias",style:boldStyle),
                    ..._CheckboxGroup(
                        [
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
                        ],
                        'p70_',
                        getValue:(name)=>o[name],
                        onChanged:(value,name)=>setO(setState,value,name)
                    ),
                    Text("¿En los últimos 15 días, ¿Su niño/a ha tenido diarrea?",style:boldStyle),
                    ..._RadioGroup(
                        [
                            'Si',
                            'No'
                        ], 
                        o['p71'],
                        setter(setState,'p71')
                    ),
                    Text("La próxima visita será el:",style:boldStyle),
                    _DateField(
                        context,
                        o['p72'],
                        setter(setState,'p72')
                    ),
                ]
            },
        ];

        return new Scaffold(
            body: new Form(
                key: _formKey,
                child:Column(children:[
                    Expanded(child:SingleChildScrollView(
                        child:Padding(
                            padding: EdgeInsets.all(16.0),
                            child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                        DataTable(
                        columns: [
                        DataColumn(label: Text('RollNo')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Class')),
                        ],
                        rows: [
                        DataRow(cells: [
                        DataCell(Text('1')),
                        DataCell(Text('Arya')),
                        DataCell(Text('6')),
                        ]),
                        DataRow(cells: [
                        DataCell(Text('12')),
                        DataCell(Text('John')),
                        DataCell(Text('9')),
                        ])
                        ],
                        ),


                        ExpansionPanelList(
                        animationDuration: Duration(milliseconds: 300),
                        expansionCallback: (int index, bool isExpanded) {
                        setState((){
                        o[index]=!isExpanded;
                        });
                        },
                        children:[..._ExpansionPanel(panels)]
                        )
                        ]
                        )
                        ),
                    )),
                    Padding(padding: EdgeInsets.all(10.0),child:Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            ElevatedButton.icon(
                                onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                    }
                                    setState(() {
                                        //debugPrint(_formKey);
                                        debugPrint(json.encode(o));
                                        //_futureAlbum = createAlbum(_controller.text);
                                    });
                                },
                                label: const Text('Grabar'),
                                icon:Icon(Icons.save)
                            )
                        ]
                    ))
                ])
            ),
        );
          
    }

}