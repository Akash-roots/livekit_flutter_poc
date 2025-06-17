import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  State<TeacherListPage> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  List<dynamic> _teachers = [];

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.35:3000/teachers'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _teachers = json.decode(response.body);
      });
    } else {
      print('Failed to load teachers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Teachers')),
      body: ListView.builder(
        itemCount: _teachers.length,
        itemBuilder: (context, index) {
          final teacher = _teachers[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(teacher['profile_picture'] ?? ''),
              ),
              title: Text(teacher['full_name']),
              subtitle: Text(teacher['bio'] ?? ''),
              onTap: () {
                // Next step: open chat or profile
                Navigator.pushNamed(context, '/chat', arguments: teacher);
              },
            ),
          );
        },
      ),
    );
  }
}
