// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<Specialist> specialistFromJson(String str) => List<Specialist>.from(json.decode(str).map((x) => Specialist.fromJson(x)));

String specialistToJson(List<Specialist> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Specialist {
  String specialistId;
  String clinicId;
  String specialistName;
  String specialistTitle;
  String phone;
  String password;

  Specialist({
    required this.specialistId,
    required this.clinicId,
    required this.specialistName,
    required this.specialistTitle,
    required this.phone,
    required this.password,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) => Specialist(
    specialistId: json["specialistID"],
    clinicId: json["clinicID"],
    specialistName: json["specialistName"],
    specialistTitle: json["specialistTitle"],
    phone: json["phone"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "specialistID": specialistId,
    "clinicID": clinicId,
    "specialistName": specialistName,
    "specialistTitle": specialistTitle,
    "phone": phone,
    "password": password,
  };
}
