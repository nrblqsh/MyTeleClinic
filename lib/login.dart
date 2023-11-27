import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/register.dart';
import 'package:my_teleclinic/Patients/patient_home.dart';
import 'package:my_teleclinic/Specialists/specialist_home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'Patients/resetPassword.dart';

void main() {
  runApp(const MaterialApp(
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText= true;
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future login() async {
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      print("dapat");

      showDialog(context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Null Information'),
              content: const Text('Both cannot be null'),
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
    else {
      print("tak dapat");
      var url = Uri.http(
          "192.168.8.186", '/teleclinic/login.php', {'q': '{http}'});

      try {
        var response = await http.post(url, body: {
          "phone": phoneController.text,
          "password": passwordController.text,
        });

        var data = json.decode(response.body);
        if (data["status"] == "success patients" ) {
          // Login successful for patient, extract patient name
          String patientName = data["patientName"];

          final SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString("phone", phoneController.text);
          await pref.setString("password", passwordController.text);
          await pref.setString("patientName", patientName); // Save patient name in SharedPreferences

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientHomePage(phone: phoneController.text, patientName: patientName),
            ),
          );
        } else if (data.toString() == "success specialist") {
          print("doctor masuk");
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Specialist_Home_Screen(),));
        }
        else {
          print("tah la");
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Login Failed'),
                content: const Text('Invalid username or password'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child:
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  Image.asset(
                    "asset/logo.png",
                    width: 280,
                    height: 350,
                  ),
                ],
              ),
            ),


            Padding( padding: const EdgeInsets.only( left: 15.0, bottom: 10.0),
                child:
                Row(
                    children: <Widget> [
                      Text('Welcome Back,',
                        style: TextStyle(decoration: TextDecoration.none,
                            fontSize: 25.0,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700),),
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
                child: Column(  //column untuk letak icon and textfield
                  children: [
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: GestureDetector(onTap: (){
                          setState(() {
                            _obscureText=!_obscureText;
                          });

                        },
                          child:Icon(!_obscureText ?Icons.visibility:
                          Icons.visibility_off),
                        ),
                        border: loginInputBorder(),
                        enabledBorder: loginInputBorder(),
                        focusedBorder: loginFocusedBorder(),
                      ) ,
                      obscureText: _obscureText,
                    )

                  ],
                )
            ),

            // SizedBox(height: 30),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: MaterialButton(minWidth:double.infinity,
            //       onPressed: (){
            //     login();
            //       },
            //   child: Text('Login'),
            //
            //   color: Colors.teal,
            //   textColor: Colors.white,),
            //
            // ),
            SizedBox(
              width:260,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  login();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                  ),
                  backgroundColor: Color(hexColor('C73B3B')), // Set your preferred background color
                ),
                child: Text('Login',
                  style:TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordScreen(),
                  ),
                ); // go to register screen
              },
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(hexColor('#024362')),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),


            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(),
                Text(
                  "Don't have account yet? ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      Navigator.push(context, MaterialPageRoute(builder:
                          (context) => RegisterScreen(),)); //go to register screen
                    });
                  },
                  child: Text(
                    'Register Now',
                    style: TextStyle(
                      color: Color(
                        hexColor('#C73B3B'),
                      ),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

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