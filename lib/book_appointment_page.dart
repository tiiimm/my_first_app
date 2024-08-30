import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_connection.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key, required this.schedule, required this.date});
  final String schedule;
  final DateTime date;

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  late SharedPreferences sharedPreferences;
  late int userId;
  int? selectedPetId;
  String? selectedAppointmentType;
  List pets = [];
  TextEditingController contactNumberController = TextEditingController();
  
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
    dbHelper.connect();
    final conn = dbHelper.connection;
    dbHelper.loadingDialog(context);

    conn!.query('SELECT * FROM pets WHERE owner_id= ?', [userId]).then((response) async {
      List tempPets = [];
      for (var pet in response) {
        tempPets.add(pet.fields);
      }

      setState(() {
        pets = tempPets;
      });
      Navigator.pop(context);
    });
  }

  bookAppointment() {
    final dbHelper = DatabaseHelper();
    dbHelper.connect();
    final conn = dbHelper.connection;
    dbHelper.loadingDialog(context);

    conn!.query('SELECT MAX(appointment_number) as max_appointment_number FROM appointments WHERE date = ? AND schedule = ?', [DateFormat('yyyy-MM-dd').format(widget.date), widget.schedule]).then((result) {
      int nextAppointmentNumber = 1;
      if (result.isNotEmpty && result.first['max_appointment_number'] != null) {
        nextAppointmentNumber = int.parse(result.first['max_appointment_number']) + 1;
      }
      log(nextAppointmentNumber.toString());
      conn.query('INSERT INTO appointments (pet_id, type, date, schedule, contact, appointment_number, status) VALUES (?, ?, ?, ?, ?, ?, ?)', 
      [selectedPetId, selectedAppointmentType, DateFormat('yyyy-MM-dd').format(widget.date), widget.schedule, contactNumberController.text, nextAppointmentNumber, 'PENDING']).then((response) async {
        Navigator.pop(context); //loading
        showConfirmationDialog(nextAppointmentNumber);
      });
    });

  }

  void showConfirmationDialog(number) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          backgroundColor: Colors.white,
          title: const Text('Success', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
          content: SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Successfully set the appointment. Your appointment number is'),
                  Text('$number', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),)
                ],
              ),
            )
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ButtonTheme(
                alignedDropdown: true,
                padding: EdgeInsets.zero,
                child: DropdownButtonFormField<int>(
                  value: selectedPetId,
                  decoration: InputDecoration(
                    labelText: 'Appointment for',
                    labelStyle: const TextStyle(color: Color(0xFF6479ba)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 16
                  ),
                  dropdownColor: Colors.white,
                  items: pets.map((pet) {
                    return DropdownMenuItem<int>(
                      value: int.parse(pet['id'].toString()),
                      child: Text(pet['pet_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPetId = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a pet';
                    }
                    return null;
                  },
                )
              ),
            ),
            _buildDropdownField(
              value: selectedAppointmentType, 
              label: 'Appointment Type', 
              items: ['Consultation', 'Vaccination', 'Deworming'],
              onChanged: (value) {
                setState(() {
                  selectedAppointmentType = value!;
                });
              }
            ),
            _buildTextField(contactNumberController, 'Contact Number'),
            Padding(
              padding: const EdgeInsets.only(top:10),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    bookAppointment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6479ba),
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        )
      )
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6479ba)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ButtonTheme(
      alignedDropdown: true,
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF6479ba)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black,
            fontSize: 16
          ),
          dropdownColor: Colors.white,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      )
    );
  }
}
