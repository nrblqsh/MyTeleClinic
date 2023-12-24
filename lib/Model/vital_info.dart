import '../Controller/request_controller.dart';

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

  VitalInfo( {
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
      waistCircumference:
      double.parse(json['waistCircumference'].toString()),
      latestDate: json['latestDate'],
      patientID: int.parse(json['patientID'].toString()),
    );
  }

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() => {'patientID': patientID,'weight': weight, 'height': height,
    'waistCircumference': waistCircumference,  'bloodPressure': bloodPressure,
    'bloodGlucose': bloodGlucose,  'heartRate': heartRate, 'latestDate': latestDate};


  Future<bool> save() async {
    RequestController req = RequestController(path: "/teleclinic/vitalInfo.php?");
    req.setBody(toJson());
    await req.post();
    return req.status() == 200;
  }

  static Future<List<VitalInfo>> loadAll() async {
    List<VitalInfo> result = [];
    RequestController req = RequestController(path: "/teleclinic/vitalInfo.php");
    await req.get();
    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(VitalInfo.fromJson(item));
      }
    }
    return result;
  }
}
