import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MaterialApp(
    home: weightHistoryScreen(),
  ));
}

class weightHistoryScreen extends StatefulWidget {
  const weightHistoryScreen ({super.key});

  @override
  _weightHistoryScreenState createState() => _weightHistoryScreenState();
}

class _weightHistoryScreenState extends State<weightHistoryScreen> {
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
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Text("Weight History",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        textStyle: const TextStyle(
                            fontSize: 42, color: Colors.black),),),
                  ),
             SizedBox(
               height: 800.0,
               child: Container(
                 child: Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: DataTable(
                          columnSpacing: 194,
                          columns: [
                            DataColumn(
                              label: Text("Weight(kg)",
                                  style: const TextStyle(fontSize: 28, color:Colors.black),),
                            ),
                            DataColumn(
                              label: Text("Date",
                                style: const TextStyle(fontSize: 28, color:Colors.black),),
                            ),
                            DataColumn(
                              label: Text("Option",
                                style: const TextStyle(fontSize: 28, color:Colors.black),),
                            ),

                          ],
                          rows: [
                            DataRow(cells: [
                              DataCell(Text('67.0 ')),
                              DataCell(Text('11/10/2023')),
                              DataCell(Text("Delete",
                                style: const TextStyle(color:Colors.redAccent),),),
                            ])
                          ]),
                    ),
               ),
             ),

              Container(
                child: ElevatedButton(
                onPressed: () {
            save();
          },
          child: Icon(Icons.add_circle_rounded, size: 80,),
          style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
            fixedSize: const Size(200, 100),
          ),
          )

        )] )


    ),
    );
  }

  save() {}
}