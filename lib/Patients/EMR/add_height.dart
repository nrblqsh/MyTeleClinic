import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import '../../Controller/request_controller.dart';

void main() {
  runApp(MaterialApp(
    home: AddHeightScreen(),
  ));
}

class Height {
  final double height;
  final String date;

  Height(this.height, this.date);

  Height.fromJson(Map<String, dynamic> json)
      : height = json['height'],
        date = json['latestDate'];

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() => {'height': height, 'latestDate': date };

  Future<bool> save() async {
    RequestController req = RequestController(path: "/teleclinic/height.php");
    req.setBody(toJson());
    await req.post();
    if (req.status() == 200) {
      return true;
    }
    return false;
  }

  static Future<List<Height>> loadAll() async {
    List<Height> result =[];
    RequestController req = RequestController(path: "/teleclinic/height.php");
    await req.get();
    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(Height.fromJson(item));
      }
    }

    return result;
  }
}

class AddHeightScreen extends StatefulWidget {
  @override
  _AddHeightScreenState createState() => _AddHeightScreenState();
}

class _AddHeightScreenState extends State<AddHeightScreen> {
  final List<Height> heights = [];
  TextEditingController heightController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  Future<void> _addHeight() async {
    String height = heightController.text.trim();

    if (height.isNotEmpty) {
      Height wgt =
      Height(double.parse(height), dateController.text);
      if (await wgt.save()) {
        setState(() {
          heights.add(wgt);
          heightController.clear();
        });
      } else {
        _showMessage("Failed to save Expenses data");
      }
    }
  }

  void _showMessage(String msg) {
    if (mounted) {
      //make sure this context is still mounted/exist
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }
  }

  void _deleteHeight(int index) {
    setState(() {
      heights.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 98,
          backgroundColor: Colors.white,
          title: Center(
            child: Image.asset(
              "asset/MYTeleClinic.png",
              width: 594,
              height: 258,
            ),
          ),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 25, right: 400),
            child: Text(
              "Add Height Data",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                textStyle: const TextStyle(fontSize: 38, color: Colors.black),
              ),
            ),
          ),
          ListTile(
            title: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRz1kwv1DTXkYiC_Z0TqiogSf3HHbqlpTJmuA&usqp=CAU',
                width: 90,
                height: 90,
              ),
            ),
            subtitle: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(
                  'Height',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle:
                    const TextStyle(fontSize: 22, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ),
          Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 55, right: 650.0),
                child: Text(
                  'Date',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 22, color: Colors.black54),
                  ),
                ),
              )),
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              // column untuk letak icon and textfield
                children: [
                  SizedBox(
                    width: 700,
                    height: 70,
                    child: Container(
                      // alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
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
                        ], //                 <--- border radius here
                      ),
                      child: TextField(
                        keyboardType: TextInputType.datetime,
                        readOnly: true,
                        onTap: _selectDate,
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Select Date',
                          prefixIcon: Icon(Icons.date_range),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
          Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 630.0),
                child: Text(
                  'Height',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    textStyle: const TextStyle(fontSize: 22, color: Colors.black54),
                  ),
                ),
              )),
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              // column untuk letak icon and textfield
                children: [
                  SizedBox(
                    width: 700,
                    height: 70,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      // alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
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
                        ], //                 <--- border radius here
                      ),

                      child: TextField(
                        controller: heightController,
                        decoration: InputDecoration(
                          labelText: 'Enter your height',
                          prefixIcon: Icon(Icons.height),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
          Container(
              child: ElevatedButton(
                onPressed: _addHeight,
                child: Text('Save'),
              )),
        ]));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      RequestController req = RequestController(
          path: "/api/timezone/Asia/Kuala_Lumpur",
          server: "http://worldtimeapi.org");
      req.get().then((value) {
        dynamic res = req.result();
        dateController.text =
            res["date"].toString().substring(0, 19).replaceAll('T', '');
      });
      heights.addAll(await Height.loadAll());

      setState(() {
        _addHeight();
      });
    });
  }

  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        // Format the picked date to display only the date part
        dateController.text =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
      });
    }
  }
}
