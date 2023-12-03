import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/patient.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

void main(){
  runApp( MaterialApp(
    home: EditProfile1(),
  ));
}


class EditProfile1 extends StatefulWidget {


  //  String patientName;
  //  String phone;
  //  String icNum;
  //  DateTime birthDate;
  //  String gender;
  //  String address;
  //
  // EditProfile({ this.patientName = '', this.phone='', this.icNum='',
  // this.birthDate,this.gender='', this.address=''});  //constructor

  @override
  State<EditProfile1> createState() => _EditProfileState();
}


class _EditProfileState extends State<EditProfile1> {
  List<Patient> patients = [];

  String _patientName ='';
  String _phone='';
  String? _icNum;
  DateTime? _birthDate;
  String? _gender;
  String? _address ;
  String? _postCode;
  String? _state;
  String? _selectedState ;
  String? _selectedGender = 'Male';
  DateTime? _selectedDate = DateTime.now();


   int? patientID;

  List<String> dropDownState= ['Perak','Kedah','Penang'];
  List<String> dropDownGender= ['Male','Female'];


  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController icNumController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _stateController = TextEditingController();

  TextEditingController _postCodeController = TextEditingController();

  void editProfile() async {
    String patientName = nameController.text.trim();
    String phone = phoneController.text.trim();
    String icNum = icNumController.text.trim();
    String address = _addressController.text.trim();

    Patient updatedPatient = Patient(
      patientID: patientID,
      patientName: patientName,
      phone: phone,
      icNum: icNum,
      gender: _gender ?? '',
      birthDate: _selectedDate ?? DateTime.now(),
      address: address,
      password: '', // You might want to update this if necessary
      state: _selectedState ?? '',
      postcode: _postCodeController.text.trim(),
    );

    bool success = await updatedPatient.save();

    if (success) {
      // Update successful, you might want to show a success message
      print("Profile updated successfully");
    } else {
      // Update failed, show an error message
      print("Failed to update profile");
    }
  }


  @override
  void initState() {
    //first thing yang akan system buat when comes to this page
    super.initState();
    _loadID();
    _selectedState = dropDownState.isNotEmpty ? dropDownState[0] : null;

    // Call the method to load data when the widget is initialized
  }


  Future<void> _loadID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int storedID = prefs.getInt("patientID") ?? 0;
    String storedPatientName = prefs.getString("patientName") ?? '';
    String storedPhone = prefs.getString("phone") ?? '';

    //String storedName = prefs.getString("patientName") ?? "";
    patientID = storedID;
    _patientName = storedPatientName;
    _phone =storedPhone;


    patients.addAll(await Patient.loadAll());
    print('Patients data: $patients');
    print(storedID);
    print(storedPatientName);
    print(storedPhone);

    patientID = storedID;
    _patientName = storedPatientName;
    _phone = storedPhone;

    String genderSQL(String ? genderFromDatabase) {
      if (genderFromDatabase == 'L') {
        return 'Male';
      } else if (genderFromDatabase == 'P') {
        return 'Female';
      } else {
        return 'Unknown'; // or handle the case when the value is neither 'L' nor 'P'
      }
    }


// In your _loadID function:
    setState(() {

      _gender = genderSQL(patients.first.gender); // Use the mapping function
      _icNum=patients.first.patientName;
      _birthDate = patients.first.birthDate;
     // _phone = patients.first.phone;
      _address = patients.first.address;
      _postCode = patients.first.postcode;
      _state = patients.first.state;

      _selectedDate = _birthDate ?? DateTime.now();
      _dateController.text = _formatDate(_selectedDate ?? DateTime.now());
      _selectedGender = _gender ?? '';
      //_selectedState = _state;
     });

  }


  // Future<void> fetchPatientData(String phone) async {
  //   final response = await http.get(Uri.parse('YOUR_PHP_API_URL?phone=$phone'));
  //
  //   if (response.statusCode == 200) {
  //     // If the server returns a 200 OK response, parse the patient data
  //     List<dynamic> data = json.decode(response.body);
  //     // Display the data as needed
  //     print(data);
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // throw an exception.
  //     throw Exception('Failed to load patient data');
  //   }
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
              child: GestureDetector(
                onTap: () {
                  print("circl avarat");
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage("asset/logo.png"),
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
              _patientName,

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
            SizedBox(height: 16.0,),

            editTitle(10, 'Name'),
            txtField(10, 19,
                _patientName, nameController,
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
                editTitle(80, 'Birthday Date'),
              ],
            ),


            // Padding(
            //   padding: const EdgeInsets.only(left: 10, top: 5),
            //   child: Column(
            //     children: [
            //       Row(
            //         children: [
            //           SizedBox(width: 10),
            //           Radio(
            //             value: "Male",
            //             groupValue: _gender,
            //             onChanged: (value) {
            //               setState(() {
            //                 _gender = value!;
            //                 print("men selected");
            //               });
            //             },
            //           ),
            //           const Text(
            //             "Male",
            //             style: TextStyle(
            //               fontSize: 20,
            //               color: Colors.black,
            //             ),
            //           ),
            //           // Add width property here
            //
            //         ],
            //       ),
            //       Row(
            //         children: [
            //           SizedBox(width: 10),
            //           Radio(
            //             value: "Male",
            //             groupValue: _gender,
            //             onChanged: (value) {
            //               setState(() {
            //                 _gender = value!;
            //                 print("men selected");
            //               });
            //             },
            //           ),
            //           const Text(
            //             "Male",
            //             style: TextStyle(
            //               fontSize: 20,
            //               color: Colors.black,
            //             ),
            //           ),
            //           // Add width property here
            //
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            //
    Padding(
    padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 100),
    child: Row(
    children: [
    Container(
    width: 180,
    child: Align(
    alignment: Alignment.centerLeft,
    child: Padding(
    padding: const EdgeInsets.only(left: 5.0, bottom:5),
    child: Container(
    height: 60,
    width:180,
    decoration: BoxDecoration(
    border: Border.all(
    color: Color(
    hexColor('#024362')),
    width: 2
    ),
    borderRadius: BorderRadius.circular(20),
    ),
    child: Align(
    alignment: Alignment.center, // Center the text
    child: DropdownButton<String>(
    isExpanded: true,
    isDense: false,
    hint: const Text('State'),
    value: _selectedState,
    borderRadius: BorderRadius.circular(20),
    items: dropDownState.map((String value) {
    return DropdownMenuItem<String>(
    value: value,
    child: Text(value),
    );
    }).toList(),
    onChanged: (newValue) {
    setState(() {
    _selectedState = newValue;
    });
    },
    ),
    ),
    ),
    ),
    ),
    ),
            // editTitle(10,'BirtDate'),
            // Padding(padding: EdgeInsets.all(30),
            // child: TextField(
            //   controller: _dateController,
            //   decoration:InputDecoration(
            //     labelText: 'Date',
            //     enabledBorder: inputBorder(),
            //     focusedBorder: focusedBorder(),
            //     filled: true,
            //
            //   ),
            //   readOnly: true,
            //   onTap: (){
            //
            //   },
            // ),
            // ),










            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: TextField(
            //     decoration: InputDecoration(
            //
            //       hintText: "test"),
            //     controller: phoneController,
            //   ),
            // ),
            // // txtField(
            // //     phone ?? '', phoneController,
            // //     Icons.phone, TextInputType.phone),

            // Padding(
            //   padding: const EdgeInsets.only(left: 15.0, top: 10.0),
            //   child: Row(
            //     children: <Widget>[
            //       Expanded(
            //         child: Container(
            //           height: 100,
            //           child: CupertinoDatePicker(
            //             initialDateTime: _dateTime,
            //             mode: CupertinoDatePickerMode.date,
            //             onDateTimeChanged: (dateTime) {
            //               print(dateTime);
            //               setState(() {
            //                 _dateTime = dateTime;
            //               });
            //             },
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.only( left:20,top: 10.0),
              child: Row(
                children: <Widget>[

                   Container(
                      height: 45,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(

                            color: Color(
                                hexColor('#024362')),
                          width: 2
                        ),
                         borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: (){
                          print("testing");
                          _openDatePicker(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white70,
                          padding: EdgeInsets.zero, // Remove default padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          _dateController.text,
                          style: TextStyle(
                            color: Colors.blue,

                        ),

                      ),

                    ),
                   ),
                ],
              ),
            ),

            editTitle(10, 'Address'),
               txtField(10, 19,
                  _address?? '', _addressController,
                  TextInputType.text),

       Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      editTitle(10, 'State'),
                      editTitle(140, 'PostCode'),

                    ],
                  ),
                // Expanded(
                //     child:Row(
                //       children: <Widget>[
                //              // txtField(10, 5, "state", _stateController, TextInputType.text),
                //
                //       ],
                //     )
                // )

                  // Flexible(
                  //   child: Row(
                  //     children: <Widget>[
                  //       txtField(10, 5, "state", _stateController, TextInputType.text),
                  //       txtField(10, 5, "postcode", _postCodeController, TextInputType.text),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15, bottom: 100),
              child: Row(
                children: [
                  Container(
                    width: 180,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom:5),
                        child: Container(
                          height: 60,
                          width:180,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(
                                    hexColor('#024362')),
                                width: 2
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Align(
                            alignment: Alignment.center, // Center the text
                            child: DropdownButton<String>(
                              isExpanded: true,
                              isDense: false,
                              hint: const Text('State'),
                              value: _selectedState,
                              borderRadius: BorderRadius.circular(20),
                              items: dropDownState.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedState = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: txtField(
                      25,
                      10,
                      _postCode?? '',
                      _postCodeController,
                      TextInputType.phone,
                    ),
                  ),
                ],
              ),
            ),



             Padding(
                padding: const EdgeInsets.only(bottom:300.0),
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




          ],

        ),


      ),
      ]
        )
      )
    );
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
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Color(
          hexColor('#024362')), width: 3,),

    );
  }

/*
  when user click the specific textfield,
  the colour of the border will change
 */
  OutlineInputBorder focusedBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.all(
            Radius.circular(20)),
        borderSide: BorderSide(color: Color(
            hexColor('#024362')),
            width: 3)
    );
  }

  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }


}