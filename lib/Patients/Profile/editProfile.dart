import 'dart:async';
import 'dart:io';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import '../../Model/patient.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';


void main(){
  runApp( MaterialApp(
    home: EditProfile(),
  ));
}


class EditProfile extends StatefulWidget {



  @override
  State<EditProfile> createState() => _EditProfileState();
}


class _EditProfileState extends State<EditProfile> {
  List<Patient> patients = [];

  String? _patientName ;
  String? _phone;
  String? _icNum;
  DateTime? _birthDate;
  String? _gender;
  String? _selectedGender = 'Male';
//  String? _profileImagePath;
  DateTime? _selectedDate = DateTime.now();
  String? _icNumber;
  String? _password;


   int? patientID;

  List<String> dropDownState= ['Perak','Kedah','Penang'];
   final genderPicker= ['Male','Female'];

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController icNumController = TextEditingController();
  TextEditingController genderController = TextEditingController();
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
      birthDate: _selectedDate ?? DateTime.now(),
      password: _password,
    );

    // int status = await updatedPatientData.save();
    //
    // if (status == 200) {
    //   print("Profile updated successfully");
    // } else {
    //   print("Failed to update profile. Status: $status");
    // }
  }



  @override
  void initState() {
    //first thing yang akan system buat when comes to this page
    super.initState();
   // _loadPatients();

    _loadID();

    // Call the method to load data when the widget is initialized
  }

  // void saveImagePath(String imagePath) async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('imagePath', imagePath);
  // }

  // Future<void> _loadPatients() async {
  //   print("masuk");
  //   try {
  //     List<Patient> allPatients = await Patient.loadAll();
  //     for (var patient in allPatients) {
  //       print("Patient ID: ${patient.patientID}");
  //       print("Patient Name: ${patient.patientName}");
  //       print("Phone: ${patient.phone}");
  //       print("gender ${patient.gender}");
  //       print("icNum ${patient.icNum}");
  //       print("birthdate ${patient.birthDate}");
  //
  //
  //     }
  //
  //     // Check if the list is empty and treat it as a successful request
  //     if (allPatients.isEmpty) {
  //       print("Successful request: Empty patient list");
  //     }
  //   } catch (e) {
  //     // Handle other errors
  //     print("Error loading patients: $e");
  //   }
  // }
  Future<void> _loadID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int storedID = prefs.getInt("patientID") ?? 0;
    print(storedID);

    List<Patient> patients = await Patient.loadAll();

    if (patients.isNotEmpty) {
      for (Patient patient in patients) {
        setState(() {
          _patientName = patient.patientName;
          _phone = patient.phone;
          _icNum = patient.icNumber;
          _gender = patient.gender.toString();
          _selectedGender = patient.gender.toString();
          _birthDate = patient.birthDate;
        });

        print("Patient Information:");
        print("Name: $_patientName");
        print("Phone: $_phone");
        print("IC Number: $_icNum");
        print("Gender: $_gender");
        print("Gender selected: $_selectedGender");
        print("Birth Date: $_birthDate");
        print("\n");
      }
    } else {
      print('No patient data available');
    }
  }


//   Future<void> _loadID() async {
//
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     int storedID = prefs.getInt("patientID") ?? 0;
//     String storedPatientName = prefs.getString("patientName") ?? '';
//     String storedPhone = prefs.getString("phone") ?? '';
//
//     //String storedName = prefs.getString("patientName") ?? "";
//     patientID = storedID;
//     _patientName = storedPatientName;
//     _phone =storedPhone;
//
//
//     patients.addAll(await Patient.loadAll());
//     print('Patients data: $patients');
//     print(storedID);
//     print(storedPatientName);
//     print(storedPhone);
//
//     patientID = storedID;
//     _patientName = storedPatientName;
//     _phone = storedPhone;
//
//
//
//
// // In your _loadID function:
// //     setState(() {
// //
// //       _gender = genderSQL(patients.first.gender);
// //
// //       print("print _gender $_gender");// Use the mapping function
// //       _icNumber=patients.first.icNum;
// //       _birthDate = patients.first.birthDate;
// //      // _phone = patients.first.phone;
// //       _address = patients.first.address;
// //       _postCode = patients.first.postcode;
// //       _state = patients.first.state;
// //
// //       _selectedDate = _birthDate ?? DateTime.now();
// //       _dateController.text = _formatDate(_selectedDate ?? DateTime.now());
// //       _selectedGender = patients.first.gender ?? '';
// //       print("print _selectedgender $_selectedGender");// Use the mapping function
// //
// //       //_selectedState = _state;
// //      });
//
//   }

  // Future<void> _loadImagePath() async {
  //   // ... other code
  //
  //   // Set _profileImagePath directly from the loaded patient data
  //   _profileImagePath = patients.isNotEmpty ? patients.first.profileImagePath : null;
  //
  //   setState(() {
  //     _imageFile = _profileImagePath != null ? XFile(_profileImagePath!) : null;
  //   });
  // }


  @override
  Widget editTitle(double leftside, String label) {
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
                        fontSize: 18, // Reduce the font size for the label
                        fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                ],
              ),
            ],
          ),
        )
    );
  }


  Widget txtField(double leftside, double righside,
      String innerText, TextEditingController controller,
      TextInputType inputType,) {
    return Container(
      padding: EdgeInsets.only(left: leftside, right: righside,
          top: 5, bottom: 10),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: innerText,
              // labelText: upperText,
              enabledBorder: inputBorder(),
              focusedBorder: focusedBorder(),

            ),
            keyboardType: inputType,
          ),
        ],
      ),
    );
  }



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
              child: InkWell(
                onTap: () {
                  print("Circle avatar tapped");
                  // showModalBottomSheet(context: context,
                  //     builder:((builder) => bottomSheet()),
                  // );
                  // Add your logic for handling the tap on the CircleAvatar here
              // getImage();
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      // backgroundImage: _imageFile == null
                      //     ? (patients.isNotEmpty && patients.first.profileImagePath != null
                      //     ? FileImage(File(patients.first.profileImagePath!))
                      //     : AssetImage("asset/profile image.jpg")) as ImageProvider<Object>?
                      //     : FileImage(File(_imageFile!.path!)) as ImageProvider<Object>?,
                    ),








                    Positioned(
                      top: 63,
                      left: 60,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.black,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
     

  SizedBox(height: 15),
            Text(
              _patientName?? "test",

              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Text(
            "+6$_phone"  ,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0,),

            editTitle(10, 'Name'),
            txtField(10, 19,
                _patientName??"test", nameController,
                TextInputType.text),


            Row(
              children: <Widget>[
                Expanded(
                  child: editTitle(10, 'IC Number'),

                ),
                SizedBox(width: 10), // Adjust the width as needed
                Expanded(
                  child: editTitle(8, 'Phone Number'),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: txtField(
                    10, 10,
                    _icNum?? '',
                    icNumController,
                    TextInputType.phone,

                  ),
                ),
                SizedBox(width: 10), // Adjust the width as needed
                Expanded(
                  child: txtField(
                    2, 10,
                    _phone?? '',
                    phoneController,
                    TextInputType.phone,
                  ),
                ),
              ],
            ),

            // Add width property here
            // Add width property here
            Row(
              children: [
                editTitle(10, 'Gender'),
                editTitle(90, 'Birthday Date'),

              ],
            ),


            Padding(
              padding: const EdgeInsets.only(left: 8, top: 3),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(height: 30),
                      Container(
                        height: 61,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(

                              color: Colors.blueGrey,
                              width: 2
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: (){
                            print("testing");
                            _genderPick(context);
                            print(_selectedGender);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            padding: EdgeInsets.zero, // Remove default padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: SizedBox(width:95,
                                  child: Text(
                                    _selectedGender?.isNotEmpty ?? false ? _selectedGender! : 'Gender',

                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 18

                                    ),

                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.blueGrey,
                              ),
                            ],
                          ),

                        ),
                      ),
                      // Add width property here
                      Padding(
                        padding: const EdgeInsets.only( left:35,top: 5.0),
                        child: Row(
                          children: <Widget>[

                            SizedBox(height: 68),
                               Container(
                                height: 63,
                                width: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(

                                      color: Colors.blueGrey,
                                      width: 2
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _openDatePicker(context);
                                    // Add any code that should run after the date selection is completed
                                  },

                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.white,
                                    padding: EdgeInsets.zero, // Remove default padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left:13.0),
                                        child: SizedBox(width:150,
                                          child: Text(
                                            _dateController.text,
                                            style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 18,
                                            ),
                                          ),

                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.blueGrey,
                                      ),
                                    ],
                                  ),

                                ),
                              ),

                          ],
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),


             Padding(
                padding: const EdgeInsets.only(bottom:300.0),
                child: Container(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                     // login();
                      editProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                      ),
                      backgroundColor: Color(hexColor('C73B3B')), // Set your preferred background color
                    ),
                    child: Text('Edit Profile',
                      style:TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),




          ],

        ),


      ),
    );
  }

  void _genderPick(BuildContext context) {
    BottomPicker(
      items: genderPicker.map((gender) => Text(gender)).toList(),
      title: 'Select the gender',
      pickerTextStyle: TextStyle(
        color: Colors.blue,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      titleStyle: TextStyle(
        fontSize: 20, // Adjust the font size as needed
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      onChange: (selectedIndex) {
        // Handle the selectedGender, which will be null if the user cancels the picker
        if (selectedIndex != null) {
          setState(() {
            _selectedGender = genderPicker[selectedIndex].toString();
          });
        }
      },
      bottomPickerTheme: BottomPickerTheme.blue,
    ).show(context);
  }




  Future<void> _openDatePicker(BuildContext context) async{
    BottomPicker.date(
      title: "Select a Date",
      dateOrder:DatePickerDateOrder.dmy,
      pickerTextStyle: TextStyle(fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue),
      titleStyle: TextStyle(fontSize: 18,
        color: Colors.blue,
        fontWeight: FontWeight.bold,

      ),
      onChange: (selectedDate){
        print(selectedDate);
        setState(() {
          _selectedDate = selectedDate;
          _dateController.text = _formatDate(selectedDate);


        });

      },
      bottomPickerTheme: BottomPickerTheme.plumPlate ,
    ).show(context);

  }





  String _formatDate(DateTime? date) {
    if (date != null) {
      return DateFormat("d MMMM yyyy").format(date);
    }
    return ''; // Return an empty string or any default value when the date is null.
  }


  OutlineInputBorder inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Colors.blueGrey, width: 2,),

    );
  }
  OutlineInputBorder focusedBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.all(
            Radius.circular(12)),
        borderSide: BorderSide(color: Color(
            hexColor('#024362')),
            width: 2)
    );
  }
/*
  when user click the specific textfield,
  the colour of the border will change
 */


  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }


}