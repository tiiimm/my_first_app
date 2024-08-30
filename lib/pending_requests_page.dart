import 'package:flutter/material.dart';

class PendingRequestsPage extends StatefulWidget {
  @override
  _PendingRequestsPageState createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  List<Map<String, dynamic>> requests = [
    {'id': 1, 'name': 'Request 1', 'status': 'pending'},
    {'id': 2, 'name': 'Request 2', 'status': 'pending'},
    {'id': 3, 'name': 'Request 3', 'status': 'pending'},
  ];

  void _updateRequestStatus(int id, String status) {
    setState(() {
      requests = requests.map((request) {
        if (request['id'] == id) {
          request['status'] = status;
        }
        return request;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Requests'),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (request['status'] == 'pending') ...[
                    ElevatedButton(
                      onPressed: () => _updateRequestStatus(request['id'], 'approved'),
                      child: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _updateRequestStatus(request['id'], 'denied'),
                      child: Text('Deny'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ] else if (request['status'] == 'approved') ...[
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 5),
                    Text('Approved', style: TextStyle(color: Colors.green)),
                  ] else if (request['status'] == 'denied') ...[
                    Icon(Icons.close, color: Colors.red),
                    SizedBox(width: 5),
                    Text('Denied', style: TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
