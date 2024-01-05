// To parse this JSON data, do
//
//     final medication = medicationFromJson(jsonString);

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Main/main.dart';

List<Medication> medicationFromJson(String str) => List<Medication>.from(json.decode(str).map((x) => Medication.fromJson(x)));

String medicationToJson(List<Medication> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Medication {
//  int medID;
 // int consultationID;
 // int medicationID;
  String? medGeneral;
  String? medForm;
  DateTime consultationDateTime;

  Medication({
    // required this.medID,
    // required this.consultationID,
    // required this.medicationID,
    required this.medGeneral,
    required this.medForm,
    required this.consultationDateTime
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    // medID: json["MedID"],
    // consultationID: json["consultationID"],
    // medicationID: json["medicationID"],
    medGeneral: json["MedGeneral"],
    medForm: json["medForm"],
    consultationDateTime: DateTime.parse(json['consultationDateTime']),
  );

  Map<String, dynamic> toJson() => {
    // "MedID": medID,
    // "consultationID": consultationID,
    // "medicationID": medicationID,
    "MedGeneral": medGeneral,
    "medForm": medForm,
    'consultationDateTime': consultationDateTime.toString(),
  };


  Future<List<Medication>> fetchConsultationMedication(int patientID, int specialistID) async {
    final String url = 'http://${MyApp.ipAddress}/teleclinic/patientMedication.php?patientID=$patientID&&specialistID=$specialistID'; // Modify the path accordingly
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print(responseData);
      return responseData.map((data) => Medication.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch medications');
    }
  }
}
