import 'package:flutter/material.dart';
import 'db_connection.dart';

class PetForm extends StatefulWidget {
  final String loggedInUserName;
  final int loggedInUserId;

  PetForm({required this.loggedInUserName, required this.loggedInUserId});

  @override
  _PetFormState createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController petNameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController speciesController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController markingsController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController appointmentDateController = TextEditingController();
  DateTime? selectedDate;
  DateTime? selectedAppointmentDate;
  final List<String> availableTimes = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
  ];
  String? selectedAvailableTime;

  Future<void> _selectDate(BuildContext context, TextEditingController controller, {DateTime? initialDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (controller == birthdateController) {
          selectedDate = picked;
        } else if (controller == appointmentDateController) {
          selectedAppointmentDate = picked;
        }
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      await DatabaseHelper().insertPetData(
        ownerId: widget.loggedInUserId,
        petName: petNameController.text,
        breed: breedController.text,
        species: speciesController.text,
        sex: sexController.text,
        age: int.parse(ageController.text),
        birthdate: selectedDate ?? DateTime.now(),
        color: colorController.text,
        markings: markingsController.text.isNotEmpty ? markingsController.text : null,
        contact: contactNoController.text,
        dateAppoint: selectedAppointmentDate ?? DateTime.now(),
        availableTime: selectedAvailableTime ?? '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pet data submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text(
          '${widget.loggedInUserName}\'s Pet Form',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF6A1B9A),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(petNameController, 'Pet Name'),
                            _buildTextField(breedController, 'Breed'),
                            _buildTextField(speciesController, 'Species'),
                            _buildTextField(sexController, 'Sex'),
                            _buildTextFieldWithDatePicker(
                              controller: birthdateController,
                              label: 'Birthdate',
                              context: context,
                              selectedDate: selectedDate,
                            ),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(ageController, 'Age', keyboardType: TextInputType.number)),
                                SizedBox(width: 10),
                                Expanded(child: _buildTextField(colorController, 'Color')),
                              ],
                            ),
                            _buildTextField(markingsController, 'Markings (optional)'),
                            _buildTextField(contactNoController, 'Contact Number'),
                            _buildTextFieldWithDatePicker(
                              controller: appointmentDateController,
                              label: 'Appointment Date',
                              context: context,
                              selectedDate: selectedAppointmentDate,
                            ),
                            _buildDropdownField(
                              value: selectedAvailableTime,
                              label: 'Available Time',
                              items: availableTimes,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedAvailableTime = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6A1B9A),
                            padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF6A1B9A)),
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

  Widget _buildTextFieldWithDatePicker({
    required TextEditingController controller,
    required String label,
    required BuildContext context,
    DateTime? selectedDate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF6A1B9A)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: Color(0xFF6A1B9A)),
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

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF6A1B9A)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
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
    );
  }
}
