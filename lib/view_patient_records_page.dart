import 'package:flutter/material.dart';

class PatientRecordListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final int? userId = args?['userId'];

    // Fetch data based on userId if needed
    // For now, we're just displaying the userId passed as an argument.

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 238, 240, 241),
      appBar: AppBar(
        title: Text('Patient Records'),
        backgroundColor: Color(0xFF6479ba),
      ),
      body: Center(
        child: Text('Displaying records for user ID: $userId'),
      ),
    );
  }
}
