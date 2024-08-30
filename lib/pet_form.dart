import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_connection.dart';

class PetForm extends StatefulWidget {
  const PetForm({super.key});


  @override
  PetFormState createState() => PetFormState();
}

class PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences sharedPreferences;
  late String username;
  late int userId;

  final TextEditingController petNameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController speciesController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController markingsController = TextEditingController();
  DateTime? selectedDate;
  // final List<String> availableTimes = [
  //   '09:00 AM - 10:00 AM',
  //   '10:00 AM - 11:00 AM',
  //   '11:00 AM - 12:00 PM',
  //   '01:00 PM - 02:00 PM',
  //   '02:00 PM - 03:00 PM',
  //   '03:00 PM - 04:00 PM',
  // ];
  // String? selectedAvailableTime;

  @override
  void initState() {
    super.initState();
    configure();
  }

  configure() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      username = sharedPreferences.getString('username')!;
      userId = sharedPreferences.getInt('userId')!;
    });
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
        if (controller == birthdateController) {
          selectedDate = picked;
        // } else if (controller == appointmentDateController) {
        //   selectedAppointmentDate = picked;
        }
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final dbHelper = DatabaseHelper();
      dbHelper.connect();
      final conn = dbHelper.connection;
      dbHelper.loadingDialog(context);

      conn!.query('INSERT INTO pets (owner_id, pet_name, breed, species, sex, bdate, color, markings) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [userId, petNameController.text, breedController.text, speciesController.text, sexController.text, birthdateController.text, colorController.text, markingsController.text]).then((response) async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet data submitted successfully!')),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/dog.png'),
                  radius: 60,
                ),
              ),
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
                  Expanded(child: _buildTextField(colorController, 'Color')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(markingsController, 'Markings (optional)', inputAction: TextInputAction.done)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top:10),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, TextInputAction inputAction = TextInputAction.next}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        textInputAction: inputAction,
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
        validator: controller == markingsController?null: (value) {
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
}
