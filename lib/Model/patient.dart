import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/request_controller.dart';

class Patient {
   int? patientID;
   String? patientName;
   String? phone;
   String? icNumber;
   String? gender;
   DateTime? birthDate;
   String? password;



  Patient({
    required this.patientID,
    required this.patientName,
    required this.phone,
    required this.icNumber,
    required this.gender,
    required this.birthDate,
    required this.password,
  });

   Patient.fromJson(Map<String, dynamic> json)
       : patientName = json['patientName'] as String?,
         phone = json['phone'] as String?,
         icNumber = json['icNumber'] as String?,
         gender = json['gender'] as String?,
         birthDate = _parseDateTime(json['birthDate'] as dynamic),
         password = json['password'] as String?;


   static DateTime? _parseDateTime(dynamic dateTimeString) {
     if (dateTimeString == null) {
       return null;
     }

     try {
       if (dateTimeString is String) {
         return DateTime.parse(dateTimeString);
       } else {
         print("Error parsing date string: $dateTimeString");
         return null;
       }
     } catch (e) {
       print("Error parsing date string: $dateTimeString");
       print("Error details: $e");
       return null;
     }
   }


   Map<String, dynamic> toJson() =>
      {
        'patientName': patientName,
        'phone': phone,
        'icNumber': icNumber,
        'gender': gender,
        'birthDate': birthDate?.toString(), // Convert DateTime to string
        'password': password
      };

   Future<bool> save() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     int storedID = prefs.getInt("patientID") ?? 0;
     print("patient ID: $storedID");

     RequestController req = RequestController(
         path: "/teleclinic/editprofile.php?patientID=$storedID");
     req.setBody(toJson());
     await req.put();
     print("PUT URL: ${req.path}"); // Assuming 'path' is the property representing the URL

     if (req.status() == 200) {
       return true;
     } else {
       print("Failed to update profile. Status: ${req.status()}");
       return false;
     }
   }



   static Future<List<Patient>> loadAll() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     int patientID = prefs.getInt("patientID") ?? 0;

     // Instantiate RequestController
     RequestController req = RequestController(
       path: "/teleclinic/editprofile.php",
     );

     // Add patientID as a query parameter
     req.path = "${req.path}?patientID=$patientID";

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
           return dataList.map((item) => Patient.fromJson(item)).toList();
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


}