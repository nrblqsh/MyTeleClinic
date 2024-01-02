import 'dart:typed_data';

import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Main/main.dart';
import '../Model/patient.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/specialist.dart';
import 'dart:io';  // Import this for File


void main() {
  runApp(MaterialApp(
    home: EditProfileSpecialist(),
  ));
}

class EditProfileSpecialist extends StatefulWidget {
  @override
  State<EditProfileSpecialist> createState() => _EditProfileSpecialistState();
}

class _EditProfileSpecialistState extends State<EditProfileSpecialist> {
  late int specialistID;
  late int clinicID;

  Uint8List? _selectedImageData; // Add this line

  String? _specialistName;
  String? _phone;
  String? _password;
  String? _title;
  String imagePath = '';

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();





  final Specialist _specialist = Specialist(
    specialistID: 0, // You may need to set the correct specialist ID
    clinicID: 0, // You may need to set the correct clinic ID
    specialistName: '', // You may need to set the correct specialist name
    specialistTitle: '', // You may need to set the correct specialist title
    phone: '', // You may need to set the correct phone number
    password: '', // You may need to set the correct password
    logStatus: '', // You may need to set the correct log status
    clinicName: '',
    specialistImagePath: Uint8List(0), // Empty Uint8List for no image
  );


  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController specialistTitleController = TextEditingController();



  @override
  void initState() {
    super.initState();
    _loadID();
  _loadSpecialistImage();
  }


  Future<void> _loadID() async {
    try {
      List<Specialist> specialists = await Specialist.loadAll();

      if (specialists.isNotEmpty) {
        Specialist firstSpecialist = specialists.first;

        print("Raw JSON Data: ${firstSpecialist.toJson()}");

        setState(() {
          _specialistName = firstSpecialist.specialistName ?? 'N/A';
          _phone = firstSpecialist.phone ?? 'N/A';
          _title = firstSpecialist.specialistTitle ?? 'N/A';
          _password = firstSpecialist.password ?? 'N/A';
        });

        print("Patient Information:");
        print("Name: $_specialistName");
        print("Phone: $_phone");
        print("IC Number: $_title");

        print("\n");
      } else {
        print('No patient data available');
      }
    } catch (e) {
      print('Error loading specialists: $e');
    }
  }

  Future<void> _loadSpecialistImage() async {
    try {
      Uint8List? imageBytes = await Specialist.getSpecialistImage();

      if (imageBytes != null && imageBytes.isNotEmpty) {
        setState(() {
          _specialist.specialistImagePath = imageBytes;
        });
      } else {
        print('Invalid or empty image data');
      }
    } catch (e) {
      print('Error loading specialist image: $e');
    }
  }

// ...



  // Future<void> _searchClinics(String searchTerm) async {
  //   try {
  //     if (searchTerm.isEmpty) {
  //       setState(() {
  //         clinicSuggestions = [];
  //         isClinicNameValid = false;
  //       });
  //       return;
  //     }
  //
  //     final response = await http.get(
  //       Uri.parse(
  //         'http://${MyApp.ipAddress}/teleclinic/getClinicName.php?action=getClinicNames&searchTerm=$searchTerm',
  //       ),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final dynamic responseData = json.decode(response.body);
  //
  //       if (responseData['status'] == 'success') {
  //         final dynamic data = responseData['data'];
  //
  //         // Ensure data is List<dynamic>
  //         if (data is List<dynamic>) {
  //           setState(() {
  //             clinicSuggestions = data
  //                 .where((clinic) =>
  //                 clinic['clinicName']
  //                     .toString()
  //                     .toLowerCase()
  //                     .contains(searchTerm.toLowerCase()))
  //                 .map<String>((item) {
  //               return item['clinicName'] as String;
  //             }).toList();
  //
  //             // Reset the flag when there are suggestions
  //             isClinicNameValid = true;
  //           });
  //         } else {
  //           print('Invalid data format: $data');
  //         }
  //       } else {
  //         print('Error: ${responseData['status']}');
  //       }
  //     } else {
  //       print('Failed to fetch clinic names. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching clinic names: $e');
  //   }
  // }
  //


  ImageProvider<Object>? _getImageProvider() {
    if (_specialist.specialistImagePath != null && _specialist.specialistImagePath!.isNotEmpty) {
      return MemoryImage(_specialist.specialistImagePath!); // Display the existing image
    } else {
      return AssetImage('asset/profile image default.jpg');
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
              Navigator.pop(context);

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
                    _pickImage();

                  },
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
                _specialistName ??  '',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                "+6$_phone" ?? ' ',
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
                _specialistName ?? '',
                nameController,
                TextInputType.text,
              ),


              _buildTitle(15, 'Phone Number'),
              _buildPhoneNumberTextField(
                15,
                10,
                _phone ?? '',
                phoneController,
                TextInputType.phone,
              ),

              _buildTitle(15, 'Title'),
              _buildTextField(
                15,
                10,
                _title ?? '',
                specialistTitleController,
                TextInputType.text,
              ),

              // _buildTitle(15, 'Clinic Name'),
              // InkWell(
              //   onTap: () {
              //     // Dismiss the keyboard and clear suggestions
              //     FocusScope.of(context).unfocus();
              //     setState(() {
              //       clinicSuggestions.clear();
              //     });
              //   },
              //   child: Container(
              //     padding: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 10),
              //     child: Column(
              //       children: [
              //         TextField(
              //           controller: clinicSearchNameController,
              //           decoration: InputDecoration(
              //             hintText: _clinicName ?? '',
              //           ),
              //           keyboardType: TextInputType.text,
              //           onChanged: (value) {
              //             _searchClinics(value);
              //           },
              //         ),
              //         // Suggestions list
              //         Column(
              //           children: clinicSuggestions.map(
              //                 (suggestion) => GestureDetector(
              //               onTap: () {
              //                 FocusScope.of(context).unfocus();
              //                 clinicSearchNameController.text = suggestion;
              //                 setState(() {
              //                   clinicSuggestions.clear();
              //                 });
              //
              //                 // Dismiss the keyboard
              //               },
              //               child: ListTile(
              //                 title: Text(suggestion),
              //               ),
              //             ),
              //           ).toList(),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              //



              // SizedBox(
              //   width: 260,
              //   height: 45,
              //   child: ElevatedButton(
              //     onPressed: () async {
              //       bool shouldEditProfile = await showDialog(
              //         context: context,
              //         builder: (BuildContext context) {
              //           return AlertDialog(
              //             title: Text('Confirmation'),
              //             content: Text('Are you sure you want to edit your profile?'),
              //             actions: <Widget>[
              //               TextButton(
              //                 onPressed: () {
              //                   Navigator.of(context).pop(false); // User canceled
              //                 },
              //                 child: Text('Cancel'),
              //               ),
              //               TextButton(
              //                 onPressed: () {
              //                   Navigator.of(context).pop(true); // User confirmed
              //                 },
              //                 child: Text('Yes'),
              //               ),
              //             ],
              //           );
              //         },
              //       );
              //
              //       if (shouldEditProfile ?? false) {
              //         // Convert the selected image file to Uint8List
              //         Uint8List imageData = await File(_imageFile!.path).readAsBytes();
              //
              //         bool success = await _specialist.uploadImage(
              //           imageData: imageData,
              //         );
              //
              //         if (success) {
              //           // Update was successful, you can handle it accordingly
              //           print('Image uploaded successfully');
              //         } else {
              //           // Update failed, handle the error
              //           print('Failed to upload image');
              //         }
              //       }
              //     },
              //     style: ElevatedButton.styleFrom(
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //       backgroundColor: Color(hexColor('C73B3B')),
              //     ),
              //     child: Text(
              //       'Insert Image',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontFamily: 'Inter',
              //         fontWeight: FontWeight.w700,
              //         fontSize: 15,
              //       ),
              //     ),
              //   ),
              // ),



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
                            await _specialist.editSpecialist(
                              specialistName: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              specialistTitle: specialistTitleController.text.trim(),
                              specialistImagePath:_specialist.specialistImagePath
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
              if (value.length <= 8 || value.length >= 12) {
                _showErrorPopup('Phone number must be between 9 and 11 digits');
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
            if (_containsNumber(value)) {
              _showErrorPopup('Invalid input: Numbers are not allowed.');            }
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
                      _specialist.specialistImagePath = imageData;
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
                      _specialist.specialistImagePath = imageData;
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
          _specialist.specialistImagePath = imageData;
        });

        return imageData;
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
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

   bool _containsNumber(String value) {
    return RegExp(r'[0-9]').hasMatch(value);
  }

}


