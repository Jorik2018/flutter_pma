import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:registration_login/utils/util.dart';
//https://blog.logrocket.com/flutter-datatable-widget-guide-displaying-data/

class ChildrenScreen extends StatefulWidget {

    Function? buildAction;

    ChildrenScreen({this.buildAction});

    @override
    _ChildrenScreenState createState() => _ChildrenScreenState();

}

class _ChildrenScreenState extends State<ChildrenScreen> {

  @override
  void initState() {
      _selected = List<bool>.generate(0, (int index) => false);
      super.initState();
      http.get(Uri.parse(Util.remoteHost+'/admin/directory/api/people/0/50')).then((response){
          List data=jsonDecode(response.body)['data'];
          setState(() {
              _data=data.cast<Map>();
              _selected = List<bool>.generate(data.length, (int index) => false);
          });
      });
  }

  List<Map> _data = [];
  List<bool> _selected = [];

  List<Widget> getActions(){
      return (_selected.length>0&&_selected.reduce((v,e)=>v=(v||e)))?[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                      Icons.delete,
                  ),
              )
          ),
          Container(

margin: const EdgeInsets.all(8.0),

padding: const EdgeInsets.all(8.0),

decoration: BoxDecoration(

shape: BoxShape.circle,

color: Colors.green,

boxShadow: [

BoxShadow(blurRadius: 5, color: Colors.grey.shade300)

]),


child: Icon(Icons.chat)),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                      Icons.search,
                  ),
              )
          ),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                      Icons.more_vert
                  ),
              )
          ),
      ]:[];
  }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            floatingActionButton: FloatingActionButton(
                backgroundColor: Color.fromARGB(255, 2, 97, 5),
                onPressed: () {
                    context.push('/children/create');
                },
                child: Icon(Icons.add),
            ),
            body:Column(children:[ 
                Row(children:[
                    IconButton(
                        icon: const Icon(Icons.first_page_rounded),
                        onPressed: () {
                            setState(() {});
                        },
                    ),
                    IconButton(
                        icon: const Icon(Icons.navigate_before),
                        onPressed: () {
                            setState(() {});
                        },
                    ),
                    IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: () {
                            setState(() {});
                        },
                    ),
                    IconButton(
                        icon: const Icon(Icons.last_page_outlined),
                        tooltip: 'Increase volume by 10',
                        onPressed: () {
                            setState(() {});
                        },
                    ),  
                ]),
                Expanded(
                    child:DataTable2(
                        columnSpacing: 12,
                        headingTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                        headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.black
                        ),
                        horizontalMargin: 12,
                        minWidth: 600,
                    columns: [
                        DataColumn2(
                          label: Text('Column A'),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Text('Column B'),
                          size:ColumnSize.L,
                          fixedWidth: 200
                        ),
                        DataColumn(
                        label: Text('Column C'),
                        ),
                        DataColumn(
                            label: Text('Column D'),
                        ),
                        DataColumn(
                        label: Text('Column NUMBERS'),
                            numeric: true,
                        ),
                    ],
                    rows:_data.mapIndexed((index, book) => DataRow(
                        cells: [
                            DataCell(Text(book['code'].toString())),
                            DataCell(Text(book['fullName'].toString())),
                            DataCell(Text(book['address'].toString())),
                            DataCell(Text(book['address'].toString())),
                            DataCell(Text(book['address'].toString()))
                        ],
                        selected: _selected[index],
                        onSelectChanged: (bool? selected) {
                            setState(() {
                                bool old=isSelected();
                                _selected[index] = selected!;
                                if(old!=isSelected())
                                  widget.buildAction!(actions:getActions());
                            });
                        }
                    )).toList()
                ),

            )
      ])
      );
  }

  bool isSelected(){
    return _selected.length>0&&_selected.reduce((v,e)=>v=(v||e));
  }

  @override
  void dispose() {

  }
}