import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Model/patient.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: EditProfile1(),
  ));
}

class EditProfile1 extends StatefulWidget {
  @override
  State<EditProfile1> createState() => _EditProfile1State();
}

class _EditProfile1State extends State<EditProfile1> {
  String? _patientName;
  String? _phone;
  String? _icNum;
  DateTime? _birthDate;
  String? _gender = 'Male';
  String? _password;

  String? _selectedGender = 'Male';
  DateTime? _selectedDate = DateTime.now();

  int patientID = 0;

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController icNumController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  void editProfile() async {
    String patientName = nameController.text.trim();
    String phone = phoneController.text.trim();
    String icNumber = icNumController.text.trim();

    Patient updatedPatientData = Patient(
      patientID: patientID,
      patientName: patientName,
      phone: phone,
      icNumber: icNumber,
      gender: _selectedGender,
      birthDate: _selectedDate ,
      password: _password,
    );

    bool success = await updatedPatientData.save();

    if (success) {
      print("Profile updated successfully");
    } else {
      print("Failed to update profile.");
    }
  }




  @override
  void initState() {
    super.initState();
    _loadID();
    loadProfilePicture();
  }

  ImageProvider loadProfilePicture() {
    if (_gender == 'Male') {
      return AssetImage("asset/male1.jpg"); // Change the path accordingly
    } else if (_gender == 'Female') {
      return AssetImage("asset/female.png"); // Change the path accordingly
    } else {
      return AssetImage("asset/male1.jpg"); // Change the path accordingly
    }
  }

  Future<void> _loadID() async {
    List<Patient> patients = await Patient.loadAll();

    if (patients.isNotEmpty) {
      Patient firstPatient = patients.first;

      print("Raw JSON Data: ${firstPatient.toJson()}");

      setState(() {
        _patientName = firstPatient.patientName ?? 'N/A';
        _phone = firstPatient.phone ?? 'N/A';
        _icNum = firstPatient.icNumber ?? 'N/A';
        _gender = firstPatient.gender ?? 'Select Gender';
        _selectedGender = firstPatient.gender ?? 'N/A';
        _birthDate = firstPatient.birthDate;
      });

      print("Patient Information:");
      print("Name: $_patientName");
      print("Phone: $_phone");
      print("IC Number: $_icNum");
      print("Gender: $_gender");
      print("Gender selected: $_selectedGender");
      print("Birth Date: $_birthDate");
      print("\n");
    } else {
      print('No patient data available');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.blue,
        ),
        title: Center(
          child: Image.asset(
            "asset/MYTeleClinic.png",
            width: 594,
            height: 258,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  print("circle avatar tapped");
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: loadProfilePicture(),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Icon(
                        Icons.edit,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              _patientName ?? '',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "test",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            _buildTitle(15, 'Name'),
            _buildTextField(
              15,
              19,
              _patientName ?? '',
              nameController,
              TextInputType.text,
            ),

            _buildTitle(15, 'IC Number'),
            _buildTextField(
              15,
              10,
              _icNum ?? '',
              icNumController,
              TextInputType.phone,
            ),

            _buildTitle(15, 'Phone Number'),
            _buildTextField(
              15,
              10,
              _phone ?? '',
              phoneController,
              TextInputType.phone,
            ),

            _buildTitle(15, 'Gender'),

            Padding(
              padding: const EdgeInsets.only(left: 5, top: 10),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: _selectGender,
                    child: Container(
                      padding:
                      EdgeInsets.only(top: 10, right: 270),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey

                          ),
                        ),
                      ),
                      child: Text(
                        _gender?? "Enter gender",
                        style: TextStyle(
                          fontSize: 16,

                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildTitle(10, 'Birthday Date'),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10.0),
              child: TextFormField(
                onTap: () {
                  _openDatePicker(context);
                },
                controller: TextEditingController(
                  text: _birthDate != null
                      ? _formatDate(_birthDate!) : _formatDate(_selectedDate),
                ),

                decoration: InputDecoration(
                  hintText: 'Select Birth Date',

                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(hexColor('#024352')),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),



            Padding(
              padding: const EdgeInsets.only(bottom: 300.0),
              child: ElevatedButton(
                onPressed: () {
                  editProfile();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Color(hexColor('C73B3B')),
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDatePicker(BuildContext context) async {
    BottomPicker.date(
      title: "Select a Date",
      dateOrder: DatePickerDateOrder.dmy,
      pickerTextStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.normal),
      titleStyle: TextStyle(
        fontSize: 18,
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
      onChange: (selectedDate) {
        print(selectedDate);
        setState(() {
          _selectedDate = selectedDate;
          _dateController.text = _formatDate(selectedDate);
        });
      },
      bottomPickerTheme: BottomPickerTheme.plumPlate,
    ).show(context);
  }

  String _formatDate(DateTime? date) {
    if (date != null) {
      return DateFormat("d MMMM yyyy").format(date);
    }
    return '';
  }

  Widget _buildTitle(double leftside, String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(left: leftside, right: 19, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      double leftside,
      double righside,
      String innerText,
      TextEditingController controller,
      TextInputType inputType,
      ) {
    return Container(
      padding:
      EdgeInsets.only(left: leftside, right: righside, top: 5, bottom: 10),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: innerText,
            ),
            keyboardType: inputType,
          ),
        ],
      ),
    );
  }

  void _selectGender() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Male'),
                  onTap: () {
                    setState(() {
                      _gender = 'Male';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Female'),
                  onTap: () {
                    setState(() {
                      _gender = 'Female';
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  OutlineInputBorder inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
        color: Color(hexColor('#024362')),
        width: 3,
      ),
    );
  }

  OutlineInputBorder focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Color(hexColor('#024362')), width: 3),
    );
  }

  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }
}
