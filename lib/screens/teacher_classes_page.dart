import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'class_detail_page.dart';

class TeacherClassesPage extends StatefulWidget {
  const TeacherClassesPage({super.key});

  @override
  State<TeacherClassesPage> createState() => _TeacherClassesPageState();
}

class _TeacherClassesPageState extends State<TeacherClassesPage> {
  List<dynamic> _classes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final baseUrl = dotenv.env['SERVER_URL'];

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/classes/my-classes'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          _classes = json.decode(res.body);
          _loading = false;
        });
      } else {
        print('Error fetching classes: ${res.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void createClassDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create New Class'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter class name'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await createClass(name);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> createClass(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final baseUrl = dotenv.env['SERVER_URL'];

    final res = await http.post(
      Uri.parse('$baseUrl/classes/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );

    if (res.statusCode == 201) {
      fetchClasses();
    } else {
      print('Create class failed: ${res.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: ListView.builder(
        itemCount: _classes.length,
        itemBuilder: (_, i) {
          final cls = _classes[i];
          return ListTile(
            title: Text(cls['name']),
            subtitle: Text('Class ID: ${cls['id']}'),
            onTap: () {
              // TODO: Navigate to student list for this class
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClassDetailPage(
                    classId: cls['id'],
                    className: cls['name'],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createClassDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
