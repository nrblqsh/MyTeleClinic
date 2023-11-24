import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_teleclinic/login.dart';

void main() {
  runApp(const MaterialApp(
    home: ResetPasswordScreen(),
  ));
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  bool _obscureText= true;
  bool _isPasswordEightCharacters = false;
  bool _havePasswordConstraints = false;
  bool _passwordTotalConstraints = false;
  TextEditingController phoneController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController reenterNewPasswordController = TextEditingController();
  bool isPhoneNumberExist = false;

  Future checkPhone() async {
    if (phoneController.text.isEmpty || newPasswordController.text.isEmpty ) {
      print("kosong");

      showDialog(context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Null Information'),
              content: const Text('Cannot be null'),
              actions: [
                TextButton(child:
                const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },)
              ],
            );
          });
    }
    else if(!_passwordTotalConstraints ){
      print("password tak cukup");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Wrong Password'),
            content: const Text('Your password does meet the requirement'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      );
    }
    else {
      print(" otw");
      var url = Uri.http(
          "192.168.8.186", '/teleclinic/resetPassword.php', {'q': '{http}'});

      try {
        var response = await http.post(url, body: {
          "phone": phoneController.text,
          "password" : newPasswordController.text,
        });

        var data = json.decode(response.body);
        if (data.toString() == "success reset") {

          print("test");
          print("Number betul");

          Fluttertoast.showToast(msg: "Success Update Password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,);
          Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              )
          );
    }
        else {
          print("tah la");
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Wrong Phone Number'),
                content: const Text('Your phone number does not registered'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            },
          );
        }
      } catch (error) {
        print("Error: $error");
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'An error occurred while processing your request.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          },
        );
      }
    }
  }


  onPasswordChanged(String password){

    final numericRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])'
    r'(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    setState(() {
      _isPasswordEightCharacters = false;
      if(password.length >=8){
        _isPasswordEightCharacters = true;
      }

      _havePasswordConstraints = false;
      if(numericRegex.hasMatch(password)){
        _havePasswordConstraints=true;
      }

      _passwordTotalConstraints = false;
      if(_isPasswordEightCharacters == true &&
          _havePasswordConstraints == true){

        _passwordTotalConstraints = true;
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context);
          },
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
        child:
        Column(
          children: [

            Padding( padding: const EdgeInsets.only( left: 15.0, top: 40.0),
                child:
                Row(
                    children: <Widget> [
                      Text('Forgot Password',
                        style: TextStyle(decoration: TextDecoration.none,
                            fontSize: 30.0,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700),),
                    ]
                )
            ),


            Padding( padding: const EdgeInsets.only( left: 25.0, top: 30.0),
                child:
                Row(
                    children: <Widget> [
                      Text('Enter your new password',
                        style: TextStyle(decoration: TextDecoration.none,
                            fontSize: 15.0,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w300),),
                    ]
                )
            ),

            Container(
                padding: EdgeInsets.all(20),
                child: Column(  //column untuk letak icon and textfield
                  children: [
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: loginInputBorder(),
                        enabledBorder: loginInputBorder(),
                        focusedBorder: loginFocusedBorder(),
                      ) ,
                      keyboardType: TextInputType.phone,//keyboardType: TextInputType.phone,
                    )
                  ],
                )
            ),

            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    onChanged: (password) => onPasswordChanged(password),
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(!_obscureText ? Icons.visibility : Icons.visibility_off),
                      ),
                      border: loginInputBorder(),
                      enabledBorder: loginInputBorder(),
                      focusedBorder: loginFocusedBorder(),
                    ),
                    obscureText: _obscureText,
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
                        child: Center(child: Icon(Icons.check, color: Colors.white, size: 15)),
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
                        child: Center(child: Icon(Icons.check, color: Colors.white, size: 15)),
                      ),
                      SizedBox(width: 10),
                      Text(" At least uppercase and lowercase, 1 digit, 1 symbol")
                    ],
                  ),
                  SizedBox(height: 10),  // Add space between the two rows
                  // Add more Rows for other indicators if needed
                ],
              ),
            ),




            SizedBox(
              width:260,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  checkPhone();

                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                  ),
                  backgroundColor: Color(hexColor('C73B3B')), // Set your preferred background color
                ),
                child: Text('Update Password',
                  style:TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),


            //   SizedBox(),
            //  GestureDetector(
            //   onTap:()
            //   {
            //     setState(() {
            //       login();
            //     });
            //   },
            //   child:Container(
            //     alignment: Alignment.center,
            //     width: 300,
            //     height: 50,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(50),
            //       color: Color(hexColor('C73B3B')),
            //     ),
            //     child: Text('Login', style:
            //     TextStyle(color: Colors.white,
            //         fontFamily: 'Inter',
            //         fontWeight: FontWeight.w700,
            //         fontSize: 18,
            //         ),),
            //   )
            // ),





          ],
        ),
      ),
    );
  }
}

OutlineInputBorder loginInputBorder(){
  return OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
    borderSide: BorderSide(color: Colors.grey, width:3,),

  );
}

/*
  when user click the specific textfield,
  the colour of the border will change
 */
OutlineInputBorder loginFocusedBorder()
{
  return OutlineInputBorder(
      borderRadius: BorderRadius.all(
          Radius.circular(20)),
      borderSide: BorderSide(color:Color(
          hexColor('#024362')),
          width: 3)
  );
}

int hexColor(String color)
{
  String newColor = '0xff' + color;
  newColor= newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

