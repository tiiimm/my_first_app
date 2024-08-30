import 'package:flutter/material.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  MySqlConnection? _connection;

  // connect to database
  Future<void> connect() async {
    if (_connection == null) {
      final settings = ConnectionSettings(
        host: '192.168.68.106',
        port: 3306,
        user: 'vetdb',
        password: 'vetdb',
        db: 'vet_db',
      );
      _connection = await MySqlConnection.connect(settings);
    }
  }

  MySqlConnection? get connection => _connection;
  
  // only on start of the system just to create the database table properly. BUT this can also be done in the phpmyadmin portal
  Future<void> createTables() async {
    await connect();

    // Check if 'users' table exists
    Results results = await _connection!.query(
      'SELECT 1 '
      'FROM INFORMATION_SCHEMA.TABLES '
      'WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?',
      ['vet_db', 'users'],
    );
    if (results.isEmpty) {
      await _connection!.query(
        'CREATE TABLE IF NOT EXISTS users ('
        'id INT AUTO_INCREMENT PRIMARY KEY, '
        'fname VARCHAR(255), '
        'mname VARCHAR(255), '
        'lname VARCHAR(255), '
        'contact VARCHAR(15), '
        'username VARCHAR(255) UNIQUE, '
        'password TEXT, '
        'role VARCHAR(255))'
      );
      await seedUsersDatabase();
    }

    // Check if 'pet' table exists
    results = await _connection!.query(
      'SELECT 1 '
      'FROM INFORMATION_SCHEMA.TABLES '
      'WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?',
      ['vet_db', 'pets'],
    );
    if (results.isEmpty) {
      await _connection!.query(
        'CREATE TABLE IF NOT EXISTS pets ('
        'id INT AUTO_INCREMENT PRIMARY KEY, '
        'owner_id INT NOT NULL, '
        'pet_name VARCHAR(255) NOT NULL, '
        'breed VARCHAR(255) NOT NULL, '
        'species VARCHAR(255) NOT NULL, '
        'sex VARCHAR(255) NOT NULL, '
        'bdate DATE NOT NULL, '
        'color VARCHAR(255) NOT NULL, '
        'markings VARCHAR(255), '
        'image VARCHAR(255)'
        ')'
      );
    }

    results = await _connection!.query(
      'SELECT 1 '
      'FROM INFORMATION_SCHEMA.TABLES '
      'WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?',
      ['vet_db', 'appointments'],
    );
    if (results.isEmpty) {
      await _connection!.query(
        'CREATE TABLE IF NOT EXISTS appointments ('
        'id INT AUTO_INCREMENT PRIMARY KEY, '
        'pet_id VARCHAR(255) NOT NULL, '
        'type VARCHAR(255) NOT NULL, '
        'date DATETIME NOT NULL, '
        'schedule VARCHAR(15) NOT NULL, '
        'contact VARCHAR(15), '
        'appointment_number VARCHAR(15), '
        'status VARCHAR(255) NOT NULL'
        ')'
      );
    }
  }

  // Encrypt password
  Future<String> hashPassword(String password) async {
    return await FlutterBcrypt.hashPw(password: password, salt: await FlutterBcrypt.salt());
  }

  Future<void> seedUsersDatabase() async {
    await connect();
    await _connection!.query(
      'INSERT INTO users (fname, mname, lname, contact, username, password, role) VALUES (?,?,?,?,?,?,?)',
      ["Emjay", "Asbi", "Ismael", "09776665678", "emjay", await hashPassword("emjay"), "Admin"]
    );
    await _connection!.query(
      'INSERT INTO users (fname, mname, lname, contact, username, password, role) VALUES (?,?,?,?,?,?,?)',
      ["Glenn", null, "Babalcon", "09766667898", "glenn", await hashPassword("glenn"), "Customer"]
    );
  }

  Future<void> insertPetData({
    required int ownerId,
    required String petName,
    required String breed,
    required String species,
    required String sex,
    required int age,
    required DateTime birthdate,
    required String color,
    required String? markings,
    required String contact,
    required DateTime dateAppoint,
    required String availableTime,
  }) async {
    await connect();
    await _connection!.query(
      'INSERT INTO pet (owner_id, pet_name, breed, species, sex, bdate, color, markings, date_appoint, available_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        ownerId,
        petName,
        breed,
        species,
        sex,
        age,
        birthdate.toIso8601String().split('T')[0],
        color,
        markings,
        contact,
        dateAppoint.toIso8601String(),
        availableTime,
      ],
    );
  }

  Future<List<Map<String, dynamic>>> getPetData(int ownerId) async {
    await connect();
    var results = await _connection!.query(
      'SELECT * FROM pet WHERE owner_id = ?',
      [ownerId],
    );
    return results.map((row) => row.fields).toList();
  }

  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }

  Future<Map<String, dynamic>?> getUserDetails({required String username}) async {
    await connect();
    var results = await _connection!.query(
      'SELECT * FROM users WHERE username = ?',
      [username],
    );
    if (results.isEmpty) return null;
    return results.first.fields;
  }

  loadingDialog(BuildContext context) {
    return showDialog(
      context: context, 
      builder: (BuildContext context) {
        return const Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          backgroundColor: Colors.white,
          child: SizedBox(
            height: 100,
            width: 40,
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Color(0xFF6479ba),),
              ),
            ),
          )
        );
      }
    );
  }
  
  showSnackBar(String message, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }
}
