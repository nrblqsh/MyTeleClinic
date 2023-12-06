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

class vitalInfoReportScreen extends StatefulWidget {
  const vitalInfoReportScreen({super.key});

  @override
  _vitalInfoReportScreenState createState() => _vitalInfoReportScreenState();
}

class _vitalInfoReportScreenState extends State<vitalInfoReportScreen> {
  late VitalInfoDataSource vitalInfoDataSource;
  late List<GridColumn> _columns;

  @override
  void initState() {
    super.initState();
    _columns = getColumns();
    vitalInfoDataSource = VitalInfoDataSource([]);
  }

  Future<List<VitalInfo>> generateVitalInfoList() async {
    try {
      // Provide the correct URL for your server
      var url = 'http://192.168.0.116/teleclinic/vitalInfoReport.php';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var list = json.decode(response.body);
        //var list = json.decode(response.body);
        print('Received Data: $list');

        List<VitalInfo> _vitalInfos = list
            .map<VitalInfo>((json) => VitalInfo.fromJson(json))
            .toList();

        return _vitalInfos;
      } else {
        // Handle HTTP error status codes
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      // Handle other errors that might occur
      print('Error: $error');
      return [];
    }
  }

  List<GridColumn> getColumns() {
    return <GridColumn>[
      GridColumn(
          columnName: 'infoID',
          width: 70,
          label: Container(
              padding: EdgeInsets.all(1.0),
              alignment: Alignment.center,
              child: Text(
                'infoID',
              ))),
      GridColumn(
          columnName: 'weight',
          width: 80,
          label: Container(
              padding: EdgeInsets.all(1.0),
              alignment: Alignment.center,
              child: Text('weight'))),
      GridColumn(
          columnName: 'height',
          width: 120,
          label: Container(
              padding: EdgeInsets.all(1.0),
              alignment: Alignment.center,
              child: Text(
                'height',
                overflow: TextOverflow.ellipsis,
              ))),
      // GridColumn(
      //     columnName: 'waistCircumference',
      //     label: Container(
      //         padding: EdgeInsets.all(1.0),
      //         alignment: Alignment.center,
      //         child: Text('waistCircumference'))),
      // GridColumn(
      //     columnName: 'bloodPressure',
      //     label: Container(
      //         padding: EdgeInsets.all(1.0),
      //         alignment: Alignment.center,
      //         child: Text('bloodPressure'))),
      // GridColumn(
      //     columnName: 'bloodGlucose',
      //     label: Container(
      //         padding: EdgeInsets.all(1.0),
      //         alignment: Alignment.center,
      //         child: Text('bloodGlucose'))),
      // GridColumn(
      //     columnName: 'heartRate',
      //     label: Container(
      //         padding: EdgeInsets.all(1.0),
      //         alignment: Alignment.center,
      //         child: Text('heartRate'))),
      // GridColumn(
      //     columnName: 'latestDate',
      //     label: Container(
      //         padding: EdgeInsets.all(1.0),
      //         alignment: Alignment.center,
      //         child: Text('latestDate'))),
    ];
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
              FutureBuilder<List<VitalInfo>>(
                future: generateVitalInfoList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: 0.8,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No data available'),
                    );
                  } else {
                    vitalInfoDataSource.vitalInfos = snapshot.data!;
                    vitalInfoDataSource.updateDataGrid();
                    return SfDataGrid(
                      source: vitalInfoDataSource,
                      columns: _columns,
                      columnWidthMode: ColumnWidthMode.fill,
                    );
                  }
                },
              ),



            ])));

  }
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

    //print(e.weight);
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
  int infoID;
  double weight;
  double height;
  double waistCircumference;
  double bloodPressure;
  double bloodGlucose;
  double heartRate;
  String latestDate;
  int patientID;

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
        weight: double.parse(json['weight'].toString()),
        height: double.parse(json['height'].toString()),
        bloodPressure: double.parse(json['bloodPressure'].toString()),
        bloodGlucose: double.parse(json['bloodGlucose'].toString()),
        heartRate: double.parse(json['heartRate'].toString()),
        waistCircumference: double.parse(json['waistCircumference'].toString()),
        latestDate: json['latestDate'],
        patientID: int.parse(json['patientID'].toString())
    );
  }

}

