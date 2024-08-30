import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_connection.dart';

class QueueStatusPage extends StatefulWidget {
  const QueueStatusPage({super.key});

  @override
  QueueStatusPageState createState() => QueueStatusPageState();
}

class QueueStatusPageState extends State<QueueStatusPage> {
  Map? serving;
  late SharedPreferences sharedPreferences;
  late int userId;
  String? userRole;
  TextEditingController dateController = TextEditingController();
  DateTime? selectedDate = DateTime.now();
  String? selectedSchedule = int.parse(DateFormat('HH').format(DateTime.now()))<12?'AM':'PM';
  List nextAppointments = [];

  @override
  void initState() {
    super.initState();
    configure();
  }

  configure() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPreferences.getInt('userId')!;
      userRole = sharedPreferences.getString('role')!;
      dateController.text = "${selectedDate!.toLocal()}".split(' ')[0];
    });
    loadData();
  }

  loadData() {
    setState(() {
      serving = null;
      nextAppointments.clear();
    });
    final dbHelper = DatabaseHelper();
    dbHelper.connect();
    final conn = dbHelper.connection;
    dbHelper.loadingDialog(context);

    conn!.query('SELECT appointments.*, pets.pet_name FROM appointments '
        'JOIN pets ON appointments.pet_id = pets.id '
        'WHERE appointments.date = ? AND appointments.schedule = ? AND (status = "SERVING" OR status = "PENDING") '
        'ORDER BY appointments.appointment_number ASC;', [DateFormat('yyyy-MM-dd').format(selectedDate!), selectedSchedule]).then((response) async {
      List tempAppointments = [];
      for (var appointment in response) {
        if (response.first == appointment && appointment['status'] == 'SERVING') {
          setState(() {
            serving = {'id': appointment['id'], 'text': '${appointment['appointment_number']} - ${appointment['pet_name']}'};
          });
        }
        else {
          tempAppointments.add({'id': appointment['id'], 'text': '${appointment['appointment_number']} - ${appointment['pet_name']}'});
        }
      }

      setState(() {
        nextAppointments = tempAppointments;
      });
      Navigator.pop(context);
    });
  }

  callNext() {
    final dbHelper = DatabaseHelper();
    dbHelper.connect();
    final conn = dbHelper.connection;
    dbHelper.loadingDialog(context);

    if (serving != null) {
      conn!.query(
      'UPDATE appointments SET status = "COMPLETED" WHERE id = ?',
      [serving!['id']],
    ).then((response) async {
    }).catchError((error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $error')),
      );
    });
    }

    if (nextAppointments.isNotEmpty) {
      conn!.query(
        'UPDATE appointments SET status = "SERVING" WHERE id = ?',
        [nextAppointments[0]['id']],
      ).then((response) async {
        Navigator.pop(context);

        loadData();
      }).catchError((error) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $error')),
        );
      });
    }
    else {
      Navigator.pop(context);

      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return serving!=null || nextAppointments.isNotEmpty?Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'NOW SERVING:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        Text(
          serving != null? serving!['text']:'',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 60
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'Next:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        for (var appt in nextAppointments)
        Text(
          appt['text'],
          style: const TextStyle(
            fontSize: 16
          ),
        ),
        const SizedBox(height: 40),
        if (userRole == 'Admin')
        Center(
          child: ElevatedButton(
            onPressed: () {
              callNext();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6479ba),
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              nextAppointments.isNotEmpty?'Call Next':'Finish Serving',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ):
    const Center(
      child: Text(
        'No servicing'
      )
    );
  }
}
