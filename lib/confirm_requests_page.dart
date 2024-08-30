import 'package:flutter/material.dart';

class ConfirmRequestsPage extends StatefulWidget {
  @override
  _ConfirmRequestsPageState createState() => _ConfirmRequestsPageState();
}

class _ConfirmRequestsPageState extends State<ConfirmRequestsPage> {
  List<Map<String, dynamic>> requests = [
    {'id': 1, 'name': 'Request 1', 'confirmed': false},
    {'id': 2, 'name': 'Request 2', 'confirmed': false},
    {'id': 3, 'name': 'Request 3', 'confirmed': false},
  ];

  void _confirmRequest(int id) {
    setState(() {
      requests = requests.map((request) {
        if (request['id'] == id) {
          request['confirmed'] = true;
        }
        return request;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Requests'),
        backgroundColor: Color(0xFF6479ba),
      ),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(request['name']),
              trailing: request['confirmed']
                  ? Icon(Icons.check, color: Colors.green)
                  : ElevatedButton(
                      onPressed: () => _confirmRequest(request['id']),
                      child: Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6479ba),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
