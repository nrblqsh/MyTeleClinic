import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import '../login.dart';


void main() {
  runApp(const MaterialApp(
    home: RegisterScreen(),
  ));
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscureText= true;
  bool _isPasswordEightCharacters = false;
  bool _havePasswordConstraints = false;
  bool _passwordTotalConstraints = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future register() async{

    if(nameController.text.isEmpty|| phoneController.text.isEmpty
        || passwordController.text.isEmpty){
      print("dapat sikit");
      Fluttertoast.showToast(msg: "both cannot field",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,);
    }
    else if(!_passwordTotalConstraints ){
      print("password salah");
      Fluttertoast.showToast(msg: "Your Password does not fulfill the requirement",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,);
    }
    else{
      print("tak sikit");
      var url = Uri.http("192.168.8.186", '/teleclinic/register.php', {'q': '{http}'});
      var response = await http.post(url , body: {
        "patientName" : nameController.text.toString(),
        "phone"    : phoneController.text.toString(),
        "password" : passwordController.text.toString(),

      });

      var data = json.decode(response.body);
      if (data == "error") {
        print("test");
        Fluttertoast.showToast(
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          msg: 'User already exists!',
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        print("tah");
        Fluttertoast.showToast(
          backgroundColor: Colors.green,
          textColor: Colors.white,
          msg: 'Registration Successful',
          toastLength: Toast.LENGTH_SHORT,
        );
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => successRegister(),
          ),
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

      body: SingleChildScrollView(
        child:
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  Image.asset(
                    'asset/logo.png',
                    width: 280,
                    height: 350,
                  ),

                ],
              ),
            ),


            Padding( padding: const EdgeInsets.only( left: 15.0, bottom: 10.0),
                child:
                Column(
                  children: [
                    Row(
                        children: <Widget> [
                          Text("Let's Get Started",
                            style: TextStyle(decoration: TextDecoration.none,
                                fontSize: 25.0,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700),),
                        ]
                    ),
                    Row(
                        children: <Widget> [
                          Text("Create an account to get all features",
                            style: TextStyle(decoration: TextDecoration.none,
                                fontSize: 12.0,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w300),),
                        ]
                    ),
                  ],
                )

            ),

            Container(
                padding: EdgeInsets.all(20),
                child: Column(  //column untuk letak icon and textfield
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                        border: loginInputBorder(),
                        enabledBorder: loginInputBorder(),
                        focusedBorder: loginFocusedBorder(),
                      ) , //keyboardType: TextInputType.phone,
                    )
                  ],
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
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
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
                  register();

                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                  ),
                  backgroundColor: Color(hexColor('C73B3B')), // Set your preferred background color
                ),
                child: Text('Sign Up',
                  style:TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),


            // SizedBox(),
            // GestureDetector(
            //     onTap:()
            //     {
            //       setState(() {
            //         register();
            //       });
            //     },
            //     child:Container(
            //       alignment: Alignment.center,
            //       width: 300,
            //       height: 50,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(50),
            //         color: Color(hexColor('C73B3B')),
            //       ),
            //       child: Text('Sign Up', style:
            //       TextStyle(color: Colors.white,
            //         fontFamily: 'Inter',
            //         fontWeight: FontWeight.w700,
            //         fontSize: 18,
            //       ),),
            //     )
            // ),

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(),
                Text(
                  "already Sign Up? ",
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
                          (context) => LoginScreen(),)); //go to register screen
                    });
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Color(
                        hexColor('#024362'),
                      ),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),


            //   Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: TextField(
            //       controller: passwordController,
            //       decoration: const InputDecoration(
            //         labelText: 'password',
            //       ),
            //     ),
            //   ),
            //   ElevatedButton(
            //     onPressed: () {
            //       String username = usernameController.text;
            //       String password = passwordController.text;
            //
            //       if (username == 'test' && password == 'abc') {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => test(),
            //           ),
            //         );
            //       } else {
            //         showDialog(
            //           context: context,
            //           builder: (context) {
            //             return AlertDialog(
            //               title: const Text('Login Failed'),
            //               content: const Text('Invalid'),
            //               actions: [
            //                 TextButton(
            //                   child: const Text('oke'),
            //                   onPressed: () {
            //                     Navigator.pop(context);
            //                   },
            //                 ),
            //               ],
            //             );
            //           },
            //         );
            //       }
            //     },
            //     child: const Text('Login'),
            //   ),

          ],
        ),

      ),
    );



  }
}



class successRegister extends StatefulWidget {
  const successRegister({super.key});

  @override
  State<successRegister> createState() => _successRegisterState();
}

class _successRegisterState extends State<successRegister> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
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
      borderSide: BorderSide(color:Colors.red, width: 3)
  );
}

// int hexColor(String color)
// {
//   String newColor = '0xff' + color;
//   newColow =
// }

int hexColor(String color)
{
  String newColor = '0xff' + color;
  newColor= newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}