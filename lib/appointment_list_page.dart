import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appointment_calendar_page.dart';
import 'db_connection.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  late SharedPreferences sharedPreferences;
  late int userId;
  String? userRole;
  TextEditingController dateController = TextEditingController();
  DateTime? selectedDate = DateTime.now();
  String? selectedSchedule = int.parse(DateFormat('HH').format(DateTime.now()))<12?'AM':'PM';
  List appointments = [];

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
    userRole == 'Customer'?loadDataCustomer():loadDataAdmin();
  }

  loadDataAdmin() {
    final dbHelper = DatabaseHelper();
    dbHelper.connect();
    final conn = dbHelper.connection;
    dbHelper.loadingDialog(context);

    print(selectedDate);

    conn!.query('SELECT appointments.*, appointments.id as appointment_id, pets.* FROM appointments '
        'JOIN pets ON appointments.pet_id = pets.id '
        'JOIN users ON pets.owner_id = users.id '
        'WHERE appointments.date = ? AND appointments.schedule = ? '
        'ORDER BY CASE WHEN appointments.status = "SERVING" THEN 1 WHEN appointments.status = "PENDING" THEN 2 WHEN appointments.status = "COMPLETED" THEN 3 ELSE 4 END, appointments.appointment_number ASC;', [DateFormat('yyyy-MM-dd').format(selectedDate!), selectedSchedule]).then((response) async {
      List tempAppointments = [];
      for (var appointment in response) {
        String age = computeDogAge(appointment.fields['bdate'].toString());
        appointment.fields.addAll({'age': age});
        appointment.fields.addAll({'features': '${appointment.fields['species']}, ${appointment.fields['breed']}, ${appointment.fields['color']}'});
        tempAppointments.add(appointment.fields);
      }

      setState(() {
        appointments = tempAppointments;
      });
      log(appointments.toString());
      Navigator.pop(context);
    });
  }

  loadDataCustomer() {
    final dbHelper = DatabaseHelper();
    dbHelper.connect();
    final conn = dbHelper.connection;
    dbHelper.loadingDialog(context);

    conn!.query('SELECT appointments.*, appointments.id as appointment_id, pets.* FROM appointments '
        'JOIN pets ON appointments.pet_id = pets.id '
        'JOIN users ON pets.owner_id = users.id WHERE users.id = ?;', [userId]).then((response) async {
      List tempAppointments = [];
      for (var appointment in response) {
        String age = computeDogAge(appointment.fields['bdate'].toString());
        appointment.fields.addAll({'age': age});
        appointment.fields.addAll({'features': '${appointment.fields['species']}, ${appointment.fields['breed']}, ${appointment.fields['color']}'});
        tempAppointments.add(appointment.fields);
      }

      setState(() {
        appointments = tempAppointments;
      });
      Navigator.pop(context);
    });
  }

  String computeDogAge(String birthDateString) {
    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime currentDate = DateTime.now();
    int years = currentDate.year - birthDate.year;
    int months = currentDate.month - birthDate.month;
    int days = currentDate.day - birthDate.day;
    if (months < 0) {
      years--;
      months += 12;
    }
    else if (months == 0 && currentDate.day - birthDate.day < 0) {
      years--;
      months += 11;
    }
    
    String yearPart = years == 1 ? '$years yr' : '$years yrs';
    String monthPart = months == 1 ? '$months month' : '$months months';
    String dayPart = days == 1 ? '$days day' : '$days days';

    if (years == 0 && months > 0) {
      return monthPart;
    }
    else if (years == 0 && months == 0){
      return dayPart;
    }

    return '$yearPart and $monthPart';
  }

  chooseStatus(int appointmentId) {
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Update Status',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: InputDecoration(
              labelText: 'Select Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            dropdownColor: Colors.white,
            items: ['PENDING', 'SERVING', 'COMPLETED', 'MISSED', 'CANCELLED'].map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              selectedStatus = value;
            },
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              onPressed: () {
                updateStatus(selectedStatus, appointmentId);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
  
  updateStatus(String? selectedStatus, int appointmentId) {
    final dbHelper = DatabaseHelper();
    dbHelper.connect();
    final conn = dbHelper.connection;
    dbHelper.loadingDialog(context);
    print('UPDATE appointments SET status = $selectedStatus WHERE id = $appointmentId');

    conn!.query(
      'UPDATE appointments SET status = ? WHERE id = ?',
      [selectedStatus, appointmentId],
    ).then((response) async {
      print(response);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment status updated to $selectedStatus!')),
      );

      loadDataAdmin();
    }).catchError((error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              if (userRole == 'Admin')
              Row(
                children: [
                  Expanded(
                    child: _buildTextFieldWithDatePicker(
                      controller: dateController,
                      label: 'Date',
                      context: context,
                      selectedDate: selectedDate,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: _buildDropdownField(
                      value: selectedSchedule, 
                      label: 'Schedule', 
                      items: ['AM', 'PM'],
                      onChanged: (value) {
                        setState(() {
                          selectedSchedule = value!;
                        });
                        loadDataAdmin();
                      }
                    ),
                  )
                ],
              ),
              for (var appointment in appointments)
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        '${appointment['appointment_number']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appointment['pet_name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                          Text('Appointment: ${appointment['type']}'),
                          Text('Date: ${DateFormat('yyyy-MM-dd').format(appointment['date'])}\t\t\t\t\t\tStatus: ${appointment['status']}'),
                          Text('Age: ${appointment['age']}'),
                          Text('${appointment['features']}'),
                        ],
                      )
                    ),
                    if (userRole == 'Admin')
                    IconButton(
                      onPressed: () {
                        chooseStatus(appointment['appointment_id']);
                      },
                      icon: const Icon(Icons.edit)
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        if (userRole == 'Customer')
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF6479ba),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const AppointmentCalendarPage()));
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          )
        )
      ] 
    );
  }

  Widget _buildTextFieldWithDatePicker({
    required TextEditingController controller,
    required String label,
    required BuildContext context,
    DateTime? selectedDate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: (){
          _selectDate(context, controller, initialDate: selectedDate).then((onValue)=>FocusManager.instance.primaryFocus?.unfocus());
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6479ba)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: Color(0xFF6479ba)),
            onPressed: () => _selectDate(context, controller, initialDate: selectedDate),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, {DateTime? initialDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (controller == dateController) {
          selectedDate = picked;
        // } else if (controller == appointmentDateController) {
        //   selectedAppointmentDate = picked;
        }
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
      loadDataAdmin();
    }
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
