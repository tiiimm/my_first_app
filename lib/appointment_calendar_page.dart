import 'package:flutter/material.dart';

class AppointmentCalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Calendar'),
        backgroundColor: Color(0xFF6A1B9A),
      ),
      body: Center(
        child: Text(
          'Appointment Calendar Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
