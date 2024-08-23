import 'package:flutter/material.dart';
import 'package:my_first_app/login_page.dart';
import 'package:my_first_app/signup_page.dart';
import 'package:my_first_app/dashboard_page.dart';
import 'package:my_first_app/admin_dashboard.dart';
import 'package:my_first_app/pet_form.dart';
import 'package:my_first_app/view_patient.dart';
import 'package:my_first_app/queue_status_page.dart';
import 'package:my_first_app/appointment_calendar_page.dart';
import 'package:my_first_app/pending_requests_page.dart';
import 'package:my_first_app/confirm_requests_page.dart';
import 'package:my_first_app/queueing_page.dart';
import 'package:my_first_app/patient_record_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;
String initialRoute = '/';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();

  // Check if user is logged in and set the initial route based on role
  if (sharedPreferences.containsKey('username') && sharedPreferences.getString('username')!.isNotEmpty) {
    if (sharedPreferences.getString('role') == 'Admin') {
      initialRoute = '/adminDashboard';
    } else if (sharedPreferences.getString('role') == 'Customer') {
      initialRoute = '/dashboard';
    }
  }

  runApp(PawssibleApp());
}

class PawssibleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String loggedInUserName = sharedPreferences.getString('username') ?? 'Unknown';
    final int loggedInUserId = sharedPreferences.getInt('userId') ?? 0;

    return MaterialApp(
      title: 'Pawssible Login',
      theme: ThemeData(
        primaryColor: Color(0xFF6A1B9A),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF4A0072),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/dashboard': (context) => DashboardPage(),
        '/adminDashboard': (context) => AdminDashboard(),
        '/appointments': (context) => PetForm(
          loggedInUserName: loggedInUserName,
          loggedInUserId: loggedInUserId,
        ),
        '/patient_records': (context) => ViewPatientPage(
          userId: loggedInUserId,
        ),
        '/queueStatus': (context) => QueueStatusPage(),
        '/appointmentCalendar': (context) => AppointmentCalendarPage(),
        '/pendingRequests': (context) => PendingRequestsPage(),
        '/confirmRequests': (context) => ConfirmRequestsPage(),
        '/queueing': (context) => QueueingPage(),
        '/patientRecordList': (context) => PatientRecordListPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
