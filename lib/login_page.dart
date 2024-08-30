import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'db_connection.dart';
import 'home_page.dart';
import 'signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  File? _image;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
      });
    }
  }

  Future<bool> verifyPassword(String hashedPassword) async {
    return await FlutterBcrypt.verify(password: _passwordController.text, hash: hashedPassword);
  }

  Future<void> login() async {
    final dbHelper = DatabaseHelper();
    dbHelper.connect();
    final conn = dbHelper.connection;
    dbHelper.loadingDialog(context);

    conn!.query('SELECT * FROM users WHERE username= ?', [_usernameController.text]).then((results) async {
      if (results.isNotEmpty) {
        final user = results.first.fields;
        final hashedPassword = user['password'].toString();

        // Verify the password using bcrypt
        if (await verifyPassword(hashedPassword)) {
          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          //saving username in session
          sharedPreferences.setString('username', user['username']);
          //saving role in session
          sharedPreferences.setString('role', user['role']);
          sharedPreferences.setInt('userId', user['id']);

          // if (user['role'] == 'Admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const HomePage()));
          // } else if (user['role'] == 'Customer') {
          //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => DashboardPage()));
          // } else {
          //   dbHelper.showSnackBar('Invalid role. Please contact support.', context);
          // }
        } else {
          dbHelper.showSnackBar('Invalid Credentials', context);
        }
      } else {
        dbHelper.showSnackBar('Invalid Credentials', context);
      }
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _image == null
                          ? Image.network(
                              'https://cdn-icons-png.flaticon.com/512/616/616408.png',
                              width: 50,
                            )
                          : Image.file(
                              _image!,
                              width: 50,
                            ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Pawssible',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF6479ba),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF6479ba),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF6479ba),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6479ba),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SignUpPage())),
                  child: const Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(
                      color: Color(0xFF6479ba),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '🐾 Welcome to Pawssible!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6479ba),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}