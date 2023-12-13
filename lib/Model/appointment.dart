import 'dart:convert';

class Appointment {
  int? appointmentID; // Assuming it's nullable and auto-incremented
  int patientID;
  DateTime appointmentDateTime;
  int specialistID;

  Appointment({
    this.appointmentID,
    required this.patientID,
    required this.appointmentDateTime,
    required this.specialistID,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentID: json['appointmentID'] as int?,
      patientID: json['patientID'] as int,
      appointmentDateTime: DateTime.parse(json['appointmentDateTime']),
      specialistID: json['specialistID'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'appointmentID': appointmentID,
    'patientID': patientID,
    'appointmentDateTime': appointmentDateTime.toIso8601String(),
    'specialistID': specialistID,
  };
}

List<Appointment> appointmentFromJson(String str) {
  final jsonData = json.decode(str);
  return List<Appointment>.from(jsonData.map((item) => Appointment.fromJson(item)));
}

String appointmentToJson(List<Appointment> data) {
  final List<dynamic> jsonData = data.map((item) => item.toJson()).toList();
  return json.encode(jsonData);
}
