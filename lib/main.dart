import 'package:flutter/material.dart';
import 'db_connection.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;
dynamic initialRoute = const LoginPage();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();

  // Check if user is logged in and set the initial route based on role
  // Contains Key checks if you set a value for the key you're accessing
  // getString will get the value of the key
  // in this case, the key is username
  // sharedPreferences.getString('username')!.isNotEmpty is checking if the value of username is not empty
  // sharedPreferences is used when you want the app to remember an information even after closing it
  if (sharedPreferences.containsKey('username') && sharedPreferences.getString('username')!.isNotEmpty) {
    initialRoute = const HomePage();
    // if (sharedPreferences.getString('role') == 'Admin') {
    //   initialRoute = AdminDashboard();
    // } else if (sharedPreferences.getString('role') == 'Customer') {
    //   initialRoute = DashboardPage();
    // }
  }

  runApp(const PawssibleApp());
}

class PawssibleApp extends StatelessWidget {
  const PawssibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    DatabaseHelper().createTables(); // just run this once start to create the tables and seed
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
      child: MaterialApp(
        title: 'Pawssible Login',
        theme: ThemeData(
          primaryColor: const Color(0xFF6479ba),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color(0xFFFF99F2),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: initialRoute,
        debugShowCheckedModeBanner: false,
      )
    );
  }
}
