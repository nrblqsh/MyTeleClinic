import 'package:flutter/material.dart';

import '../Model/consultation.dart';

class PatientSearch extends SearchDelegate<String> {
  late Map<int, String> patientNames = {};
  final List<Consultation> patients;

  PatientSearch(this.patients);

  void initState() {

   print(patientNames);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for the search bar (e.g., clear button)
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon on the left of the search bar (e.g., back button)
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Build the search results based on the query
    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, index) {
        late Consultation patient = patients[index];
        return ListTile(
          title: Text(patient.patientName.toString()),
          // Add more patient details as needed
          onTap: () {
            close(context, patient.patientName.toString());
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggestions shown when the user types in the search bar
    final List<Consultation> suggestionList = query.isEmpty
        ? patients
        : patients.where((patient) {
      return patient.patientName.toString().toUpperCase().contains(query.toUpperCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final Consultation suggestion = suggestionList[index];
        print(suggestionList);
        return ListTile(
          title: Text(suggestion.patientName.toString()),
          // Add more patient details as needed
          onTap: () {
            query = suggestion.patientName.toString();
            close(context, suggestion.patientName.toString());
          },
        );
      },
    );
  }
}
