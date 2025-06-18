import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for potential future use (e.g., logout)
import 'create_room_page.dart'; // Ensure this path is correct
import 'join_meeting_page.dart'; // Ensure this path is correct

// Placeholder pages for navigation
class RecentMeetingsPage extends StatelessWidget {
  const RecentMeetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Meetings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No recent meetings found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled Meetings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No upcoming scheduled meetings.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () { /* Navigate to Edit Profile */ },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () { /* Navigate to Notifications Settings */ },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Privacy & Security'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () { /* Navigate to Privacy Settings */ },
            ),
            const Divider(),
            const SizedBox(height: 30),
            Text(
              'General',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () { /* Navigate to Help */ },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About App'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () { /* Navigate to About */ },
            ),
          ],
        ),
      ),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply a consistent gradient background
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
              automaticallyImplyLeading: false, // Removed back button if not needed
              title: const Text(
                'Live Meeting Hub',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Make app bar transparent
              elevation: 0, // No shadow
              expandedHeight: 200, // Even taller header for more impact
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor, // Primary color from theme
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)), // More rounded bottom
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_rounded, // A more engaging video icon
                          color: Colors.white,
                          size: 80, // Larger icon
                        ),
                        SizedBox(height: 15), // More space
                        Text(
                          'Connect with anyone, anywhere, seamlessly.', // More descriptive and engaging tagline
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 17, // Slightly larger font
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floating: true, // App bar floats over content
              pinned: false, // App bar does not pin at the top
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0), // Increased vertical padding
              sliver: SliverToBoxAdapter(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons horizontally
                  children: [
                    const Text(
                      "Your Meeting Dashboard", // A clear section title
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30), // Spacing from title

                    // Create New Meeting Button
                    _buildFeatureButton(
                      context,
                      icon: Icons.video_call_outlined, // Specific icon for creating a call
                      text: 'Start New Meeting', // Clearer call to action
                      gradientColors: [
                        Colors.blue.shade600,
                        Colors.blue.shade800,
                      ],
                      onTap: () {
                        print('Create Room pressed');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  CreateRoomPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 20), // Spacing between buttons

                    // Join Existing Meeting Button
                    _buildFeatureButton(
                      context,
                      icon: Icons.person_add_alt_1_outlined, // Icon for joining a call
                      text: 'Join Meeting via Code', // Clearer call to action
                      gradientColors: [
                        Colors.purple.shade600,
                        Colors.deepPurple.shade800,
                      ],
                      onTap: () {
                        print('Join Meeting pressed');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  JoinMeetingPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 40), // Spacing before other actions

                    // Placeholder for engaging content: Recent Meetings / Quick Actions
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), // Slightly transparent white
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quick Actions & Insights",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Easily jump back into recent meetings or explore new options. "
                                "Your personalized dashboard awaits!",
                            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickActionButton(
                                Icons.history,
                                "Recent",
                                () {
                                  // Navigate to RecentMeetingsPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RecentMeetingsPage()),
                                  );
                                },
                              ),
                              _buildQuickActionButton(
                                Icons.calendar_today,
                                "Schedule",
                                () {
                                  // Navigate to SchedulePage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SchedulePage()),
                                  );
                                },
                              ),
                              _buildQuickActionButton(
                                Icons.settings,
                                "Settings",
                                () {
                                  // Navigate to SettingsPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Log Out Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('auth_token');
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Logged out successfully.")),
                        );
                      },
                      icon: const Icon(Icons.logout, size: 24),
                      label: const Text('Log Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400, // A clear logout color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8, // More prominent shadow
                        shadowColor: Colors.red.shade400.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for consistent feature buttons (Create/Join Meeting)
  Widget _buildFeatureButton(
      BuildContext context, {
        required IconData icon,
        required String text,
        required List<Color> gradientColors,
        required VoidCallback onTap,
      }) {
    return Container(
      height: 70, // Even taller buttons for more significant impact
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // More rounded corners
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.5), // Stronger shadow matching gradient
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // Make Material transparent to show gradient
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 35, color: Colors.white), // Larger icon
                const SizedBox(width: 20), // More space
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 22, // Larger text
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0, // Increased letter spacing
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated helper method for quick action buttons with onTap functionality
  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell( // Added InkWell for tap detection and ripple effect
      onTap: onTap,
      borderRadius: BorderRadius.circular(15), // Match container's border radius
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
