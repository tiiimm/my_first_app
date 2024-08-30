import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_connection.dart';
import 'pet_form.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  late SharedPreferences sharedPreferences;
  late int userId;
  List appointmentTypes = [
    {'label': 'Consultation', 'icon': Icons.medical_services, 'color': const Color(0xFFF45B69)},
    {'label': 'Vaccination', 'icon': Icons.vaccines, 'color': const Color(0xFF90BEDE)},
    {'label': 'Deworming', 'icon': Icons.medication, 'color': const Color(0xFF2A9D8F)},
    {'label': 'Surgery', 'icon': Icons.healing, 'color': const Color(0xFFCCA43B)},
    {'label': 'Pet Supplies', 'icon': Icons.store, 'color': const Color(0xFFF7AF9D)},
  ];
  List pets = [];
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
    });
    loadData();
  }

  loadData() {
    final dbHelper = DatabaseHelper();
    late final MySqlConnection? conn;
    dbHelper.connect().then((value){
      conn = dbHelper.connection;
      dbHelper.loadingDialog(context);

      conn!.query('SELECT * FROM pets WHERE owner_id= ?', [userId]).then((response) async {
        List temPets = [];
        for (var pet in response) {
          String age = computeDogAge(pet.fields['bdate'].toString());
          pet.fields.addAll({'age': age});
          temPets.add(pet.fields);
        }

        setState(() {
          pets = temPets;
        });
      });

      conn!.query('SELECT appointments.*, pets.pet_name FROM appointments '
        'JOIN pets ON appointments.pet_id = pets.id '
        'JOIN users ON pets.owner_id = users.id '
        'WHERE users.id = ? '
        'ORDER BY appointments.id DESC LIMIT 3;', [userId]).then((response) async {
        List tempAppointments = [];
        for (var appointment in response) {
          tempAppointments.add(appointment.fields);
        }

        setState(() {
          appointments = tempAppointments;
        });
        print(appointments);
        Navigator.pop(context);
      });
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              image: DecorationImage(image: AssetImage('assets/banner1.jpg'), fit: BoxFit.fill)
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft, 
              child:Text(
                'SERVICES', 
                textAlign: TextAlign.start, 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold
                ),
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var type in appointmentTypes)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        color: type['color']
                      ),
                      child: Icon(type['icon'], color: Colors.white,),
                    ),
                    Text(
                      type['label'],
                      style: const TextStyle(
                        fontSize: 12
                      ),
                    )
                  ]
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MY PETS', 
                  textAlign: TextAlign.start, 
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                IconButton(
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                    elevation: WidgetStateProperty.all(0)
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const PetForm())).then((value)=>loadData());
                  },
                  icon: const Icon(Icons.add,)
                )
              ],
            )
          ),
          if (pets.isEmpty)
          const Text('No pets added yet')
          else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (var pet in pets)
                  Container(
                    height: 200,
                    width: 140,
                    margin: EdgeInsets.only(left: pets.indexOf(pet)==0?0:10),
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xFFCDD4F3)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: pet['image'] != null?NetworkImage(pet['image']):const AssetImage('assets/dog.png'),
                          minRadius: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Row(
                            children: [
                              Text(
                                pet['pet_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                              Icon(
                                pet['sex'] == 'Male'?Icons.male:Icons.female,
                                size: 20,
                              )
                            ],
                          )
                        ),
                        Text(
                          pet['age'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600]
                          ),
                        ),
                        Text(
                          pet['breed'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600]
                          ),
                        ),
                      ],
                    ),
                  )
                ]
              ),
            )
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Align(
              alignment: Alignment.centerLeft, 
              child:Text(
                'RECENT APPOINTMENTS', 
                textAlign: TextAlign.start, 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold
                ),
              )
            )
          ),
          // if (appointments.isEmpty)
          // const Text('No appointments in the record yet')
          // else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Container(
              height: 130,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                // border: Border.all(),
                color: Colors.white
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 40,
                      dataRowMinHeight: 26,
                      dataRowMaxHeight: 26,
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Pet')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: [
                        for (var appointment in appointments)
                        DataRow(cells: [
                          DataCell(Text(DateFormat('yyyy-MM-dd').format(appointment['date']))),
                          DataCell(Text(appointment['type'])),
                          DataCell(Text(appointment['pet_name'])),
                          DataCell(Text(appointment['status'])),
                        ]),
                      ],
                    ),
                  ),
                  if (appointments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('No records yet', textAlign: TextAlign.center,),
                  )
                ]
              )
            )
          )
        ],
      ),
    );
  }
}
