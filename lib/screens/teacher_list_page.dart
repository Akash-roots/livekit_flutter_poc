import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'chat_screen.dart';

class TeacherListPage extends StatefulWidget {
  const TeacherListPage({super.key});

  @override
  State<TeacherListPage> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  final serverUrl = dotenv.env['SERVER_URL'];
  String? studentId;

  List<dynamic> _teachers = [];
  bool _isLoading = true; // Added loading state
  String? _errorMessage; // Added error message state

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studentId = prefs.getString('user_id');
    });
  }

  Future<void> _fetchTeachers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication token not found. Please log in again.';
      });
      print('No auth token found');
      // Optionally navigate back to login screen
      // Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$serverUrl/teachers'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _teachers = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load teachers: ${response.statusCode}';
          print('Failed to load teachers: ${response.body}');
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error: Could not fetch teachers. $e';
        print('Error fetching teachers: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFBBDEFB), // Light blue
              Color(0xFFD1C4E9), // Light purple
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text(
                'Available Teachers',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.people_alt, // Icon for teachers list
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
              floating: true,
              pinned: false,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: _isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _errorMessage != null
                  ? SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 50,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _fetchTeachers,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _teachers.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No teachers available at the moment.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final teacher = _teachers[index];
                        return TeacherCard(
                          teacher: teacher,
                          studentId: studentId,
                        );
                      }, childCount: _teachers.length),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final String? studentId;

  const TeacherCard({
    super.key,
    required this.teacher,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // Consistent rounding
      ),
      elevation: 8, // Elevated card shadow
      shadowColor: Colors.purple.withOpacity(0.2),
      child: InkWell(
        onTap: () {
          // Next step: open chat or profile
          // This should navigate to a detail page or chat screen for the teacher
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Tapped on ${teacher['full_name']}')),
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                teacher: teacher,
                studentId:
                    'CURRENT_STUDENT_ID', // Replace with real user ID from token or session
              ),
            ),
          );

          // Example navigation to a chat page (ensure '/chat' route is defined)
          // Navigator.pushNamed(context, '/chat', arguments: teacher);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    (teacher['profile_picture'] != null &&
                        teacher['profile_picture'].isNotEmpty)
                    ? NetworkImage(teacher['profile_picture'])
                    : null,
                child:
                    (teacher['profile_picture'] == null ||
                        teacher['profile_picture'].isEmpty)
                    ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher['full_name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher['qualifications'] ?? 'No qualifications listed',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      teacher['bio'] ?? 'No bio available.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Displaying languages if available
                    if (teacher['languages'] != null &&
                        teacher['languages'].isNotEmpty)
                      Wrap(
                        spacing: 8.0, // horizontal space between chips
                        runSpacing:
                            4.0, // vertical space between lines of chips
                        children: (teacher['languages'] as String)
                            .split(',')
                            .map(
                              (lang) => Chip(
                                label: Text(lang.trim()),
                                backgroundColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: Colors.redAccent,
                  ), // Example action icon
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added ${teacher['full_name']} to favorites!',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
