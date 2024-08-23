import 'package:flutter/material.dart';
import 'package:my_first_app/main.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final String? ownerName = sharedPreferences.getString('username');
    final int? ownerId = sharedPreferences.getInt('userId');

    return Scaffold(
      backgroundColor: Color(0xFFF3E5F5),
      appBar: _buildAppBar(),
      body: _buildBody(context, ownerName, ownerId),
      bottomNavigationBar: _buildBottomNavigationBar(context, ownerName, ownerId),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Dashboard',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Color(0xFF6A1B9A),
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
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
          icon: Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, String? ownerName, int? ownerId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(ownerName),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildDashboardCard(
                  icon: Icons.pets,
                  title: 'Make Appointments',
                  subtitle: 'Schedule a visit for your pet',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/appointments',
                      arguments: {'userId': ownerId},
                    );
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.medical_services,
                  title: 'View my Records',
                  subtitle: 'Access medical records of your pets',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/patient_records',
                      arguments: {'userId': ownerId},
                    );
                  },
                ),
                _buildDashboardCard(
                  icon: Icons.queue,
                  title: 'Queue Status',
                  subtitle: 'Check the current queue status',
                  onTap: () {
                    _navigateToQueueStatus(context, ownerName);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String? ownerName) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFCE93D8),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFAB47BC),
            child: Icon(
              Icons.person,
              size: 35,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Hello, $ownerName! 😊',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF8E24AA),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.white,
                ),
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
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF6A1B9A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context, String? ownerName, int? ownerId) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _onTabTapped(index, context, ownerName, ownerId);
      },
      items: [
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
      selectedItemColor: Color(0xFF6A1B9A),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
    );
  }

  void _onTabTapped(int index, BuildContext context, String? ownerName, int? ownerId) {
    switch (index) {
      case 0:
        break; // Current page
      case 1:
        Navigator.pushNamed(context, '/appointments', arguments: {'userId': ownerId});
        break;
      case 2:
        Navigator.pushNamed(context, '/patient_records', arguments: {'userId': ownerId});
        break;
      case 3:
        _navigateToQueueStatus(context, ownerName);
        break;
    }
  }

  void _navigateToAccount(BuildContext context) {
    Navigator.pushNamed(context, '/my_account');
  }

  void _navigateToQueueStatus(BuildContext context, String? ownerName) {
    Navigator.pushNamed(
      context,
      '/queueStatus',
      arguments: ownerName,
    );
  }

  void _logout(BuildContext context) {
    sharedPreferences.clear();
    Navigator.pushReplacementNamed(context, '/');
  }
}
