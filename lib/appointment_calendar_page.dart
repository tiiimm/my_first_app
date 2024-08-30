import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_first_app/book_appointment_page.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'db_connection.dart';

class AppointmentCalendarPage extends StatefulWidget {
  const AppointmentCalendarPage({super.key});

  @override
  State<AppointmentCalendarPage> createState() => _AppointmentCalendarPageState();
}

class _AppointmentCalendarPageState extends State<AppointmentCalendarPage> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  late SharedPreferences sharedPreferences;
  late int userId;
  List scheduledAppointments = [];

  @override
  void initState() {
    super.initState();
    configure();
  }

  configure() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPreferences.getInt('userId')!;
    });
    loadData();
  }

  loadData() {
    final dbHelper = DatabaseHelper();
    late final MySqlConnection? conn;
    dbHelper.connect().then((value){
      conn = dbHelper.connection;
      dbHelper.loadingDialog(context);

      conn!.query('SELECT appointments.*, pets.pet_name FROM appointments '
        'JOIN pets ON appointments.pet_id = pets.id '
        'JOIN users ON pets.owner_id = users.id '
        'WHERE users.id = ?;', [userId]).then((response) async {
        List tempAppointments = [];
        for (var appointment in response) {
          tempAppointments.add(appointment.fields);
        }

        setState(() {
          scheduledAppointments = tempAppointments;
        });
        print(scheduledAppointments);
        Navigator.pop(context);
      });
    });
  }

  void showAppointmentDialog(date, showAM, showPM) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          backgroundColor: Colors.white,
          title: Text('Book appointment on ${DateFormat('yyyy-MM-dd').format(date)}?', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
          content: Text(!showAM & !showPM?'Sorry, this day is fully booked.':showAM & showPM?'Select your schedule:':'The only available schedule for this day is: ${showAM?'AM':'PM'}'),
          actions: [
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            if (showAM & showPM)
            if (showAM)
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BookAppointmentPage(schedule: 'AM', date: date))).then((value)=>loadData());
              },
              child: const Text('AM'),
            ),
            if (showPM)
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => BookAppointmentPage(schedule: 'PM', date: date))).then((value)=>loadData());
              },
              child: const Text('PM'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar:AppBar(
        title: const Text(
          'Pawssible Solutions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6479ba),
        toolbarHeight: 70,
      ),
      body: TableCalendar(
        rowHeight: 120,
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 60)),
        focusedDay: DateTime.now().subtract(const Duration(days: 1)),
        calendarFormat: calendarFormat,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, date, focusedDate) {
            String dateDisplay = DateFormat('yyyy-MM-dd').format(date);
            int amSlots = 10;
            amSlots -= scheduledAppointments.where((appt) => dateDisplay == DateFormat('yyyy-MM-dd').format(appt['date']) && appt['schedule'] == 'AM').length;
            int pmSlots = 10;
            pmSlots -= scheduledAppointments.where((appt) => dateDisplay == DateFormat('yyyy-MM-dd').format(appt['date']) && appt['schedule'] == 'PM').length;
            return GestureDetector(
              onTap: () {
                bool showAM = amSlots>0;
                bool showPM = pmSlots>0;
                showAppointmentDialog(date, showAM, showPM);
              },
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\n$amSlots Slots\nAM\n',
                      style: const TextStyle(fontSize: 10.0),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$pmSlots Slots\nPM',
                      style: const TextStyle(fontSize: 10.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            );
          },
        ),
      ),
    );
  }
}
