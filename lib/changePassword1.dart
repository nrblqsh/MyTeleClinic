import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: ChangePasswordScreen(),
  ));
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  bool _isOldPasswordVisible = true;
  bool _isNewPasswordVisible = true;
  bool _isConfirmPasswordVisible = true;

  bool _isPasswordEightCharacters = false;
  bool _havePasswordConstraints = false;
  bool _passwordTotalConstraints = false;

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isPhoneNumberExist = false;

  int? patientID;

  @override
  void initState() {
    super.initState();
    _getPatientID();
  }

  Future<void> _getPatientID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      patientID = prefs.getInt('patientID');
    });
  }

  Future<void> updatePassword() async {
    try {
       await _getPatientID();

      final response = await http.post(
        Uri.http("192.168.8.186", '/teleclinic/changePassword1.php', {'q': '{http}'}),
        body: {
          'patientID': patientID.toString(),
          'oldPassword': oldPasswordController.text,
          'newPassword': newPasswordController.text,
        },
      );

     // Inside the updatePassword() method
     if (response.statusCode == 200) {
       final Map<String, dynamic> responseData = json.decode(response.body);
       if (responseData['Success'] != null && responseData['Success']) {
         showToastMessage('Password updated successfully', Colors.green);
         setState(() {
           oldPasswordController.clear();
           newPasswordController.clear();
           confirmPasswordController.clear();
         });
       } else {
         showToastMessage(responseData['message'] ?? 'Failed to Update Password', Colors.red);
       }
     }
    } catch (error) {
      print('Error updating password: $error');
    }
  }


  void showToastMessage(String message, Color backgroundColor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }



  void onPasswordChanged(String password) {
    final numericRegex = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    setState(() {
      _isPasswordEightCharacters = false;
      if (password.length >= 8) {
        _isPasswordEightCharacters = true;
      }

      _havePasswordConstraints = false;
      if (numericRegex.hasMatch(password)) {
        _havePasswordConstraints = true;
      }

      _passwordTotalConstraints = false;
      if (_isPasswordEightCharacters == true &&
          _havePasswordConstraints == true) {
        _passwordTotalConstraints = true;
      }
    });
  }


  void checkAndSave() {
    if (oldPasswordController.text.isNotEmpty &&
        newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty) {
      if (newPasswordController.text == confirmPasswordController.text) {
        if (oldPasswordController.text == newPasswordController.text) {
          // Show AlertDialog if old password is the same as the new password
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Same Password Detected'),
                content: Text('Your old password is the same as the new password. Choose another password.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (!_passwordTotalConstraints) {
          // If requirements are not met, show an AlertDialog
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Password Requirements'),
                content: Text(
                    'Password must have at least 8 characters, including an uppercase letter, a lowercase letter, a digit, and a symbol.'
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Call the function to update the password
          updatePassword();
        }
      } else {
        showToastMessage('Passwords did not match', Colors.red);
      }
    } else {
      Fluttertoast.showToast(msg: 'No changes to update');
    }
  }





  //   void checkAndSave() {
  //     if (confirmPasswordController.text.isEmpty ||
  //         newPasswordController.text.isEmpty ||
  //         confirmPasswordController.text.isEmpty) {
  //       print("kosong");
  //
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             title: const Text('Null Information'),
  //             content: const Text('Cannot be null'),
  //             actions: [
  //               TextButton(
  //                 child: const Text('OK'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //               )
  //             ],
  //           );
  //         },
  //       );
  //     } else if (!_passwordTotalConstraints) {
  //       print("password tak cukup");
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             title: const Text('Wrong Password'),
  //             content: const Text(
  //                 'Your password does not meet the requirement'),
  //             actions: [
  //               TextButton(
  //                 child: const Text('OK'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //               )
  //             ],
  //           );
  //         },
  //       );
  //     } else {
  //       print("otw");
  //       var url = Uri.http("192.168.8.186", '/teleclinic/changePassword1.php', {
  //         'q': '{http}',
  //         'patientID': patientID,
  //       });
  //
  //
  //       try {
  //         var response = await http.post(url, body: {
  //           "patientID": patientID,
  //           "currentPassword": confirmPasswordController.text,
  //           "newPassword": newPasswordController.text,
  //         });
  //
  //         var data = json.decode(response.body);
  //         if (data.toString() == "success reset") {
  //           print("test");
  //           print("Number betul");
  //
  //           Fluttertoast.showToast(
  //             msg: "Success Update Password",
  //             toastLength: Toast.LENGTH_SHORT,
  //             gravity: ToastGravity.CENTER,
  //           );
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => LoginScreen(),
  //             ),
  //           );
  //         } else {
  //           print("tah la");
  //           showDialog(
  //             context: context,
  //             builder: (context) {
  //               return AlertDialog(
  //                 title: const Text('Same Password Detected'),
  //                 content: const Text('Your current password and '
  //                     'new password is the same. Choose othe password'),
  //                 actions: [
  //                   TextButton(
  //                     child: const Text('OK'),
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                   )
  //                 ],
  //               );
  //             },
  //           );
  //         }
  //       } catch (error) {
  //         print("Error: $error");
  //         showDialog(
  //           context: context,
  //           builder: (context) {
  //             return AlertDialog(
  //               title: const Text('Error'),
  //               content: const Text(
  //                   'An error occurred while processing your request.'),
  //               actions: [
  //                 TextButton(
  //                   child: const Text('OK'),
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                 )
  //               ],
  //             );
  //           },
  //         );
  //       }
  //     }
  //   }
  //
  //   void onPasswordChanged(String password) {
  //     final numericRegex = RegExp(
  //         r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  //     setState(() {
  //       _isPasswordEightCharacters = false;
  //       if (password.length >= 8) {
  //         _isPasswordEightCharacters = true;
  //       }
  //
  //       _havePasswordConstraints = false;
  //       if (numericRegex.hasMatch(password)) {
  //         _havePasswordConstraints = true;
  //       }
  //
  //       _passwordTotalConstraints = false;
  //       if (_isPasswordEightCharacters == true &&
  //           _havePasswordConstraints == true) {
  //         _passwordTotalConstraints = true;
  //       }
  //     });
  //   }
  // }

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
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 40.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 30.0,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 30.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Enter your new password',
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 15.0,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [

                  SizedBox(
                    height:60,
                    child: TextField(
                      controller: oldPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isOldPasswordVisible = !_isOldPasswordVisible;
                            });
                          },
                          child: Icon(!_isOldPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        border: loginInputBorder(),
                        enabledBorder: loginInputBorder(),
                        focusedBorder: loginFocusedBorder(),
                      ),
                      obscureText: _isOldPasswordVisible,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  TextField(
                    onChanged: (password) {
                      onPasswordChanged(password);
                    },
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                        child: Icon(!_isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      border: loginInputBorder(),
                      enabledBorder: loginInputBorder(),
                      focusedBorder: loginFocusedBorder(),
                    ),
                    obscureText: _isNewPasswordVisible,
                  ),
                  SizedBox(height: 1),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _isPasswordEightCharacters
                              ? Colors.green
                              : Colors.transparent,
                          border: _isPasswordEightCharacters
                              ? Border.all(color: Colors.transparent)
                              : Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                            child: Icon(Icons.check,
                                color: Colors.white, size: 15)),
                      ),
                      SizedBox(width: 10),
                      Text("Contains at least 8 characters")
                    ],
                  ),
                  SizedBox(height: 1),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _havePasswordConstraints
                              ? Colors.green
                              : Colors.transparent,
                          border: _havePasswordConstraints
                              ? Border.all(color: Colors.transparent)
                              : Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                            child: Icon(Icons.check,
                                color: Colors.white, size: 15)),
                      ),
                      SizedBox(width: 10),
                      Text(
                          " At least uppercase and lowercase, 1 digit, 1 symbol")
                    ],
                  ),

                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Re-enter New Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                        child: Icon(!_isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      border: loginInputBorder(),
                      enabledBorder: loginInputBorder(),
                      focusedBorder: loginFocusedBorder(),
                    ),
                    obscureText: _isConfirmPasswordVisible,
                  ),

                ],
              ),
            ),
            SizedBox(
              width: 260,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                    checkAndSave();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Color(hexColor('C73B3B')),
                ),
                child: Text(
                  'Update Password',
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
}


OutlineInputBorder loginInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide(
      color: Colors.grey,
      width: 3,
    ),
  );
}

OutlineInputBorder loginFocusedBorder() {
  return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(color: Color(hexColor('#024362')), width: 3));
}

int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}
