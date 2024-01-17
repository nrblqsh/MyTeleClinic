import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_teleclinic/Patients/Profile/patient_home_page.dart';
import 'package:my_teleclinic/Specialists/ZegoCloud/constants.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Main/main.dart';
import '../../Model/medication.dart';
import '../Profile/specialist_home.dart';

class MyCall extends StatefulWidget {
  const MyCall(
      {Key? key,
      required this.callID,
      required this.id,
      required this.name,
      required this.roleId,
      required this.consultationID})
      : super(key: key);

  final String callID;
  final String id;
  final String name;
  final int roleId;
  final int consultationID;

  @override
  State<MyCall> createState() => _MyCallState(
      callID: callID,
      id: id,
      name: name,
      roleId: roleId,
      consultationID: consultationID);
}

class _MyCallState extends State<MyCall> {
  late String callID;
  late String id;
  late String name;
  bool isContainerVisible = true;
  late int consultationID;


  late TextEditingController symptomEditingContoller;
  late TextEditingController treatmentEditingController;
  late TextEditingController medicationEditingController;
  late TextEditingController rmEditingController;
  late TextEditingController centsEditingController;
  late TextEditingController medInstructionEditingController;

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
  int _consultID = 0;
  int? storedConsultationID;


  List<Map<String, dynamic>> allMedicines = [];

  // Create a list to hold selected medications
  List<Map<String, dynamic>> selectedMedications = [];
  List<String> suggestions = [];
  List<TextEditingController> medInstructionControllers = [];

  late Timer _callTimer;
  _MyCallState({
    required this.callID,
    required this.id,
    required this.name,
    required int roleId,
    required int consultationID,


  }) {

    symptomEditingContoller = TextEditingController();
    treatmentEditingController = TextEditingController();
    medicationEditingController = TextEditingController();
    rmEditingController = TextEditingController();
    centsEditingController = TextEditingController();
    medInstructionEditingController = TextEditingController();

    // Initialize the call timer
    const Duration callTimeout = const Duration(minutes: 15); // Set your desired timeout duration
    _callTimer = Timer(callTimeout, () {
      // Call timeout occurred, perform actions here
      onCallTimeout();
    });
  }




// void startCallTimer() {
//   _callTimer = Timer(const Duration(minutes: 10), () {
//     // Call timeout occurred, perform actions here
//     onCallTimeout();
//   });
// }

  void onCallTimeout() {
    // Perform actions when the call times out
    print('Call timeout occurred');
   Navigator.pop(context);

    // Add logic to hang up the call or handle the timeout scenario
  }
  @override
  void initState() {
    super.initState();
    _loadDetails();
    _loadAllMedicine();
   // startCallTimer();
  }

  Future<void> _loadDetails() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      patientID = pref.getInt("patientID") ?? 0;
      specialistID = pref.getInt("specialistID") ?? 0;
      specialistName = pref.getString("specialistName") ?? '';
      consultationID = widget.consultationID;
      print("consultation dalam kelas sebelah$consultationID");
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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('consultationID', _consultationID);

        storedConsultationID = prefs.getInt('consultationID');
        print('Consultation ID saved: $storedConsultationID');
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
        child: SingleChildScrollView(
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


                    config: ZegoUIKitPrebuiltCallConfig
                        .oneOnOneVideoCall(),
                    events:
                    ZegoUIKitPrebuiltCallEvents(

                      onHangUpConfirmation: (BuildContext context) async {
                        bool shouldHangUp = false;

                        if (widget.roleId == 1) {
                          await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                title: const Text(
                                  "Consultation Information",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                                content: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  // Set your desired height here

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      customText1("Symptom"),
                                      Text('${symptomEditingContoller.text}'),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      customText1("Treatement"),
                                      Text(
                                          '${treatmentEditingController.text}'),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      customText1("Medication and Instruction"),
                                      for (int index = 0;
                                          index < selectedMedications.length;
                                          index++)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${index + 1} ${selectedMedications[index]['MedGeneral'] ?? ''}(${selectedMedications[index]['Dosage'] ?? ''}) - ${selectedMedications[index]['MedForm'] ?? ''} ',
                                            ),
                                            Text(
                                              'Instruction: ${medInstructionControllers[index].text}',
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      customText1("Consultation Fees"),
                                      Text('RM ${rmEditingController.text}.'
                                          '${centsEditingController.text}'),
                                      SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                      child: const Text("Cancel",
                                          style:
                                              TextStyle(color: Colors.white70)),
                                      onPressed: () {
                                        shouldHangUp = false;

                                        Navigator.of(context).pop(false);
                                      }),
                                  ElevatedButton(
                                      child: const Text("Exit"),
                                      onPressed: () async {
                                        String combinedFees =
                                            '${rmEditingController.text}.'
                                            '${centsEditingController.text}';
                                        print(combinedFees);
                                        await insertConsultationInformation(
                                            consultationID,
                                            symptomEditingContoller.text,
                                            treatmentEditingController.text,
                                            combinedFees);

                                        // print('MedID: ${selectedMedications[index]['MedID']}');

                                        print(
                                            'consultationID: $consultationID');
                                        await insertMedicationDetails(
                                            consultationID,
                                            selectedMedications);

                                        final newStatus = 'Done';

                                        final response =
                                            await http.get(Uri.parse(
                                          'http://${MyApp.ipAddress}/teleclinic/'
                                          'updateConsultationStatus.php?consultationID='
                                          '$consultationID&updateConsultationStatus=$newStatus',
                                        ));

                                        if (response.statusCode == 200) {
                                          print('Status updated successfully');

                                          // Update the UI with the new status

                                          // Close the existing dialog and show the updated one
                                          // Navigator.of(context).pop(true);
                                          //  Navigator.push(
                                          //    context,
                                          //    MaterialPageRoute(
                                          //      builder: (context) => MenuScreen
                                          //        (specialistName: specialistName,
                                          //        logStatus: 'Done',
                                          //        specialistID: specialistID,
                                          //        todayConsultations: [],
                                          //        fetchTodayConsultations: () {  },
                                          //        navigateToPage: (int ) {  },
                                          //
                                          //      ), // Replace YourSpecificPage with the actual widget/page you want to navigate to
                                          //    ),
                                          //  );
                                          shouldHangUp = true;

                                          Navigator.of(context).pop(true);


                                         if(widget.roleId==0){
                                           Navigator.of(context).pop(true);
                                           Navigator.of(context).pop();

                                           Navigator.push(
                                               context,
                                               MaterialPageRoute(
                                                 builder: (context) => HomePage(
                                                   phone: "phone",
                                                   patientName: "patientName",
                                                   patientID: patientID, // Replace with actual patientID
                                                 ),
                                               )
                                           );
                                         }


                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             SpecialistHomeScreen()));

                                          // else if(widget.roleId==0){
                                          //   Navigator.push(context, MaterialPageRoute(builder
                                          //       : (context)=>HomePage(phone:
                                          //   "phone", patientName: "patientName",
                                          //       patientID: patientID)));
                                          // }
                                        }


                                        // else if(shouldHangUp || widget.roleId==0){
                                        //   print("statusX");
                                        //   Navigator.push(context, MaterialPageRoute(builder
                                        //             : (context)=>HomePage(phone:
                                        //         "phone", patientName: "patientName",
                                        //             patientID: patientID)));
                                        //    //Navigator.of(context).pop(true);
                                        //
                                        //
                                        // }



                                      }
                                      ),

                                ],

                              );
                            },
                          );
                        }


                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => HomePage(
                          //         phone: "phone",
                          //         patientName: "patientName",
                          //         patientID: patientID, // Replace with actual patientID
                          //       ),
                          //     )
                          // );


                        // }   if (shouldHangUp || widget.roleId == 0) {
                        //   print("Hang up or navigate based on shouldHangUp or roleId");
                        //
                        //   // If roleId is 0, directly navigate to the appropriate screen
                        //   if (widget.roleId == 0) {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => HomePage(
                        //           phone: "phone",
                        //           patientName: "patientName",
                        //           patientID: patientID, // Replace with actual patientID
                        //         ),
                        //       ),
                        //     );
                        //   }
                        // }

                      },


                    ),
                  ),
                ),

                if (widget.roleId == 1)
                  Positioned(
                    bottom: 50.0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isContainerVisible = !isContainerVisible;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: isContainerVisible ? 800.0 : 0,
                        height: isContainerVisible ? 700.0 : 0,
                        color: Colors.white.withOpacity(70),
                        child: isContainerVisible
                            ? SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 250, top: 18.0),
                                      child: Text("Consultation Information",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ),

                                    SingleChildScrollView(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.blue.withOpacity(0.5),
                                              offset: Offset(0.0, 2.0),
                                              blurRadius: 4.0,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            customText("Symptom"),
                                            TextFormField(
                                              controller:
                                                  symptomEditingContoller,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: null,
                                              decoration: InputDecoration(
                                                hintText: 'Symptom',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                              textInputAction:
                                                  TextInputAction.newline,
                                              onFieldSubmitted: (value) {
                                                print('Done button pressed!');
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              toolbarOptions: ToolbarOptions(
                                                copy: true,
                                                cut: true,
                                                paste: true,
                                                selectAll: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 10.0),

                                    // ... existing code ...

                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                          customText("Treatment"),
                                          TextFormField(
                                            controller:
                                                treatmentEditingController,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                              hintText: 'Treatment',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            textInputAction:
                                                TextInputAction.newline,
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
                                        ],
                                      ),
                                    ),

                                    // ...
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
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
                                          customText("Medication"),
                                          TextField(
                                            controller:
                                                medicationEditingController,
                                            decoration: InputDecoration(
                                              hintText: 'Medication',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            onChanged: (query) async {
                                              print(
                                                  "Medication search term: $query");
                                              print(
                                                  "consu$storedConsultationID");

                                              List<Map<String, dynamic>>
                                                  suggestions = await Medication
                                                      .getMedicationSuggestions(
                                                          query);
                                              setState(() {
                                                medicationSuggestions =
                                                    suggestions;
                                                print("keluar");
                                              });
                                            },
                                          ),
                                          SizedBox(height: 10.0),
                                          if (medicationSuggestions.isNotEmpty)
                                            Column(
                                              children: [
                                                // Existing Container for medication suggestions
                                                Container(
                                                  height: 200.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.blue
                                                            .withOpacity(0.5),
                                                        offset:
                                                            Offset(0.0, 2.0),
                                                        blurRadius: 4.0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: ListView.builder(
                                                    itemCount:
                                                        selectedMedications
                                                                .length +
                                                            medicationSuggestions
                                                                .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      if (index <
                                                          selectedMedications
                                                              .length) {
                                                        // Display selected medications
                                                        return ListTile(
                                                          title: Text(
                                                            '${selectedMedications[index]['MedGeneral'] ?? ''}(${selectedMedications[index]['Dosage'] ?? ''}) ${selectedMedications[index]['MedForm'] ?? ''} - ${selectedMedications[index]['Dosage'] ?? ''}',
                                                          ),
                                                          onTap: () {
                                                            print(
                                                                "print sisni");
                                                            setState(() {
                                                              selectedMedications
                                                                  .removeAt(
                                                                      index);
                                                            }); // Handle tap on selected medication if needed
                                                          },
                                                        );
                                                      } else if (index <
                                                          selectedMedications
                                                                  .length +
                                                              medicationSuggestions
                                                                  .length) {
                                                        // Display medication suggestions
                                                        final suggestionIndex =
                                                            index -
                                                                selectedMedications
                                                                    .length;
                                                        return ListTile(
                                                          title: Text(
                                                            '${medicationSuggestions[suggestionIndex]['MedGeneral'] ?? ''}(${medicationSuggestions[suggestionIndex]['Dosage'] ?? ''}) ${medicationSuggestions[suggestionIndex]['MedForm'] ?? ''}',
                                                          ),
                                                          onTap: () {
                                                            setState(() {
                                                              selectedMedications
                                                                  .add({
                                                                'MedID': medicationSuggestions[
                                                                        suggestionIndex]
                                                                    ['MedID'],
                                                                'MedGeneral':
                                                                    medicationSuggestions[
                                                                            suggestionIndex]
                                                                        [
                                                                        'MedGeneral'],
                                                                'MedForm': medicationSuggestions[
                                                                        suggestionIndex]
                                                                    ['MedForm'],
                                                                'Dosage': medicationSuggestions[
                                                                        suggestionIndex]
                                                                    ['Dosage'],
                                                              });
                                                              medicationSuggestions
                                                                  .clear();
                                                              medicationSuggestions.removeWhere((suggestion) =>
                                                                  suggestion[
                                                                      'MedID'] ==
                                                                  medicationSuggestions[
                                                                          suggestionIndex]
                                                                      [
                                                                      'MedID']);
                                                              medicationEditingController
                                                                  .clear();
                                                            });
                                                          },
                                                        );
                                                      } else {
                                                        // Handle an out-of-range index gracefully
                                                        return SizedBox
                                                            .shrink();
                                                      }
                                                    },
                                                  ),
                                                ),
                                                // Display selected medications outside the containerif (selectedMedications.isNotEmpty)

                                                // Existing Container for medication suggestions
                                              ],
                                            ),
                                          // Container(
                                          //   decoration: BoxDecoration(
                                          //     borderRadius: BorderRadius.circular(8.0),
                                          //     color: Colors.white,
                                          //     boxShadow: [
                                          //       BoxShadow(
                                          //         color: Colors.blue.withOpacity(0.5),
                                          //         offset: Offset(0.0, 2.0),
                                          //         blurRadius: 4.0,
                                          //       ),
                                          //     ],
                                          //   ),
                                          //   child: Column(
                                          //     crossAxisAlignment: CrossAxisAlignment.start,
                                          //     children: [
                                          //       Text(
                                          //         'Selected Medications:',
                                          //         style: TextStyle(fontWeight: FontWeight.bold),
                                          //       ),
                                          //       // Display selected medications with corresponding TextFields
                                          //       ListView.builder(
                                          //         shrinkWrap: true,
                                          //         itemCount: selectedMedications.length,
                                          //         itemBuilder: (context, index) {
                                          //           // Ensure that you have enough controllers in the list
                                          //           while (medInstructionControllers.length <= index) {
                                          //             medInstructionControllers.add(TextEditingController());
                                          //           }
                                          //           // setState(() {
                                          //           //   FocusScope.of(context).unfocus();
                                          //           //
                                          //           // });
                                          //
                                          //           print("Index: $index");
                                          //           print("MedID: ${selectedMedications[index]['MedID']}");
                                          //           print("ConsultationID: $consultationID");
                                          //
                                          //           return Column(
                                          //             crossAxisAlignment: CrossAxisAlignment.start,
                                          //             children: [
                                          //               Text(
                                          //                 '${selectedMedications[index]['MedGeneral'] ?? ''} - ${selectedMedications[index]['MedForm'] ?? ''} - ${selectedMedications[index]['Dosage'] ?? ''}',
                                          //               ),
                                          //               TextField(
                                          //                 controller: medInstructionControllers[index],
                                          //                 decoration: InputDecoration(
                                          //                   hintText: 'Enter additional information for ${selectedMedications[index]['MedGeneral']}',
                                          //                 ),
                                          //                 // Handle the onChanged or onSubmitted event based on your needs
                                          //               ),
                                          //
                                          //             ],
                                          //           );
                                          //         },
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                          SizedBox(height: 10.0),
                                          if (selectedMedications.isNotEmpty)
                                            SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  SingleChildScrollView(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.blue
                                                                .withOpacity(
                                                                    0.5),
                                                            offset: Offset(
                                                                0.0, 2.0),
                                                            blurRadius: 4.0,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10.0),
                                                            child: Text(
                                                              'Selected Medications:',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 17),
                                                            ),
                                                          ),
                                                          // Display selected medications with corresponding TextFields
                                                          ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount:
                                                                selectedMedications
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              // Ensure that you have enough controllers in the list
                                                              while (medInstructionControllers
                                                                      .length <=
                                                                  index) {
                                                                medInstructionControllers
                                                                    .add(
                                                                        TextEditingController());
                                                              }

                                                              return Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10.0),
                                                                    child:
                                                                        ListTile(
                                                                      title:
                                                                          Text(
                                                                        '${selectedMedications[index]['MedGeneral'] ?? ''}(${selectedMedications[index]['Dosage'] ?? ''}) - ${selectedMedications[index]['MedForm'] ?? ''} ',
                                                                      ),
                                                                      leading:
                                                                          IconButton(
                                                                        icon: Icon(
                                                                            Icons.delete),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            // Remove the selected medication and its corresponding instruction
                                                                            selectedMedications.removeAt(index);
                                                                            medInstructionControllers.removeAt(index);
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Container(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 10.0),
                                                                            child:
                                                                                TextField(
                                                                              controller: medInstructionControllers[index],
                                                                              decoration: InputDecoration(
                                                                                hintText: 'Enter additional information for ${selectedMedications[index]['MedGeneral']}(${selectedMedications[index]['Dosage'] ?? ''})',
                                                                              ),
                                                                              // Handle the onChanged or onSubmitted event based on your needs
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

// Add another container or widgets here if needed
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      customText(
                                                          "Consultation Fees"),
                                                      TextField(
                                                        controller:
                                                            rmEditingController,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: 'Enter RM',
                                                        ),
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        // Handle onChanged or onSubmitted event based on your needs
                                                        onChanged: (value) {
                                                          // Handle the entered dollar amount
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: Text(
                                                    ':',
                                                    style: TextStyle(
                                                        fontSize: 20.0),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        centsEditingController,
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter cents',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
// ...
                                  ],
                                ),
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
                      isContainerVisible ? Icons.aspect_ratio : Icons.aspect_ratio_sharp,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customText1(
    String text,
  ) {
    return Text(
      text,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget customText(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> insertConsultationInformation(int consultationID, String symptom,
      String treatment, String combinedFees) async {
    final String url =
        'http://${MyApp.ipAddress}/teleclinic/insertConsultationInformation.php?consultationID=$consultationID';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'consultationTreatment': treatment,
          'consultationSymptom': symptom,
          'feesConsultation': combinedFees
        },
      );

      if (response.statusCode == 200) {
        // Data inserted successfully
        print('Data inserted successfully');
      } else {
        throw Exception('Failed to insert consultation data');
      }
    } catch (e) {
      throw Exception('Error during data insertion: $e');
    }
  }

  Future<void> insertMedicationDetails(int consultationID,
      List<Map<String, dynamic>> selectedMedications) async {
    final String url =
        'http://${MyApp.ipAddress}/teleclinic/insertMedicationDetails.php';

    print("select${selectedMedications.length}");
    for (int index = 0; index < selectedMedications.length; index++) {
      final Map<String, dynamic> data = {
        'MedID': selectedMedications[index]['MedID'],
        'MedInstruction': medInstructionControllers[index].text,
        'consultationID': consultationID,
      };

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Medication inserted successfully!');
      } else {
        print(
            'Failed to insert medication. Status code: ${response.statusCode}');
      }
    }
  }

  void onUserLogin() {
    /// 4/5. initialized ZegoUIKitPrebuiltCallInvitationService when account is logged in or re-logged in
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: MyConstant.appId,
      /*input your AppID*/
      appSign: MyConstant.appSign /*input your AppSign*/,
      userID: widget.id,
      userName: widget.name,
      plugins: [
        ZegoUIKitSignalingPlugin(),
      ],
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoAndroidNotificationConfig(
          channelID: "ZegoUIKit",
          channelName: "Call Notifications",
          sound: "call",
          icon: "call",
        ),
        iOSNotificationConfig: ZegoIOSNotificationConfig(
          systemCallingIconName: 'CallKitIcon',
        ),
      ),
      requireConfig: (ZegoCallInvitationData data) {
        final config = (data.invitees.length > 1)
            ? ZegoCallType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
            : ZegoCallType.videoCall == data.type
                ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        // config.avatarBuilder = customAvatarBuilder;

        /// support minimizing, show minimizing button
        config.topMenuBarConfig.isVisible = true;
        config.topMenuBarConfig.buttons
            .insert(0, ZegoMenuBarButtonName.minimizingButton);

        return config;
      },
    );
  }
}

//
// class CallInvitationPage extends StatelessWidget {
//   const CallInvitationPage({super.key,
//   required this.child,
//   required this.username});
//
//
//   final Widget child;
//   final String username;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//     );
//   }
//   ZegoSendCallInvitationButton actionButton(bool isVideo) =>
//       ZegoSendCallInvitationButton(
//         isVideoCall: isVideo,
//         resourceID: "zegouikit_call", invitees: [
//           id:
//       ],
//
//       )
// }
