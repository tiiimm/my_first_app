import 'package:flutter/material.dart';

class PatientRecordListPage extends StatefulWidget {
  @override
  _PatientRecordListPageState createState() => _PatientRecordListPageState();
}

class _PatientRecordListPageState extends State<PatientRecordListPage> {
  List<Map<String, String>> patientRecords = [
    {'name': 'John Doe', 'id': '123', 'details': 'Details about John Doe'},
    {'name': 'Jane Smith', 'id': '124', 'details': 'Details about Jane Smith'},
    // Add more patient records here
  ];

  void _showPatientDetails(Map<String, String> patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Patient Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${patient['name']}'),
              Text('ID: ${patient['id']}'),
              Text('Details: ${patient['details']}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Record List'),
        backgroundColor: Color(0xFF6479ba),
      ),
      body: ListView.builder(
        itemCount: patientRecords.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(patientRecords[index]['name']!),
              subtitle: Text('ID: ${patientRecords[index]['id']}'),
              trailing: Icon(Icons.info, color: Color(0xFF6479ba)),
              onTap: () => _showPatientDetails(patientRecords[index]),
            ),
          );
        },
      ),
    );
  }
}
