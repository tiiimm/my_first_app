import 'package:flutter/material.dart';
import 'package:my_first_app/db_connection.dart';
import 'package:my_first_app/pet_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetListPage extends StatefulWidget {
  const PetListPage({super.key});

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  late SharedPreferences sharedPreferences;
  late int userId;
  late String userRole;
  List pets = [];

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
        String age = computeDogAge(pet.fields['bdate'].toString());
        pet.fields.addAll({'age': age});
        pet.fields.addAll({'features': '${pet.fields['species']}, ${pet.fields['breed']}, ${pet.fields['color']}'});
        tempPets.add(pet.fields);
      }

      setState(() {
        pets = tempPets;
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              for (var pet in pets)
              Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CircleAvatar(
                        backgroundImage: pet['image'] != null?NetworkImage(pet['image']):const AssetImage('assets/dog.png'),
                        minRadius: 50,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pet['pet_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                          Text('Age: ${pet['age']}'),
                          Text('${pet['features']}'),
                        ],
                      )
                    ),
                    if (userRole == 'Admin')
                    IconButton(
                      onPressed: () {

                      },
                      icon: const Icon(Icons.edit)
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF6479ba),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const PetForm())).then((onValue) => loadData());
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          )
        )
      ] 
    );
  }
}
