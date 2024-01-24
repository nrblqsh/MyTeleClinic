import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/material.dart';

import '../../Main/main.dart';
import '../../Model/vital_info.dart';
import 'add_vital_info.dart';

// void main() {
//   runApp(MaterialApp(
//     home: VitalInfoReportScreen(patientID: 0),
//   ));
// }

class VitalInfoReportScreen extends StatefulWidget {
  final int patientID;
  VitalInfoReportScreen({required this.patientID});

  @override
  _VitalInfoReportScreenState createState() => _VitalInfoReportScreenState();
}

class _VitalInfoReportScreenState extends State<VitalInfoReportScreen> {
  late int patientID;
  late VitalInfo vitalInfo;
  late VitalInfoDataSource vitalInfoDataSource;
  late List<GridColumn> _columns;

  @override
  void initState() {
    super.initState();
    _loadData();
    _columns = getColumns();
    vitalInfoDataSource = VitalInfoDataSource([]);
  }

  Future<void> _loadData()  async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;

    setState(() {
      patientID = storedID;
      //patientIDController.text = patientID.toString();
    });
  }

  Future<VitalInfo?> generateVitalInfo() async {
    try {
      var url =
          'http://${MyApp.ipAddress}/teleclinic/currentVitalInfo.php?patientID=$patientID';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var list = json.decode(response.body);
        print('Received Data: $list');

        List<VitalInfo> _vitalInfos = list
            .map<VitalInfo>((json) => VitalInfo.fromJson(json))
            .toList();

        if (_vitalInfos.isNotEmpty) {
          vitalInfo = _vitalInfos.first;
          print('Parsed Data: $vitalInfo');
          return vitalInfo;
        } else {
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  Future<List<VitalInfo>> generateVitalInfoList() async {
    try {
      var url = 'http://${MyApp.ipAddress}/teleclinic/vitalInfoReport.php?patientID=$patientID';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var list = json.decode(response.body);
        print('Received Data: $list');

        List<VitalInfo> _vitalInfos = list
            .map<VitalInfo>((json) => VitalInfo.fromJson(json))
            .toList();

        print('Parsed Data: $_vitalInfos');

        return _vitalInfos;
      } else {
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  List<GridColumn> getColumns() {
    return <GridColumn>[
      // GridColumn(
      //   columnName: 'infoID',
      //   width: 100,
      //   label: Container(
      //     padding: EdgeInsets.all(8.0),
      //     alignment: Alignment.center,
      //     child: Text('Info ID'),
      //   ),
      // ),
      GridColumn(
        columnName: 'weight',
        width: 100,
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Weight'),
        ),
      ),
      GridColumn(
        columnName: 'height',
        width: 100,
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            'Height',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      GridColumn(
        columnName: 'waistCircumference',
        width: 150,
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Waist Circumference'),
        ),
      ),
      GridColumn(
        columnName: 'bloodPressure',
        width: 150,
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Blood Pressure'),
        ),
      ),
      GridColumn(
        columnName: 'bloodGlucose',
        width: 150,
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Blood Glucose'),
        ),
      ),
      GridColumn(
        columnName: 'heartRate',
        width: 100,
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Heart Rate'),
        ),
      ),
      GridColumn(
        columnName: 'latestDate',
        width: 150,
        label: Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Latest Date'),
        ),
      ),
      // GridColumn(
      //   columnName: 'patientID',
      //   width: 100,
      //   label: Container(
      //     padding: EdgeInsets.all(8.0),
      //     alignment: Alignment.center,
      //     child: Text('Patient ID'),
      //   ),
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 98,
      //   backgroundColor: Colors.white,
      //   title: Center(
      //     child: Image.asset(
      //       "asset/MYTeleClinic.png",
      //       width: 594,
      //       height: 258,
      //     ),
      //   ),
      // ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, right: 20),
              child: Text(
                " Latest Vital Info Record" ,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
            ),

            ListTile(
              title: Padding(
                padding: EdgeInsets.only(top: 40, bottom: 30),
                child: Image.asset(
                  "asset/news.png",
                  width: 294,
                  height: 88,
                ),
              ),
            ),
            FutureBuilder<VitalInfo?>(
              future: generateVitalInfo(),
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
                } else if (snapshot.data == null) {
                  return Center(
                    child: Text('No data available'),
                  );
                } else {
                  return Container(
                    width: double.infinity, // Make it full width
                    margin: EdgeInsets.all(5),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 70.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Date: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.latestDate} ',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Weight: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.weight} kg',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Height: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.height} cm',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Waist Circumference: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.waistCircumference} cm',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Blood Pressure: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.bloodPressure} mmHg',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Blood Glucose: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.bloodGlucose} mg/dl',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'Heart Rate: ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${snapshot.data!.heartRate} bpm',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                }
              },
            ),

            Padding(
              padding: const EdgeInsets.only(left:70, top: 25, right: 100, bottom: 10),
              child: Text(
                "Vital Info Report ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => AddVitalInfoScreen( patientID: patientID)));
            //
            //   },
            //   child: Text("Add Vital Info "),
            // ),

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
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: 1000,
                      child: SfDataGrid(
                        source: vitalInfoDataSource,
                        columns: _columns,
                        columnWidthMode: ColumnWidthMode.fill,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVitalInfoScreen(patientID: patientID),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

}

class VitalInfoDataSource extends DataGridSource {
  VitalInfoDataSource(this.vitalInfos);

  List<VitalInfo> vitalInfos = [];

  @override
  List<DataGridRow> get rows {
    buildDataGridRow();
    return _vitalInfoDataGridRows;
  }

  List<DataGridRow> _vitalInfoDataGridRows = [];

  void buildDataGridRow() {
    _vitalInfoDataGridRows = vitalInfos
        .map<DataGridRow>((e) => DataGridRow(cells: [
      // DataGridCell<int>(columnName: 'infoID', value: e.infoID),

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
      //  DataGridCell<int>(columnName: 'patientID', value: e.patientID),
    ]))
        .toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(
            e.value.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  void updateDataGrid() {
    notifyListeners();
  }
}