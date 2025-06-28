import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClassDetailPage extends StatefulWidget {
  final int classId;
  final String className;

  const ClassDetailPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  List _students = [];
  final _studentIdController = TextEditingController();

  Future<void> _fetchStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url =
        '${dotenv.env['SERVER_URL']}/classes/${widget.classId}/students';

    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() {
        _students = json.decode(res.body);
      });
    } else {
      print('Failed to load students');
    }
  }

  Future<void> _addStudent() async {
    final studentId = _studentIdController.text;
    if (studentId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url =
        '${dotenv.env['SERVER_URL']}/classes/${widget.classId}/students';

    final res = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'studentId': int.parse(studentId)}),
    );

    if (res.statusCode == 200) {
      _studentIdController.clear();
      _fetchStudents();
    } else {
      print('Failed to add student: ${res.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.className)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (_, index) {
                final student = _students[index];
                return ListTile(
                  title: Text(student['full_name'] ?? 'Unnamed'),
                  subtitle: Text(student['email'] ?? ''),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Student ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: _addStudent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
