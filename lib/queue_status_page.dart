import 'package:flutter/material.dart';

class QueueStatusPage extends StatefulWidget {
  @override
  _QueueStatusPageState createState() => _QueueStatusPageState();
}

class _QueueStatusPageState extends State<QueueStatusPage> {
  List<Map<String, dynamic>> queue = [
    {'name': '', 'status': false},
    {'name': '', 'status': false},
    {'name': '', 'status': false},
  ];

  void _deleteQueueItem(int index) {
    setState(() {
      queue.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Queue Status',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Color(0xFF6A1B9A),
      ),
      backgroundColor: Color(0xFFF5F5F5), // Set background color to white smoke
      body: ListView.builder(
        itemCount: queue.length,
        itemBuilder: (context, index) {
          final item = queue[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(
                item['name'] ?? 'No Name',
                style: TextStyle(color: Colors.white), // Set text color to white
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteQueueItem(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
