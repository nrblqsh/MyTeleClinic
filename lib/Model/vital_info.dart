import '../Controller/request_controller.dart';

class VitalInfo {
  final double weight;
  final double height;
  final double waistCircumference;
  final double bloodPressure;
  final double bloodGlucose;
  final double heartRate;
  final String latestDate;
  final int patientID;


  VitalInfo(
      this.weight,
      this.height,
  this.waistCircumference,
      this.bloodPressure,
      this.bloodGlucose,
  this.heartRate,
      this.latestDate, this.patientID,
      );

  VitalInfo.fromJson(Map<String, dynamic> json)
      : patientID = int.parse(json['patientID'].toString()),
        weight = json['weight'],
        height = json['height'],
        waistCircumference = json['waistCircumference'],
        bloodGlucose = json['bloodGlucose'],
        bloodPressure = json['bloodPressure'],
        heartRate = json['heartRate'],
        latestDate = json['latestDate'];

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
