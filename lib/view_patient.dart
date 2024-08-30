import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_connection.dart'; // Ensure this import points to your DatabaseHelper class

class ViewPatientPage extends StatefulWidget {
  const ViewPatientPage({super.key});


  @override
  ViewPatientPageState createState() => ViewPatientPageState();
}

class ViewPatientPageState extends State<ViewPatientPage> {
  late SharedPreferences sharedPreferences;
  late String username;
  late int userId;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 240, 241),
      appBar: AppBar(
        title: Text('View Patient - $username'),
        backgroundColor: const Color(0xFF6479ba),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPatientRecords(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading patient records. Please try again.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No records found.'));
          } else {
            return _buildViewPatientBody(snapshot.data!);
          }
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPatientRecords(int userId) async {
    final dbHelper = DatabaseHelper();
    try {
      return await dbHelper.getPetData(userId);
    } catch (e) {
      print('Error fetching patient records: $e');
      return [];
    }
  }

  Widget _buildViewPatientBody(List<Map<String, dynamic>> records) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              title: Text(record['pet_name']),
              subtitle: Text(
                'Breed: ${record['breed']}\n'
                'Species: ${record['species']}\n'
                'Age: ${record['age']}\n'
                'Appointment: ${record['date_appoint']} at ${record['available_time']}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.pets, color: Color(0xFF6479ba)),
            ),
          );
        },
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // Assuming this is the "Patient Records" tab
      onTap: (index) {
        _onTabTapped(index, context);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: 'Patient Records',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.queue),
          label: 'Queue Status',
        ),
      ],
      selectedItemColor: const Color(0xFF6479ba),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
    );
  }

  void _onTabTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/appointments');
        break;
      case 2:
        // Navigate to the current page
        Navigator.pushNamed(context, '/patient_records');
        break;
      case 3:
        Navigator.pushNamed(context, '/queueStatus');
        break;
    }
  }
}
