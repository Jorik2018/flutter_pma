import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';

class ChildrenScreen extends StatefulWidget {
  @override
  _ChildrenScreenState createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Niños'),
        ),
        body: Center(
          child: DataTable(
              columns: [
                  DataColumn(label: Text('RollNo')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Class')),
              ],
              rows: [
                  DataRow(cells: [
                      DataCell(Text('12')),
                      DataCell(Text('John')),
                      DataCell(Text('9')),
                  ])
              ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {

  }
}