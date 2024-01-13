// To parse this JSON data, do
//
//     final medication = medicationFromJson(jsonString);

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Controller/request_controller.dart';
import '../Main/main.dart';

List<Medication> medicationFromJson(String str) => List<Medication>.from(json.decode(str).map((x) => Medication.fromJson(x)));

String medicationToJson(List<Medication> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Medication {
  int medID;
  int consultationID;
  int medicationID;
  String? medGeneral;
  String? medForm;
  DateTime consultationDateTime;
  String? dosage;
  String? medInstruction;

  Medication({
     required this.medID,
     required this.consultationID,
     required this.medicationID,
    required this.medGeneral,
    required this.medForm,
    required this.consultationDateTime,
    required this.dosage,
    required this.medInstruction
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
     medID: json["MedID"],
     consultationID: json["consultationID"],
     medicationID: json["medicationID"],
    medGeneral: json["MedGeneral"],
    medForm: json["medForm"],
    consultationDateTime: DateTime.parse(json['consultationDateTime']),
    dosage: json["Dosage"],
    medInstruction: json["MedInstruction"],


  );

  Map<String, dynamic> toJson() => {
     "MedID": medID,
     "consultationID": consultationID,
     "medicationID": medicationID,
    "MedGeneral": medGeneral,
    "medForm": medForm,
    'consultationDateTime': consultationDateTime.toString(),
    "Dosage": dosage,
    "MedInstruction": medInstruction,



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




  static Future<List<Medication>> loadAll() async {

    // Instantiate RequestController
    RequestController req = RequestController(
      path: "/teleclinic/getMedicineforVideoConsultation.php",
    );

    // Make a GET request
    print("Request URL: ${req.path}");

    await req.get();
    print("Response Status: ${req.status()}");
    print("Response Body: ${req.result()}");

    if (req.status() == 200 && req.result() != null) {
      dynamic resultData = req.result();

      print("Raw JSON Data: $resultData");

      try {
        if (resultData is Map<String, dynamic> && resultData.containsKey('data')) {
          // Handle the case when the result is an array or a single object
          print("1");
          var dataList = resultData['data'] as List<dynamic>;
          return dataList.map((item) => Medication.fromJson(item)).toList();
        } else {
          print('Unexpected response format. Body is not a JSON object.');
          return [];
        }
      } catch (e) {
        print('Error parsing response: $e');
        return [];
      }
    } else {
      // Handle the case when the request failed
      print('Error loading patients: ${req.status()}');
      return [];
    }
  }


  static Future<List<Map<String, dynamic>>> getMedicationSuggestions(String value) async {
    final String url = 'http://${MyApp.ipAddress}/teleclinic/getMedicineforVideoConsultation.php?searchTerm=$value'; // Modify the path accordingly
    final response = await http.get(Uri.parse(url));

    print('Raw Response: ${response.body}');


    if (response.statusCode == 200) {
      try {
        dynamic responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic> && responseBody.containsKey('data')) {
          if (responseBody['data'] is List<dynamic>) {
            // Handle the case when the result is a list
            return List<Map<String, dynamic>>.from(responseBody['data']);
          } else {
            // Handle the case when the result is a single object
            return [responseBody['data']];
          }
        } else {
          print('Unexpected response format. Body is not a JSON object.');
          return [];
        }
      } catch (e) {
        print('Error parsing response: $e');
        return [];
      }
    } else {
      print('Failed to fetch medication suggestions. Status Code: ${response.statusCode}');
      throw Exception('Failed to fetch medication suggestions. Status Code: ${response.statusCode}');
    }
  }

}