import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'appointment_list_page.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pet_list_page.dart';
import 'queue_status_page.dart';

GlobalKey pageviewWidgetKey = GlobalKey();
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PageController pageViewController = PageController();
  late SharedPreferences sharedPreferences;
  String? userRole;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    configure();
  }

  configure() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userRole = sharedPreferences.getString('role')!;
    });
    print('JHASFDGA $userRole');
  }

  logout() {
    sharedPreferences.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const LoginPage()));
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
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  onTap: () {
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const Account()));
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.account_circle, color: Colors.black),
                      SizedBox(width: 10),
                      Text('My Account'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  onTap: () {
                    logout();
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: userRole == null ? const Center(child: CircularProgressIndicator()):
      PageView(
        key: pageviewWidgetKey,
        physics: const NeverScrollableScrollPhysics(),
        controller: pageViewController,
        onPageChanged: (page) {
          setState(() {
            currentPage = page;
          });
        },
        children: [
          userRole == 'Admin'?const AdminDashboard():const DashboardPage(),
          if (userRole == 'Customer')const PetListPage(),
          const AppointmentListPage(),
          const QueueStatusPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          pageViewController.animateToPage(index, duration: const Duration(milliseconds: 10), curve: Curves.easeIn);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          if (userRole == 'Customer')
          const BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Pets',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.numbers),
            label: 'Queue',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.queue),
          //   label: 'Queue Status',
          // ),
        ],
        selectedItemColor: const Color(0xFF6479ba),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
