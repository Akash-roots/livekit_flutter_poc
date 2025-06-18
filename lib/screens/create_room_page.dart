import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:http/http.dart' as http;
import 'waiting_room_page.dart'; // Ensure this path is correct
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Consider moving serverUrl to a separate config file for better management
final serverUrl = dotenv.env['SERVER_URL'];

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key}); // Added const constructor

  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  String? roomId;
  String? password;
  bool _loading = true; // State to manage loading indicator
  String? _errorMessage; // To display error messages

  @override
  void initState() {
    super.initState();
    _createRoom(); // Automatically create room on page load
  }

  // Function to create a new room by calling the backend API
  Future<void> _createRoom() async {
    setState(() {
      _loading = true;
      _errorMessage = null; // Clear previous errors
    });
    try {
      final response = await http.get(Uri.parse('$serverUrl/api/create-room'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Room ID: ${data['room_id']}");
        print("Room Password: ${data['room_password']}");
        setState(() {
          roomId = data['room_id'];
          password = data['room_password'];
          _loading = false; // Stop loading
        });
      } else {
        // Handle API error
        setState(() {
          _loading = false;
          _errorMessage =
              'Failed to create room: ${response.statusCode} ${response.body}';
        });
        print('Failed to create room: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error creating room: $e');
      setState(() {
        _loading = false; // Stop loading even on error
        _errorMessage =
            'Network error: Could not connect to server. Please try again. ($e)';
      });
    }
  }

  // Function to copy text to clipboard and show a confirmation message
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(
      ClipboardData(text: text),
    ); // Use Clipboard from services.dart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label Copied!'),
        duration: const Duration(seconds: 1),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  // Function to show a simple invite dialog for various invite types
  void _showInviteDialog(
    BuildContext context,
    String inviteType,
    String? meetingDetails,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController emailController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '$inviteType Invitation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            // Added SingleChildScrollView for dialog content
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (inviteType == 'Invite via Email') ...[
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Enter Email Addresses (comma-separated)',
                      hintText: 'e.g., user1@gmail.com, user2@example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ), // Rounded corners for dialog text field
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey[600],
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    maxLines: null, // Allow multiple lines for multiple emails
                    minLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Meeting Details:\n$meetingDetails',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ] else if (inviteType == 'Invite Members') ...[
                  Text(
                    'You can share the meeting details below manually or use other methods:',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: SelectableText(
                      // Use SelectableText for easy copying by long press
                      meetingDetails!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (meetingDetails != null) {
                        _copyToClipboard(meetingDetails, 'Meeting Details');
                      }
                    },
                    icon: const Icon(Icons.copy, size: 20),
                    label: const Text(
                      'Copy All Details',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (inviteType == 'Invite via Email') {
                      final emails = emailController.text
                          .trim()
                          .split(',')
                          .map((e) => e.trim())
                          .toList();
                      final validEmails = emails
                          .where(
                            (email) => email.isNotEmpty && email.contains('@'),
                          )
                          .toList();

                      if (validEmails.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter at least one valid email address.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      for (final email in validEmails) {
                        // Simulate email sending for each valid email
                        print(
                          'Sending email invitation to: $email with details: $meetingDetails',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invitation sent to $email!'),
                            backgroundColor: Colors.green.shade600,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$inviteType functionality would be integrated here.',
                          ),
                          backgroundColor: Colors.green.shade600,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Confirm Invitation',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate meeting details string
    final String meetingDetailsText = roomId != null && password != null
        ? 'Room ID: $roomId\nPassword: $password'
        : 'Meeting details not available.';

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
                'Create New Meeting',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
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
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.video_call, // Relevant icon for creating meeting
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
              sliver: _loading
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text(
                              'Generating your new meeting room...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                color: Colors.red.shade600,
                                size: 60,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton.icon(
                                onPressed: _createRoom, // Retry button
                                icon: const Icon(Icons.refresh, size: 24),
                                label: const Text(
                                  'Try Again',
                                  style: TextStyle(fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverToBoxAdapter(
                      // <--- Wrapped SingleChildScrollView with SliverToBoxAdapter
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Card to highlight room details
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.95,
                                ), // Slightly transparent white
                                borderRadius: BorderRadius.circular(
                                  28,
                                ), // More rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 25,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Your New Meeting is Ready!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF673AB7), // Accent color
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  // Room ID display with copy button
                                  _buildDetailRow(
                                    label: 'Meeting ID:',
                                    value: roomId!,
                                    icon: Icons.meeting_room_outlined,
                                    onCopy: () =>
                                        _copyToClipboard(roomId!, 'Meeting ID'),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ), // Increased spacing
                                  // Password display with copy button
                                  _buildDetailRow(
                                    label: 'Password:',
                                    value: password!,
                                    icon: Icons.lock_outline,
                                    onCopy: () =>
                                        _copyToClipboard(password!, 'Password'),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Share these details with participants to join your meeting.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ), // Spacing before Join as Host button
                            // Join as Host button
                            _buildMainButton(
                              'Start Meeting Now',
                              color: Colors.green.shade600,
                              onTap: () {
                                print('Joining as Host (room_id: $roomId)');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WaitingRoomPage(
                                      roomId: roomId!,
                                      password: password!,
                                      userIdentity:
                                          'Host-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', // Dynamic host identity
                                      isHost: true,
                                    ),
                                  ),
                                );
                              },
                              icon: Icons.videocam,
                            ),
                            const SizedBox(height: 40),

                            Text(
                              'Invite Participants:',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            // Invite Members Button
                            _buildSocialButton(
                              icon: Icons.person_add_alt_1_outlined,
                              text: 'Invite Members',
                              color: Colors.white,
                              textColor: Colors.black87,
                              borderColor: Colors.grey[300],
                              onTap: () => _showInviteDialog(
                                context,
                                'Invite Members',
                                meetingDetailsText,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Invite via Gmail Button
                            _buildSocialButton(
                              icon: Icons
                                  .email_outlined, // Using generic email icon for consistency
                              text: 'Invite via Email',
                              color: Colors.red.shade600, // Gmail red
                              textColor: Colors.white,
                              onTap: () => _showInviteDialog(
                                context,
                                'Invite via Email',
                                meetingDetailsText,
                              ),
                            ),
                            const SizedBox(height: 40),
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

  // Helper widget to build a detail row with a label, value, and copy button (Enhanced)
  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10), // Increased spacing
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ), // Increased padding
          decoration: BoxDecoration(
            color: Colors.grey[50], // Light grey fill
            borderRadius: BorderRadius.circular(15), // More rounded corners
            border: Border.all(
              color: Colors.grey.shade300!,
              width: 1.5,
            ), // Subtle border
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF673AB7),
                size: 24,
              ), // Accent color icon
              const SizedBox(width: 15),
              Expanded(
                child: SelectableText(
                  // Use SelectableText for easy text selection
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy,
                  color: Theme.of(context).primaryColor,
                ), // Copy icon with primary color
                onPressed: onCopy,
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for building customized main action buttons (from login_screen)
  Widget _buildMainButton(
    String text, {
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
  }) {
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
        icon: icon != null
            ? Icon(icon, size: 28)
            : const SizedBox.shrink(), // Larger icon
        label: Text(text),
      ),
    );
  }

  // Helper method for building customized social login/invite buttons (from login_screen)
  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55, // Consistent height
      child: OutlinedButton.icon(
        icon: Icon(icon, color: textColor, size: 24),
        label: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        onPressed: onTap,
      ),
    );
  }
}
