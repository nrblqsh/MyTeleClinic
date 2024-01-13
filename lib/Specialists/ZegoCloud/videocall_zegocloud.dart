import 'package:flutter/material.dart';
import 'package:my_teleclinic/Specialists/ZegoCloud/constants.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/medication.dart';

class MyCall extends StatefulWidget {
  const MyCall({
    Key? key,
    required this.callID,
    required this.id,
    required this.name,
    required this.roleId,
  }) : super(key: key);

  final String callID;
  final String id;
  final String name;
  final int roleId;

  @override
  State<MyCall> createState() => _MyCallState(
    callID: callID,
    id: id,
    name: name,
    roleId: roleId,
  );
}

class _MyCallState extends State<MyCall> {
  late String callID;
  late String id;
  late String name;
  bool isContainerVisible = true;

  late TextEditingController symptomEditingContoller;
  late TextEditingController treatmentEditingController;
  late TextEditingController medicationEditingController;
  List<Map<String, dynamic>> medicationSuggestions = [];

  late TextEditingController textEditingController;
  final FocusNode textFocus = FocusNode();

  // Specialist details
  late int patientID;
  late int specialistID;
  late String specialistName;

  int _medID = 0;
  String? _medGeneral;
  String? _medForm;
  String? _dosage;
  int _consultationID = 0;
  String? _medInstruction;
  int _medicationID = 0;
  DateTime _consultationDateTime = DateTime.now();
  double feesConsultation = 0;

  List<Map<String, dynamic>> allMedicines = [];


  // Create a list to hold selected medications
  List<Map<String, dynamic>> selectedMedications = [];
  List<String> suggestions = [];

  _MyCallState({
    required this.callID,
    required this.id,
    required this.name,
    required int roleId,
  }) {
    symptomEditingContoller = TextEditingController();
    treatmentEditingController = TextEditingController();
    medicationEditingController = TextEditingController();
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadAllMedicine();
  }

  Future<void> _loadDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      patientID = pref.getInt("patientID") ?? 0;
      specialistID = pref.getInt("specialistID") ?? 0;
      specialistName = pref.getString("specialistName") ?? '';
    });
  }

  Future<void> _loadAllMedicine() async {
    List<Medication> meds = await Medication.loadAll();

    if (meds.isNotEmpty) {
      for (Medication med in meds) {
        setState(() {
          _medID = med.medID!;
          _consultationID = med.consultationID!;
          _medicationID = med.medicationID!;
          _medGeneral = med.medGeneral;
          _medForm = med.medForm;
          _dosage = med.dosage;
          _medInstruction = med.medInstruction;
        });

        print("medid$_medID");
        print("consultid$_consultationID");
        print("medicationid$_medicationID");
        print("medgeneral$_medGeneral");
      }
    } else {
      print('No patient data available');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Colors.white,
        title: Center(
          child: Image.asset(
            "asset/MYTeleClinic.png",
            width: 594,
            height: 258,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: ZegoUIKitPrebuiltCall(
                  appID: MyConstant.appId,
                  appSign: MyConstant.appSign,
                  callID: callID,
                  userID: id,
                  userName: name,
                  config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
                  events: ZegoUIKitPrebuiltCallEvents(
                    onHangUpConfirmation: (BuildContext context) async {
                      if (widget.roleId == 1) {
                        return await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.blue[900]!.withOpacity(0.9),
                              title: const Text("This is your custom dialog", style: TextStyle(color: Colors.white70)),
                              content: Text(
                                "Symptom: ${symptomEditingContoller.text}",
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                ElevatedButton(
                                  child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                ElevatedButton(
                                  child: const Text("Exit"),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              ),

              if (widget.roleId == 1)
                Positioned(
                  bottom: 30.0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isContainerVisible = !isContainerVisible;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: isContainerVisible ? 800.0 : 0,
                      height: isContainerVisible ? 470.0 : 0,
                      color: Colors.white,
                      child: isContainerVisible
                          ? Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  offset: Offset(0.0, 2.0),
                                  blurRadius: 4.0,
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: symptomEditingContoller,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Symptom',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              textInputAction: TextInputAction.newline,
                              onFieldSubmitted: (value) {
                                print('Done button pressed!');
                                FocusScope.of(context).unfocus();
                              },
                              toolbarOptions: ToolbarOptions(
                                copy: true,
                                cut: true,
                                paste: true,
                                selectAll: true,
                              ),
                            ),
                          ),

                          SizedBox(height: 15.0),

                          // ... existing code ...

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  offset: Offset(0.0, 2.0),
                                  blurRadius: 4.0,
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: symptomEditingContoller,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Symptom',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              textInputAction: TextInputAction.newline,
                              onFieldSubmitted: (value) {
                                print('Done button pressed!');
                                FocusScope.of(context).unfocus();
                              },
                              toolbarOptions: ToolbarOptions(
                                copy: true,
                                cut: true,
                                paste: true,
                                selectAll: true,
                              ),
                            ),
                          ),

                          // ...

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  offset: Offset(0.0, 2.0),
                                  blurRadius: 4.0,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: medicationEditingController,
                                  decoration: InputDecoration(
                                    hintText: 'Medication',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (query) async {
                                    print("Medication search term: $query");

                                    List<Map<String, dynamic>> suggestions =
                                    await Medication.getMedicationSuggestions(query);
                                    setState(() {
                                      medicationSuggestions = suggestions;
                                      print("keluar");
                                    });
                                  },
                                ),
                                SizedBox(height: 8.0),
                                if (medicationSuggestions.isNotEmpty)
                                  Column(
                                    children: [
                                      // Existing Container for medication suggestions
                                      Container(
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.5),
                                              offset: Offset(0.0, 2.0),
                                              blurRadius: 4.0,
                                            ),
                                          ],
                                        ),
                                        child: ListView.builder(
                                          itemCount: selectedMedications.length + medicationSuggestions.length,
                                          itemBuilder: (context, index) {
                                            if (index < selectedMedications.length) {
                                              return ListTile(
                                                title: Text(
                                                  '${selectedMedications[index]['MedGeneral'] ?? ''} - ${selectedMedications[index]['MedForm'] ?? ''} - ${selectedMedications[index]['Dosage'] ?? ''}',
                                                ),
                                                onTap: () {
                                                  // Handle tap on selected medication if needed
                                                },
                                              );
                                            } else {
                                              final suggestionIndex = index - selectedMedications.length;
                                              return ListTile(
                                                title: Text(
                                                  '${medicationSuggestions[suggestionIndex]['MedGeneral'] ?? ''} - ${medicationSuggestions[suggestionIndex]['MedForm'] ?? ''} - ${medicationSuggestions[suggestionIndex]['Dosage'] ?? ''}',
                                                ),
                                                onTap: () {

                                                  setState(() {

                                                    selectedMedications.add({
                                                      'MedGeneral': medicationSuggestions[suggestionIndex]['MedGeneral'],
                                                      'MedForm': medicationSuggestions[suggestionIndex]['MedForm'],
                                                      'Dosage': medicationSuggestions[suggestionIndex]['Dosage'],
                                                    });

                                                    medicationSuggestions.clear();
                                                    medicationEditingController.clear();
                                                  });
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      // Display selected medications outside the containerif (selectedMedications.isNotEmpty)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Selected Medications:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            // Display selected medications with corresponding TextFields
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: selectedMedications.length,
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${selectedMedications[index]['MedGeneral'] ?? ''} - ${selectedMedications[index]['MedForm'] ?? ''} - ${selectedMedications[index]['Dosage'] ?? ''}',
                                                    ),
                                                    TextField(
                                                      decoration: InputDecoration(
                                                        hintText: 'Enter additional information for ${selectedMedications[index]['MedGeneral']}',
                                                      ),
                                                      // Handle the onChanged or onSubmitted event based on your needs

                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
// Add another container or widgets here if needed
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Enter dollars',
                                          ),
                                          keyboardType: TextInputType.number,
                                          // Handle onChanged or onSubmitted event based on your needs
                                          onChanged: (value) {
                                            // Handle the entered dollar amount
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          ':',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Enter cents',
                                          ),
                                          keyboardType: TextInputType.number,
                                          // Handle onChanged or onSubmitted event based on your needs
                                          onChanged: (value) {
                                            // Handle the entered cent amount
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                    height: 50.0,
                                    color: Colors.red, // You can customize the color or other properties
                                   // Add your child widgets here
                                ),
                              ],
                            ),
                          ),
// ...

                        ],

                      )

                          : null, // Render child only when the container is visible
                    ),
                  ),
                ),

// Add this GestureDetector to toggle isContainerVisible using Icons.minimize and Icons.maximize
              Positioned(
                top: 16.0,
                right: 16.0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isContainerVisible = !isContainerVisible;
                    });
                  },
                  child: Icon(
                    isContainerVisible ? Icons.minimize : Icons.maximize,
                    color: Colors.blue,
                    size: 30.0,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      );




  }


}
