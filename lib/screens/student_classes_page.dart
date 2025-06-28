import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentClassesPage extends StatefulWidget {
  const StudentClassesPage({super.key});

  @override
  State<StudentClassesPage> createState() => _StudentClassesPageState();
}

class _StudentClassesPageState extends State<StudentClassesPage> {
  List<dynamic> _classes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchStudentClasses();
  }

  Future<void> fetchStudentClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final baseUrl = dotenv.env['SERVER_URL'];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/classes/student'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _classes = data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load classes';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_classes.isEmpty) {
      return const Center(child: Text('No classes found.'));
    }

    return ListView.builder(
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final classInfo = _classes[index];
        return ListTile(
          leading: const Icon(Icons.class_),
          title: Text(classInfo['name'] ?? 'Unnamed Class'),
          subtitle: Text('Teacher: ${classInfo['teacher_name'] ?? 'Unknown'}'),
        );
      },
    );
  }
}
