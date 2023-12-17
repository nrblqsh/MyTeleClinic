// consultation.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_teleclinic/Controller/request_controller.dart';
import '';

//
class Consultation {
  int? consultationID; // Assuming it's nullable and auto-incremented
  int patientID;
  DateTime consultationDateTime;
  int specialistID;
  String consultationSymptom;
  String consultationTreatment;
  String consultationStatus;
  String? specialistName;
  String? patientName;// Add specialist's name field
  //String? specialistTitle;
  //int procedureID;

  Consultation({
    this.consultationID,
    required this.patientID,
    required this.consultationDateTime,
    required this.specialistID,
    required this.consultationStatus,
    required this.consultationTreatment,
    required this.consultationSymptom,
    this.specialistName,
    this.patientName,
    // this.specialistTitle,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      consultationID: json['consultationID'] as int?,
      patientID: json['patientID'] as int,
      consultationDateTime: DateTime.parse(json['consultationDateTime']),
      specialistID: json['specialistID'] as int,
      consultationTreatment: json['consultationTreatment'],
      consultationStatus: json['consultationStatus'],
      consultationSymptom: json['consultationSymptom'],
      specialistName: json['specialistName'],
      patientName: json['patientName'], // Add this field if it exists in the JSON response
      //specialistTitle: json['specialistTitle'], // Add this field if it exists in the JSON response
    );
  }

  Map<String, dynamic> toJson() => {
    'consultationID': consultationID,
    'patientID': patientID,
    'consultationDateTime': consultationDateTime.toString(),
    'specialistID': specialistID,
    'consultationTreatment': consultationTreatment,
    'consultationStatus': consultationStatus,
    'consultationSymptom': consultationSymptom,
    'specialistName' : specialistName,
    'patientName' : patientName,
    //'specialistTitle':specialistTitle

  };


  //add save
  Future<bool> save() async {
    // API OPERATION
    RequestController req = RequestController(path: '/teleclinic/consultation.php');
    req.setBody(toJson());
    await req.post();
    if (req.status() == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Consultation>> fetchConsultations() async {
    final String url = 'http://192.168.200.150/teleclinic/consultation.php'; // Modify the path accordingly
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => Consultation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch consultations');
    }
  }


}