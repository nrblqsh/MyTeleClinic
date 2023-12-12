// booking.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_teleclinic/Controller/request_controller.dart';


class Booking {
  int? appointmentID; // Assuming it's nullable and auto-incremented
  int patientID;
  DateTime appointmentDateTime;
  int specialistID;

  Booking({
    this.appointmentID,
    required this.patientID,
    required this.appointmentDateTime,
    required this.specialistID,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      appointmentID: json['appointmentID'] as int?,
      patientID: json['patientID'] as int,
      appointmentDateTime: DateTime.parse(json['appointmentDateTime']),
      specialistID: json['specialistID'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'appointmentID': appointmentID,
    'patientID': patientID,
    'appointmentDateTime': appointmentDateTime.toString(),
    'specialistID': specialistID,
  };


  //add save
  Future<bool> save() async {
    // API OPERATION
    RequestController req = RequestController(path: '/teleclinic/booking.php');
    req.setBody(toJson());
    await req.post();
    if (req.status() == 200) {
      return true;
    } else {
      return false;
    }
  }


Future<List<Booking>> fetchBookings() async {
  final String url = 'http://10.131.74.150/teleclinic/booking.php'; // Modify the path accordingly
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    return responseData.map((data) => Booking.fromJson(data)).toList();
  } else {
    throw Exception('Failed to fetch bookings');
  }
}

}