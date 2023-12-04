import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MaterialApp(
    home: eMedicalRecordScreen(),
  ));
}

class eMedicalRecordScreen extends StatefulWidget {
  const eMedicalRecordScreen({super.key});

  @override
  _eMedicalRecordScreenState createState() => _eMedicalRecordScreenState();
}

class _eMedicalRecordScreenState extends State<eMedicalRecordScreen> {
  var _infos = [
    {
      "Info": "Weight",
      "Image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz1kwv1DTXkYiC_Z0TqiogSf3HHbqlpTJmuA&usqp=CAU"

    },
    {
      "Info": "Height",
      "Image": "https://cdn-icons-png.flaticon.com/512/3209/3209114.png"
    },
    {
      "Info": "Waist Circumference",
      "Image": "https://us.123rf.com/450wm/vectorwin/vectorwin2003/vectorwin200300678/141472597-waist-circumference-icon-vector-thin-line-sign-isolated-contour-symbol-illustration.jpg"
    },
    {
      "Info": "Blood Glucose",
      "Image": "https://st3.depositphotos.com/32990740/36636/v/450/depositphotos_366360024-stock-illustration-blood-drop-with-medical-cross.jpg"
    },
    {
      "Info": "Blood Pressure",
      "Image": "https://www.shutterstock.com/image-vector/blood-pressure-concept-meter-heart-600nw-659070700.jpg"
    },
    {
      "Info": "Heart Rate",
      "Image": "https://cdn-icons-png.flaticon.com/512/4583/4583463.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      toolbarHeight: 98,
      backgroundColor: Colors.white,
      title: Center(child: Image.asset(
        "asset/MYTeleClinic.png",
        width: 594,
        height: 258,
      ),
      ),
    ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
            children: [
              Padding(
               padding: const EdgeInsets.only(right: 500,top:25),
                child: Text("Vital Info",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight. bold,
                    textStyle: const TextStyle(fontSize: 38, color:Colors.black),),),
              ), //<------------
              // Expanded(
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 778,
                    height: 400.0,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      // alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                          borderRadius: BorderRadius.all(
                            Radius.circular(24.0) ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            offset: const Offset(
                              5.0,
                              5.0,
                            ),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],//                 <--- border radius here
                        ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: GridView.builder(
                          itemCount: _infos.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:3,
                              mainAxisSpacing: 1.0,
                              crossAxisSpacing: 50.0,
                          ),
                          itemBuilder: (context,index){
                            return ListTile(
                                title: Row(
                                  children: [
                                    Image.network(_infos[index]["Image"]!,
                                            width: 90,height: 90,),
                                  ],
                                ),

                                subtitle:
                                 Row(
                                   children: [
                                     Column(
                                       children: [
                                          Text(_infos[index]["Info"]!,
                                                    style: const TextStyle(fontSize: 16, color:Colors.black),),
                                       ],
                                     ),
                                   ],
                                 ),


                            );
                          }, ),
                      ),
                    ),

                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 300,top:14),
                child: Text("Consultation History",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight. bold,
                    textStyle: const TextStyle(fontSize: 38, color:Colors.black),),),
              ),
          SizedBox(
            width: 874,
            height: 404.0,
            child: Container(
                margin: EdgeInsets.all(8),
                // alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.all(
                      Radius.circular(24.0) ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey,
                      offset: const Offset(
                        5.0,
                        5.0,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ), //BoxShadow
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],//                 <--- border radius here
                ),
            ),
          ),
            ]
        ),

      ), //<---
    );





  }

}