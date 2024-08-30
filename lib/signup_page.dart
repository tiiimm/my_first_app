import 'package:flutter/material.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:mysql1/mysql1.dart'; // Ensure you have mysql1 dependency

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;  // Loading state variable

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;  // Show loading indicator
      });

      try {
        final firstName = _firstNameController.text;
        final lastName = _lastNameController.text;
        final contact = _contactController.text;
        final username = _usernameController.text;
        final password = _passwordController.text;

        // Hash the password
        final hashedPassword = await FlutterBcrypt.hashPw(
          password: password,
          salt: await FlutterBcrypt.salt(),
        );

        // Connect to the database
        final settings = ConnectionSettings(
          host: '192.168.1.139',
          port: 3306,
          user: 'vetdb',
          password: 'vetdb',
          db: 'vet_db',
        );
        final conn = await MySqlConnection.connect(settings);

        // Insert the new user into the database
        await conn.query(
          'INSERT INTO user (fname, mname, lname, contact, username, password, role) VALUES (?,?,?,?,?,?,?)',
          [firstName, null, lastName, contact, username, hashedPassword, 'Customer'],
        );

        await conn.close();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-up successful! Redirecting to login...'),
          ),
        );

        // Wait for a moment to let the user see the message
        await Future.delayed(Duration(seconds: 2));

        // Navigate back to the login page
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-up failed! Please try again.'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;  // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F0FF),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildLogo(),
                    SizedBox(height: 20),
                    _buildSignUpForm(),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6479ba)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          'https://cdn-icons-png.flaticon.com/512/616/616408.png',
          width: 80,
        ),
        SizedBox(height: 10),
        Text(
          'Pawssible',
          style: TextStyle(
            fontSize: 28,
            color: Color(0xFF6479ba),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _firstNameController,
              labelText: 'First Name',
              hintText: 'Enter your first name',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _lastNameController,
              labelText: 'Last Name',
              hintText: 'Enter your last name',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _contactController,
              labelText: 'Contact',
              hintText: 'Enter your contact number',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _usernameController,
              labelText: 'Username',
              hintText: 'Choose a username',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
            ),
            SizedBox(height: 20),
            _buildSignUpButton(),
            SizedBox(height: 10),
            _buildLoginRedirect(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Color(0xFFF3F0FF),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _signUp,
      child: Center(
        child: Text('Sign Up'),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50), // Full-width button
        backgroundColor: Color(0xFF6479ba),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context); // Pops the SignUpPage and returns to the LoginPage
      },
      child: Center(
        child: Text(
          "Already have an account? Log in",
          style: TextStyle(
            color: Color(0xFF6479ba),
          ),
        ),
      ),
    );
  }
}
