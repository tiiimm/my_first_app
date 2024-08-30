import 'package:flutter/material.dart';

class QueueingPage extends StatefulWidget {
  @override
  _QueueingPageState createState() => _QueueingPageState();
}

class _QueueingPageState extends State<QueueingPage> {
  List<Map<String, dynamic>> queue = [
    {'name': '', '': false},
    {'name': '', '': false},
    {'name': '', '': false},
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
        title: Text('Queueing'),
        backgroundColor: Color(0xFF6479ba),
      ),
      body: ListView.builder(
        itemCount: queue.length,
        itemBuilder: (context, index) {
          final item = queue[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(item['name'] ?? 'No Name'),
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
