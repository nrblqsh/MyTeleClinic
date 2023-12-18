// consultation.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_teleclinic/Controller/request_controller.dart';
import '';
import '../main.dart';

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
  String? patientName;
  String? icNum;
  String? gender;
  DateTime? birthDate;
  String? phone;// Add specialist's name field
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
    this.icNum,
    this.gender,
    this.birthDate,
    this.phone,
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
      patientName: json['patientName'],
      icNum: json['icNumber'],
      gender: json['gender'],
      birthDate : json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'])
          : DateTime.parse('0000-00-00'),
      phone: json['phone'],// Add this field if it exists in the JSON response
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
    'icNumber': icNum,
    'gender': gender,
    'birthDate': birthDate.toString(),
    'phone': phone,
    //'specialistTitle':specialistTitle

  };

  Consultation updateStatus(String newStatus) {
    // Create a new instance of Consultation with updated status
    return Consultation(
      consultationID: this.consultationID,
      specialistID: this.specialistID,
      consultationStatus: newStatus,
      consultationSymptom: this.consultationSymptom,
      consultationTreatment: this.consultationTreatment,
      consultationDateTime: this.consultationDateTime,
      patientID: this.patientID,
      patientName: this.patientName,
    );
  }

  Future<List<Consultation>> fetchTodayConsultations(int specialistID) async {
    final String url = 'http://${MyApp.ipAddress}/teleclinic/getTodayConsultation.php?specialistID=$specialistID';
    final response = await http.get(Uri.parse(url));
    print(specialistID);
    print('Response Status Code: ${response.statusCode}');
    print('Content-Type: ${response.headers['content-type']}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        dynamic responseBody = json.decode(response.body);

        // Check if the response is a JSON object
        if (responseBody is Map<String, dynamic> && responseBody.containsKey('data')) {
          List<Consultation> consultations = List<Consultation>.from(responseBody['data']
              .map((consultationData) => Consultation.fromJson(consultationData)));
          return consultations;
        } else {
          print('Unexpected response format. Body is not a JSON object.');
          return [];
        }

      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Error parsing response: $e');
      }
    } else {
      print('Failed to fetch today\'s consultations. Status Code: ${response.statusCode}');
      throw Exception('Failed to fetch today\'s consultations. Status Code: ${response.statusCode}');
    }
  }

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
    final String url = 'http://${MyApp.ipAddress}/teleclinic/consultation.php'; // Modify the path accordingly
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => Consultation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch consultations');
    }
  }

  Future<List<Consultation>> fetchConsultationByPatient(int specialistID, int patientID) async {
    final String url = 'http://${MyApp.ipAddress}/teleclinic/patientConsultation.php?patientID=$patientID&&specialistID=$specialistID'; // Modify the path accordingly
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => Consultation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch consultations');
    }
  }

  Future<List<Consultation>> fetchUpcomingConsultations(int specialistID) async {
    final String url = 'http://${MyApp.ipAddress}/teleclinic/getUpcomingAppointment.php?specialistID=$specialistID';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        dynamic responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic> && responseBody.containsKey('data')) {
          List<Consultation> consultations = List<Consultation>.from(responseBody['data']
              .map((consultationData) => Consultation.fromJson(consultationData)));
          return consultations;
        } else {
          print('Unexpected response format. Body is not a JSON object.');
          return [];
        }
      } catch (e) {
        print('Error parsing response: $e');
        throw Exception('Error parsing response: $e');
      }
    } else {
      print('Failed to fetch upcoming consultations. Status Code: ${response.statusCode}');
      throw Exception('Failed to fetch upcoming consultations. Status Code: ${response.statusCode}');
    }
  }


}