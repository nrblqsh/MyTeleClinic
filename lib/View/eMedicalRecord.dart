import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      title: Center(child: Text("MyTeleClinic",
        style: const TextStyle(fontSize: 32, color:Colors.blueAccent),)
      ),
    ),
      body: Container(
        padding: EdgeInsets.all(7),
          child: Column(
              children: [
                   Text("Vital Info",
                     style: const TextStyle(fontSize: 32, color:Colors.black),), //<------------
               Expanded(
                child:GridView.builder(
                         itemCount: _infos.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:3),
                          itemBuilder: (context,index){
                            return ListTile(
                                title: Image.network(_infos[index]["Image"]!,
                                  width: 100,height: 100,),
                                  subtitle: Column(
                                    children: [
                                      Text(_infos[index]["Info"]!,
                                        style: const TextStyle(fontSize: 24, color:Colors.black),),
                                    ],
                                  ),

                            );
                      }, ),
               ),
              ]),
    ),



    );





    }

}