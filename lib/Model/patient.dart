import 'dart:typed_data';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/request_controller.dart';

class Patient {
   int? patientID;
   String? patientName;
   String? phone;
   String? icNum;
   String? gender;
   DateTime? birthDate;
   String? address;
   String? password;
   String? state;
   String? postcode;

  Patient({
    required this.patientID,
    required this.patientName,
    required this.phone,
    required this.icNum,
    required this.gender,
    required this.birthDate,
    required this.address,
    required this.password,
    required this.state,
    required this.postcode
  });


  Patient.fromJson(Map<String, dynamic> json)
      :
        patientName = json['patientName'] as String?,
        phone = json['phone'] as String? ,
        icNum = json['icNumber'] as String?,
        gender = json['gender'] as String ?,
        birthDate = _parseDateTime(json['birthDate'] as dynamic),
        address = json['patientAddress'] as String?,
        state = json['state'] as String?,
        postcode = json['postcode'] as String?,
        password = json['password'] as String?;


   static DateTime? _parseDateTime(dynamic dateTimeString) {
     if (dateTimeString == null) {
       return null;
     }

     try {
       return DateTime.parse(dateTimeString.toString());
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
        'icNumber': icNum,
        'gender': gender,
        'birthDate': birthDate?.toString(), // Convert DateTime to string
        'patientAddress': address,
        'state': state,
        'postcode': postcode,
        'password': password
      };

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;
    print("patinetttt $storedID");

    RequestController req = RequestController(
        path: "/teleclinic/editprofile.php?patientID=$storedID");
    req.setBody(toJson());
    await req.post();
    if (req.status() == 200) {
      return true;
    }
    else {
      print("tak dapat bro");
      return false;
    }
  }

   static Future<List<Patient>> loadAll() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     int storedID = prefs.getInt("patientID") ?? 0;

     print("patient $storedID");

     List<Patient> result = [];

     // Instantiate RequestController
     RequestController req = RequestController(
       path: "/teleclinic/editprofile.php?patientID=$storedID",
     );

     // Make a GET request
     await req.get();

     if (req.status() == 200 && req.result() != null) {
       dynamic resultData = req.result();

       if (resultData is Iterable) {
         for (var item in resultData) {
           result.add(Patient.fromJson(item));
           print("sini 1");
         }
       } else if (resultData is Map<String, dynamic>) {
         // Handle the case when the result is a single object (not iterable)
         result.add(Patient.fromJson(resultData));
         print("sini 2");
       } else {
         // Handle the case when the result is neither an iterable nor a map
         print('Unexpected result type: ${resultData.runtimeType}');
       }
     }
     else{
       print("tak dapat weh");
     }
     return result;
   }


}