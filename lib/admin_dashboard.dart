import 'package:flutter/material.dart';
import 'package:my_first_app/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int appointmentCount = 0;
  int pendingRequestsCount = 0;
  int confirmRequestsCount = 0;
  int queueingCount = 0;
  int patientRecordCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      appointmentCount = 5;  // Example data
      pendingRequestsCount = 3;  // Example data
      confirmRequestsCount = 4;  // Example data
      queueingCount = 2;  // Example data
      patientRecordCount = 10;  // Example data
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? adminName = sharedPreferences.getString('username');

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Color(0xFFD1C4E9),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'my_account') {
                _navigateToAccount(context);
              } else if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'my_account',
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, color: Colors.black),
                      SizedBox(width: 10),
                      Text('My Account'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
            icon: Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFE8EAF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildWelcomeCard(adminName),
            SizedBox(height: 16),
            DashboardItem(
              title: 'Appointment Calendar',
              icon: FontAwesomeIcons.calendarCheck,
              count: appointmentCount,
              onTap: () {
                Navigator.pushNamed(context, '/appointmentCalendar');
              },
            ),
            DashboardItem(
              title: 'Pending Requests',
              icon: FontAwesomeIcons.paw,
              count: pendingRequestsCount,
              onTap: () {
                Navigator.pushNamed(context, '/pendingRequests');
              },
            ),
            DashboardItem(
              title: 'Confirm Requests',
              icon: FontAwesomeIcons.dog,
              count: confirmRequestsCount,
              onTap: () {
                Navigator.pushNamed(context, '/confirmRequests');
              },
            ),
            DashboardItem(
              title: 'Queueing',
              icon: FontAwesomeIcons.bone,
              count: queueingCount,
              onTap: () {
                Navigator.pushNamed(context, '/queueing');
              },
            ),
            DashboardItem(
              title: 'Patient Record List',
              icon: FontAwesomeIcons.clipboardList,
              count: patientRecordCount,
              onTap: () {
                Navigator.pushNamed(context, '/patientRecordList');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String? adminName) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFD1C4E9),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF9575CD),
            child: Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Welcome, Admin $adminName!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF512DA8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAccount(BuildContext context) {
    Navigator.pushNamed(context, '/my_account');
  }

  void _logout(BuildContext context) {
    sharedPreferences.clear();
    Navigator.pushNamed(context, '/');
  }
}

class DashboardItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Function onTap;

  const DashboardItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.count,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF9575CD),
                child: Icon(icon, size: 25, color: Colors.white),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF512DA8),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Users: $count',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}
