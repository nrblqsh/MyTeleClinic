import 'dart:convert';

class Clinic {
  int clinicId;
  String clinicName;
  String clinicLocation;
  double latitude;
  double longitude;
  String clinicType;
  String phone;



  Clinic({
    required this.clinicId,
    required this.clinicName,
    required this.clinicLocation,
    required this.latitude,
    required this.longitude,
    required this.clinicType,
    required this.phone,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) => Clinic(
    clinicId: json["clinicID"],
    clinicName: json["clinicName"],
    clinicLocation: json["clinicLocation"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    clinicType: json["clinicType"],
    phone: json["phone"],

  );

  Map<String, dynamic> toJson() => {
    "clinicID": clinicId,
    "clinicName": clinicName,
    "clinicLocation": clinicLocation,
    "latitude": latitude,
    "longitude": longitude,
    "clinicType": clinicType,
    "phone": phone,

  };
}