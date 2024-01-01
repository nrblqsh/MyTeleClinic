import 'dart:io';
import 'dart:typed_data';

import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_teleclinic/Specialists/editProfileSpecialist.dart';
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

  String imagePath = '';

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();


   final Patient _patients = Patient(
    patientID: 0, // You may need to set the correct specialist ID
    icNumber: '', // You may need to set the correct clinic ID
    patientName: '', // You may need to set the correct specialist name
    gender: '', // You may need to set the correct specialist title
    phone: '', // You may need to set the correct phone number
    password: '', // You may need to set the correct password
    birthDate: DateTime.now(), // You may need to set the correct log status
    patientImage: Uint8List(0), // Empty Uint8List for no image
  );


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

    bool success = await updatedPatientData.editPatient();

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
    _loadPatientImage();
  //  loadProfilePicture();
  }






  ImageProvider<Object>? _getImageProvider() {
    if (_patients.patientImage != null && _patients.patientImage!.isNotEmpty) {
      return MemoryImage(_patients.patientImage!); // Display the existing image
    } else {
      return AssetImage('asset/profile image default.jpg');
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


  Future<void> _loadPatientImage() async {

    try {
      Uint8List? imageBytes = await Patient.getPatientImage();

      if (imageBytes != null && imageBytes.isNotEmpty) {
        setState(() {
          _patients.patientImage = imageBytes;
        });
      } else {
        print('Invalid or empty image data');
      }
    } catch (e) {
      print('Error loading specialist image: $e');
    }
  }


  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  Uint8List? imageData = await _getImage(ImageSource.gallery);
                  if (imageData != null) {
                    setState(() {
                      _patients.patientImage= imageData;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  Uint8List? imageData = await _getImage(ImageSource.camera);
                  if (imageData != null) {
                    setState(() {
                      _patients.patientImage= imageData;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Future<Uint8List?> _getImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Adjust the quality (0 to 100)
      );

      if (image != null) {
        Uint8List imageData = await File(image.path).readAsBytes();

        // Call setState to trigger a rebuild
        setState(() {
          imagePath = image.path;
          _imageFile = File(image.path);
         _patients.patientImage= imageData;
        });

        return imageData;
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () async {
            bool shouldDiscardChanges = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Discard Changes?'),
                  content: Text('Are you sure you want to discard changes?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // User canceled
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true); // User confirmed
                      },
                      child: Text('Yes'),
                    ),
                  ],
                );
              },
            );

            if (shouldDiscardChanges ?? false) {
              // User confirmed to discard changes
              Navigator.pop(context); // Go back
            }
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
                  _pickImage();                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      key: UniqueKey(), // Add this line
                      radius: 45,
                      backgroundImage: _getImageProvider(),
                    ),
                    Positioned(
                      top: 60,
                      left: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey, // Adjust the color and opacity
                          borderRadius: BorderRadius.circular(30), // Adjust the radius
                        ),
                        padding: EdgeInsets.all(8), // Adjust the padding as needed
                        child: Icon(
                          Icons.edit,
                          color: Colors.white, // Adjust the icon color
                          size: 10,
                        ),
                      ),
                    )

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
              "+6$_phone",
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
              30,
              _patientName ?? '',
              nameController,
              TextInputType.text,
            ),

            _buildTitle(15, 'IC Number'),
            _buildICNumberTextField(
              15,
              30,
              _icNum ?? '',
              icNumController,
              TextInputType.phone,
            ),

            _buildTitle(15, 'Phone Number'),
            _buildPhoneNumberTextField(
              15,
              30,
              _phone ?? '',
              phoneController,
              TextInputType.phone,
            ),

            _buildTitle(15, 'Gender'),

            Padding(
              padding: const EdgeInsets.only(left: 5, top: 10, right: 30),
              child: Row(
                children: [
                  SizedBox(width: 10,
                  height: 30,),
                  GestureDetector(
                    onTap: _selectGender,
                    child: SizedBox(
                        height: 40,
                      child: Container(
                        padding:
                        EdgeInsets.only(top: 10, right: 519),
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
                  ),
                ],
              ),
            ),

            _buildTitle(15, 'Birthday Date'),
            Padding(
              padding: const EdgeInsets.only(left: 17, top: 10.0, right:30),
              child: TextFormField(
                onTap: () {
                  _openDatePicker(context);
                },
                controller: TextEditingController(
                  text: _birthDate != null
                      ? _formatDate(_birthDate) : _formatDate(_selectedDate),
                ),

                decoration: InputDecoration(
                  hintText: 'Select Birth Date',

                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.5)
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(hexColor('#024352')),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),


            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 280.0),
              child: SizedBox(
                width: 260,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    bool shouldEditProfile = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text('Are you sure you want'
                              ' to edit your profile?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // User canceled
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // User confirmed
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldEditProfile ?? false) {


                      // Call the function to update the specialist profile
                      await _patients.editPatient(
                        patientName: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        icNumber: icNumController.text.trim(),
                        patientImage:_patients.patientImage,
                        gender: _gender,
                        birthDate: _birthDate
                        ,

                      );
                      await _loadID();


                      Fluttertoast.showToast(
                        msg: 'You have successfully updated your profile',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );



                    }



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
      maxDateTime: DateTime.now(), // Set the maximum date to today

      onChange: (selectedDate) {
        print(selectedDate);
        setState(() {
          _birthDate = selectedDate;
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


  Widget _buildPhoneNumberTextField(
      double leftside,
      double righside,
      String innerText,
      TextEditingController controller,
      TextInputType inputType,
      ) {
    return Container(
      padding: EdgeInsets.only(left: leftside, right: righside, top: 5, bottom: 10),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: innerText,
            ),
            keyboardType: inputType,
            onEditingComplete: () {
              // Validate phone number length
              String value = controller.text;
              if (value.length <= 8 || value.length >= 12 ||
                  !_containsNumber(value)) {
                _showErrorPopup('Phone number must'
                    ' between 9 and 11 digits');
              }
              else {
                // If validation passes, move focus to the next focus node
                FocusScope.of(context).requestFocus(FocusNode());
              }
            },
          ),
        ],
      ),
    );
  }


  Widget _buildICNumberTextField(
      double leftside,
      double righside,
      String innerText,
      TextEditingController controller,
      TextInputType inputType,
      ) {
    return Container(
      padding: EdgeInsets.only(left: leftside, right: righside, top: 5, bottom: 10),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: innerText,
            ),
            keyboardType: inputType,
            onEditingComplete: () {

              String value = controller.text;
              if (value.length !=12  || !_containsNumber(value)) {
                _showErrorPopup('IC Number must have 12 digits');
              }
              else {
                // If validation passes, move focus to the next focus node
                FocusScope.of(context).requestFocus(FocusNode());
              }
            },
          ),
        ],
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
              onEditingComplete: () {
                // Validate phone number length
                String value = controller.text;
                if (_containsSpecialCharAndNumbers(value)) {
                  _showErrorPopup('Invalid input: Special Characters or Numbers '
                  ' are not allowed.');            }
                else {
                  // If validation passes, move focus to the next focus node
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              }
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



  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Credentials'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
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


  bool isPhoneNumberValid(String phoneNumber) {
    return phoneNumber.length >= 8 && phoneNumber.length <= 11;
  }


  bool isICNumberValid(String icNumber){
    return icNumber.length == 12;
  }

  bool _containsNumber(String value) {
    return RegExp(r'[0-9]').hasMatch(value);
  }

  bool _containsSpecialCharAndNumbers(String value) {
    return
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value) ||
     RegExp(r'[0-9]').hasMatch(value)
    ;
  }


}
