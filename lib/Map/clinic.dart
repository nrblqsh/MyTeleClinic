import 'dart:convert';

class Clinic {
  int clinicId;
  String clinicName;
  String clinicLocation;
  double latitude;
  double longitude;
  String clinicType;
  String phone;
  String operationHour;
  String clinicEmail;

  Clinic({
    required this.clinicId,
    required this.clinicName,
    required this.clinicLocation,
    required this.latitude,
    required this.longitude,
    required this.clinicType,
    required this.phone,
    required this.operationHour,
    required this.clinicEmail,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) => Clinic(
    clinicId: json["clinicID"],
    clinicName: json["clinicName"],
    clinicLocation: json["clinicLocation"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    clinicType: json["clinicType"],
    phone: json["phone"],
    operationHour: json["operationHour"],
    clinicEmail: json["clinicEmail"],
  );

  Map<String, dynamic> toJson() => {
    "clinicID": clinicId,
    "clinicName": clinicName,
    "clinicLocation": clinicLocation,
    "latitude": latitude,
    "longitude": longitude,
    "clinicType": clinicType,
    "phone": phone,
    "operationHour": operationHour,
    "clinicEmail": clinicEmail,
  };
}
