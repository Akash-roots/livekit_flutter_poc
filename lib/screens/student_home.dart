import 'package:flutter/material.dart';
import 'package:livekit_flutter_poc/screens/student_classes_page.dart';
import 'package:livekit_flutter_poc/screens/teacher_classes_page.dart';
import 'teacher_list_page.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    Center(child: Text('Dashboard (Coming Soon)')),
    TeacherListPage(),
    StudentClassesPage(),
    Center(child: Text('Settings (Coming Soon)')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final drawerItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Teachers'),
    BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Classes'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Panel')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: drawerItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
