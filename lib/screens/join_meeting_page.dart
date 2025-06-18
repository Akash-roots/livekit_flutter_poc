import 'package:flutter/material.dart';
import 'waiting_room_page.dart'; // Ensure this path is correct

class JoinMeetingPage extends StatefulWidget {
  const JoinMeetingPage({super.key}); // Added const constructor

  @override
  _JoinMeetingPageState createState() => _JoinMeetingPageState();
}

class _JoinMeetingPageState extends State<JoinMeetingPage> {
  // Text controllers for input fields
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _identityController = TextEditingController(
      text: 'Guest-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}' // Pre-fill with a unique guest ID
      );

  // Focus nodes for managing keyboard focus (optional but good practice)
  final FocusNode _roomIdFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _identityFocus = FocusNode();

  @override
  void dispose() {
    // Dispose controllers and focus nodes to prevent memory leaks
    _roomIdController.dispose();
    _passwordController.dispose();
    _identityController.dispose();
    _roomIdFocus.dispose();
    _passwordFocus.dispose();
    _identityFocus.dispose();
    super.dispose();
  }

  // Function to handle the join button press
  void _joinMeeting() {
    final String roomId = _roomIdController.text.trim();
    final String password = _passwordController.text.trim();
    final String userIdentity = _identityController.text.trim();

    // Basic validation
    if (roomId.isEmpty || password.isEmpty || userIdentity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    print(
      'Join pressed: Room=$roomId, Password=$password, Identity=$userIdentity',
    );

    // Navigate to the WaitingRoomPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WaitingRoomPage(
          roomId: roomId,
          password: password,
          userIdentity: userIdentity,
          isHost: false, // User joining as a regular participant
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Consistent gradient background
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
                'Join a Meeting',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Make app bar transparent
              elevation: 0, // No shadow
              expandedHeight: 180, // Taller header
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
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.group_add_outlined, // Relevant icon for joining meeting
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
              ),
              floating: true,
              pinned: false,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(32), // Increased padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95), // Slightly transparent white
                    borderRadius: BorderRadius.circular(28), // More rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Enter Meeting Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF673AB7), // Accent color
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Meeting ID Text Field
                      _buildTextField(
                        controller: _roomIdController,
                        focusNode: _roomIdFocus,
                        labelText: 'Meeting ID',
                        hintText: 'Enter the meeting ID',
                        icon: Icons.meeting_room_outlined,
                        keyboardType: TextInputType.text,
                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                      ),
                      const SizedBox(height: 20),

                      // Room Password Text Field
                      _buildTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        labelText: 'Password',
                        hintText: 'Enter the meeting password',
                        icon: Icons.lock_outline,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_identityFocus),
                      ),
                      const SizedBox(height: 20),

                      // Your Name Text Field
                      _buildTextField(
                        controller: _identityController,
                        focusNode: _identityFocus,
                        labelText: 'Your Name',
                        hintText: 'e.g., John Doe',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        onSubmitted: (_) => _joinMeeting(),
                      ),
                      const SizedBox(height: 40),

                      // Join Button
                      _buildMainButton(
                        'Join Meeting',
                        color: Colors.green.shade600,
                        onTap: _joinMeeting,
                        icon: Icons.arrow_forward_ios,
                      ),
                      const SizedBox(height: 20),

                      // Back to Home Button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Go back to previous screen (Home)
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        child: const Text('Back to Home'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a consistent text field (adapted from login/register)
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    String? hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: const Color(0xFF673AB7), width: 2.5), // Accent border on focus
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      cursorColor: const Color(0xFF673AB7),
    );
  }

  // Helper method for building customized main action buttons (from login_screen)
  Widget _buildMainButton(String text,
      {required Color color, required VoidCallback onTap, IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      height: 60, // Taller button
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          shadowColor: color.withOpacity(0.5),
          textStyle: const TextStyle(
            fontSize: 20, // Larger text
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        icon: icon != null ? Icon(icon, size: 28) : const SizedBox.shrink(), // Larger icon
        label: Text(text),
      ),
    );
  }
}
