// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<Specialist> specialistFromJson(String str) => List<Specialist>.from(json.decode(str).map((x) => Specialist.fromJson(x)));

String specialistToJson(List<Specialist> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Specialist {
  dynamic specialistID;
  String clinicID;
  String specialistName;
  String specialistTitle;
  String phone;
  String password;
  String logStatus;

  Specialist({
    required this.specialistID,
    required this.clinicID,
    required this.specialistName,
    required this.specialistTitle,
    required this.phone,
    required this.password,
    required this.logStatus

  });

  factory Specialist.fromJson(Map<String, dynamic> json) => Specialist(
    specialistID: json["specialistID"],
    clinicID: json["clinicID"],
    specialistName: json["specialistName"],
    specialistTitle: json["specialistTitle"],
    phone: json["phone"],
    password: json["password"],
    logStatus: json["logStatus"],

  );

  Map<String, dynamic> toJson() => {
    "specialistID": specialistID,
    "clinicID": clinicID,
    "specialistName": specialistName,
    "specialistTitle": specialistTitle,
    "phone": phone,
    "password": password,
    "logStatus": logStatus,

  };
}