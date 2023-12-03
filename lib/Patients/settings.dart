import 'package:flutter/material.dart';
import 'package:my_teleclinic/login.dart';

import 'editProfile.dart';
import 'editProfile1.dart';

void main(){
  runApp( MaterialApp(
    home: SettingsScreen(),
  ));
}

class SettingsScreen extends StatefulWidget {
  // late String patientName;
  //
  //
  // SettingsScreen({required this.patientName});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override

  Widget settings(String label){
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap:()
                  {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => EditProfile1(),));
                  },

                child:
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18, // Reduce the font size for the label
                      fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                ),

                IconButton(
                  icon: Icon(Icons.navigate_next_outlined)
                  ,
                  color: Colors.grey,
                  onPressed: () {
                    // Navigator.push(
                    //     context, MaterialPageRoute(builder: (context) => EditProfile(),));

                  },
                ),

              ],

            ),
            // Text(
            //   value,
            //   style: TextStyle(
            //     fontSize: 18, // Font size for the value
            //   ),
            // ),

           Divider(
              color: Colors.grey,
              thickness: 1,
            )// Add space between the fields
          ],
        ),
      ),
    );
  }

  // Widget profileImage(){
  //   return Center(
  //     child: Stack(children: <Widget>[
  //       CircleAvatar(
  //         radius: 80,
  //         backgroundImage: AssetImage("asset/logo.png"),
  //       ),
  //       Positioned(
  //           bottom:20,
  //           right:20,
  //           child: Icon(Icons.edit,
  //           color:Colors.grey,
  //               size: 28))
  //
  //     ],
  //     ),
  //   );
  //
  // }

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
            color: Colors.blue,),
            title: Center(
            child: Image.asset("asset/MYTeleClinic.png",
            width: 594,
            height: 258,
    ),
    ),
    ),
      body: SingleChildScrollView(
        child: Column(
            children: [
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage("asset/logo.png"),
                      ),
                      SizedBox(height: 5),
                      Text("test",
                        //widget.patientName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, top: 40.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'My account',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 30.0,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
        SizedBox(height: 16.0,),

          settings('Edit Profile'),
          settings('Change Password'),

          Padding(
            padding: const EdgeInsets.only( left: 15.0, top: 10.0),
            child: Row(
                children: <Widget> [
                  Text('General',
                    style: TextStyle(decoration: TextDecoration.none,
                        fontSize: 30.0,
                        fontFamily: 'Inter', fontWeight: FontWeight.w700),),
                ]
            ),
          ),
          SizedBox(height: 16.0,),

          settings('Help Centre'),
          settings('About Us'),
          settings('Terms and Condition'),

      SizedBox(
        width:260,
        height: 65,
        child: Padding(
          padding: const EdgeInsets.only(top:17.0),
          child: ElevatedButton(
            onPressed: () {

            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
              ),
              backgroundColor: Color(hexColor('C73B3B')), // Set your preferred background color
            ),
            child: Text('Log Out',
              style:TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),


    ]

    ),
    ),
    );


  }
}


int hexColor(String color)
{
  String newColor = '0xff' + color;
  newColor= newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

