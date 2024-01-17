// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Controller/request_controller.dart';
import '../Main/main.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';



List<Specialist> specialistFromJson(String str) => List<Specialist>.from(json.decode(str).map((x) => Specialist.fromJson(x)));

String specialistToJson(List<Specialist> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Specialist {
  dynamic specialistID;
  dynamic clinicID;
  String specialistName;
  String specialistTitle;
  String phone;
  String password;
  String logStatus;
  String clinicName;
  Uint8List? specialistImagePath;


  Specialist({
    required this.specialistID,
    required this.clinicID,
    required this.specialistName,
    required this.specialistTitle,
    required this.phone,
    required this.password,
    required this.logStatus,
    required this.clinicName,
    this.specialistImagePath


  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      specialistID: json["specialistID"],
      clinicID: json["clinicID"],
      specialistName: json["specialistName"] ?? '',
      specialistTitle: json["specialistTitle"] ?? '',
      phone: json["phone"] ?? '',
      password: json["password"] ?? '',
      logStatus: json["logStatus"] ?? '',
      clinicName: json["clinicName"] ?? '',
      specialistImagePath: base64Decode(json["base64Image"] ?? ''),


    );
  }


  Map<String, dynamic> toJson() =>
      {
        "specialistID": specialistID,
        "clinicID": clinicID,
        "specialistName": specialistName,
        "specialistTitle": specialistTitle,
        "phone": phone,
        "password": password,
        "logStatus": logStatus,
        "clinicName": clinicName,
        "specialistImagePath": specialistImagePath


      };


  Future<bool> editSpecialist({
    String? specialistName,
    String? specialistTitle,
    String? phone,
    Uint8List? specialistImagePath,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("specialistID") ?? 0;

    // Specify the full URI including the host
    String fullUri = "http://${MyApp.ipAddress}/teleclinic/"
        "editProfileSpecialist.php?specialistID=$storedID";

    try {
      // Create a `http.MultipartRequest` to send both text fields and the image file
      var request = http.MultipartRequest('POST', Uri.parse(fullUri));

      // Attach the text fields
      request.fields.addAll({
        'specialistName': specialistName ?? '',
        'specialistTitle': specialistTitle ?? '',
        'phone': phone ?? '',
      });

      // Attach the image file (if it exists)
      if (specialistImagePath != null && specialistImagePath.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            specialistImagePath,
            filename: 'image.jpg',
          ),
        );
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // Successfully updated the profile
        // Parse the JSON response if needed
        final Map<String, dynamic> responseData =
        json.decode(await response.stream.bytesToString());

        print('Profile Update Response: $responseData');

        return true;
      } else {
        // Handle the case when the request failed
        print('Failed to update profile. Status: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      // Handle any exceptions that might occur during the request
      print('Error updating profile: $error');
      return false;
    }
  }

//   Future<bool> uploadImage({required Uint8List imageData,}) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int storedID = prefs.getInt("specialistID") ?? 0;
//
//     // Specify the full URI including the host
//     String fullUri = "http://192.168.8.186/teleclinic/uploadSpecialistImage.php?specialistID=$storedID";
//
//     // Instantiate RequestController with the full URI
// //    RequestController req = RequestController(path: "/teleclinic/uploadSpecialistImage.php", server: "http://192.168.8.186");
//
//     // Create a `http.MultipartRequest` to send the image file
//     var request = http.MultipartRequest('POST', Uri.parse(fullUri));
//
//     // Attach the image file
//     request.files.add(
//       http.MultipartFile.fromBytes('image', imageData, filename: 'image.jpg'),
//     );
//
//     try {
//       // Send the request
//       var response = await request.send();
//
//       if (response.statusCode == 200) {
//         // Successfully uploaded the image
//         // Parse the JSON response if needed
//         final Map<String, dynamic> responseData =
//         json.decode(await response.stream.bytesToString());
//
//         print('Image Upload Response: $responseData');
//
//         return true;
//       } else {
//         // Handle the case when the request failed
//         print('Failed to upload image. Status: ${response.statusCode}');
//         return false;
//       }
//     } catch (error) {
//       // Handle any exceptions that might occur during the image upload
//       print('Error uploading image: $error');
//       return false;
//     }
//   }

  static Future<List<Specialist>> loadAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int specialistID = prefs.getInt("specialistID") ?? 0;

    // Instantiate RequestController
    RequestController req = RequestController(
      path: "/teleclinic/getProfileSpecialist.php",
    );

    // Add specialistID as a query parameter
    req.path = "${req.path}?specialistID=$specialistID";

    // Make a GET request
    await req.get();

    if (req.status() == 200 && req.result() != null) {
      dynamic resultData = req.result();

      try {
        if (resultData is Map<String, dynamic> && resultData.containsKey('data')) {
          // The data field contains a single Specialist object
          Specialist specialist = Specialist.fromJson(resultData['data']);
          return [specialist];
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
      print('Error loading specialists: ${req.status()}');
      return [];
    }
  }

  static Future<Uint8List?> getSpecialistImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int specialistID = prefs.getInt("specialistID") ?? 0;
    RequestController req = RequestController(

      path: "/teleclinic/getSpecialistImage.php",
    );

    // Add specialistID as a query parameter
    req.path = "${req.path}?specialistID=$specialistID";

    try {
      // Make a GET request using RequestController
      await req.get();

      if (req.status() == 200) {
        // Image data is available in the response body
        return req.result();
      } else if (req.status() == 404) {
        // Image not found
        print('Image not found for specialistID: $specialistID');
        return null;
      } else {
        // Handle other status codes
        print('Failed to retrieve image. Status: ${req.status()}');
        return null;
      }
    } catch (error) {
      // Handle any exceptions that might occur during the request
      print('Error retrieving image: $error');
      return null;
    }
  }



  static Future<Uint8List?> getSpecialistImageforCall(int consultationID) async {

    RequestController req = RequestController(

      path: "/teleclinic/getSpecialistImageforVideoNotification.php",
    );

    // Add specialistID as a query parameter
    req.path = "${req.path}?consultationID=$consultationID";

    try {
      // Make a GET request using RequestController
      await req.get();

      if (req.status() == 200) {
        // Image data is available in the response body
        return req.result();
      } else if (req.status() == 404) {
        // Image not found
        print('Image not found for specialistID: $consultationID');
        return null;
      } else {
        // Handle other status codes
        print('Failed to retrieve image. Status: ${req.status()}');
        return null;
      }
    } catch (error) {
      // Handle any exceptions that might occur during the request
      print('Error retrieving image: $error');
      return null;
    }
  }


  static Future<Uint8List?> getSpecialistImage1(int specialistID) async {

    RequestController req = RequestController(

      path: "/teleclinic/getSpecialistImagePatientSide.php",
    );

    // Add specialistID as a query parameter
    req.path = "${req.path}?specialistID=$specialistID";

    try {
      // Make a GET request using RequestController
      await req.get();

      if (req.status() == 200) {
        // Image data is available in the response body
        return req.result();
      } else if (req.status() == 404) {
        // Image not found
        print('Image not found for specialistID: $specialistID');
        return null;
      } else {
        // Handle other status codes
        print('Failed to retrieve image. Status: ${req.status()}');
        return null;
      }
    } catch (error) {
      // Handle any exceptions that might occur during the request
      print('Error retrieving image: $error');
      return null;
    }
  }
}

