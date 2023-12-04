import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_teleclinic/Patients/EMR/add_vital_info.dart';
import 'package:my_teleclinic/Patients/EMR/vital_info.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Controller/request_controller.dart';

void main() {
  runApp(const MaterialApp(
    home: vitalInfoReportScreen(),
  ));
}

class VitalInfoDataSource extends DataGridSource {
  VitalInfoDataSource(this.vitalInfos) {
    buildDataGridRow();
  }

  void buildDataGridRow() {
    _vitalInfoDataGridRows = vitalInfos
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'infoID', value: e.infoID),
              DataGridCell<double>(columnName: 'weight', value: e.weight),
              DataGridCell<double>(columnName: 'height', value: e.height),
              DataGridCell<double>(
                  columnName: 'waistCircumference',
                  value: e.waistCircumference),
              DataGridCell<double>(
                  columnName: 'bloodPressure', value: e.bloodPressure),
              DataGridCell<double>(
                  columnName: 'bloodGlucose', value: e.bloodGlucose),
              DataGridCell<double>(columnName: 'heartRate', value: e.heartRate),
              DataGridCell<String>(
                  columnName: 'latestDate', value: e.latestDate),
            ]))
        .toList();
  }

  List<VitalInfo> vitalInfos = [];

  List<DataGridRow> _vitalInfoDataGridRows = [];

  @override
  List<DataGridRow> get rows => _vitalInfoDataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }

  void updateDataGrid() {
    notifyListeners();
  }
}

class VitalInfo {
  late int infoID;
  late double weight;
  late double height;
  late double waistCircumference;
  late double bloodPressure;
  late double bloodGlucose;
  late double heartRate;
  late String latestDate;
  late int patientID;

  VitalInfo({
    required this.weight,
    required this.height,
    required this.bloodPressure,
    required this.bloodGlucose,
    required this.heartRate,
    required this.waistCircumference,
    required this.latestDate,
    required this.patientID,
    required this.infoID,
  });

  factory VitalInfo.fromJson(Map<String, dynamic> json) {
    return VitalInfo(
        infoID: int.parse(json['infoID'].toString()),
        weight: json['weight'],
        height: json['height'],
        bloodPressure: json['bloodPressure'],
        bloodGlucose: json['bloodGlucose'],
        heartRate: json['heartRate'],
        waistCircumference: json['waistCircumference'],
        latestDate: json['latestDate'],
        patientID: int.parse(json['patientID'].toString()));
  }
}

class vitalInfoReportScreen extends StatefulWidget {
  const vitalInfoReportScreen({super.key});

  @override
  _vitalInfoReportScreenState createState() => _vitalInfoReportScreenState();
}

class _vitalInfoReportScreenState extends State<vitalInfoReportScreen> {
  late VitalInfoDataSource vitalInfoDataSource;
  late List<GridColumn> _columns;

  Future<List<VitalInfo>> generateVitalInfoList() async {
    // Give your sever URL of get_employees_details.php file
    var url = "/teleclinic/vital_info_report.php";
    final response = await http.get(url as Uri);
    var list = json.decode(response.body);
    List<VitalInfo> _vitalInfos =
        await list.map<VitalInfo>((json) => VitalInfo.fromJson(json)).toList();
    var vitalInfoDataSource = VitalInfoDataSource(_vitalInfos);
    return _vitalInfos;
  }

  List<GridColumn> getColumns() {
    return <GridColumn>[
      GridColumn(
          columnName: 'infoID',
          width: 70,
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'infoID',
              ))),
      GridColumn(
          columnName: 'weight',
          width: 80,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('weight'))),
      GridColumn(
          columnName: 'height',
          width: 120,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                'height',
                overflow: TextOverflow.ellipsis,
              ))),
      GridColumn(
          columnName: 'waistCircumference',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('waistCircumference'))),
      GridColumn(
          columnName: 'bloodPressure',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('bloodPressure'))),
      GridColumn(
          columnName: 'bloodGlucose',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('bloodGlucose'))),
      GridColumn(
          columnName: 'heartRate',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('heartRate'))),
      GridColumn(
          columnName: 'latestDate',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('latestDate'))),
    ];
  }

  @override
  void initState() {
    super.initState();
    _columns = getColumns();
    vitalInfoDataSource = VitalInfoDataSource([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 98,
          backgroundColor: Colors.white,
          title: Center(
            child: Image.asset(
              "asset/MYTeleClinic.png",
              width: 594,
              height: 258,
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 25, right: 154),
            child: Text(
              "Vital Info Report ",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                textStyle: const TextStyle(fontSize: 28, color: Colors.black),
              ),
            ),
          ),
          ListTile(
            title: Padding(
              padding: EdgeInsets.only(top: 30),
              child: Image.asset(
                "asset/news.png",
                width: 294,
                height: 88,
              ),
            ),
          ),
          FutureBuilder<Object>(
              future: generateVitalInfoList(),
              builder: (context, data) {
                return data.hasData
                    ? SfDataGrid(
                        source: vitalInfoDataSource,
                        columns: _columns,
                        columnWidthMode: ColumnWidthMode.fill)
                    : Center(
                        child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: 0.8,
                      ));
              })
        ])));
  }
}
