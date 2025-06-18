import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'teacher_list_page.dart'; // Make sure this import is correct and the file exists
import 'register_screen.dart';
import 'home_screen.dart'; // Make sure this import is correct and the file exists
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Removed phoneController as it's not used in login logic and not part of the core UI goal

  void login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    print("Attempting login for Email: $email, Password: $password");
    final serverUrl = dotenv.env['SERVER_URL'];

    final url = Uri.parse('$serverUrl/auth/login');
    print("API URL: $url");

    try {
      final response = await http.post(
        url,
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        final String? token = jsonResponse['token'];
        final List<String> roles = List<String>.from(
          jsonResponse['role'] ?? [],
        );
        final String? userId = jsonResponse['user_id'];

        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          if (userId != null) {
            await prefs.setString('userId', userId);
          }
          print("Auth token saved: $token");
          print("roles saved: $roles");

          // Navigate based on role
          if (roles.contains('student')) {
            print("Navigating to TeacherListPage as teacher role detected.");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TeacherListPage()),
            );
          } else {
            print("Navigating to HomeScreen for non-teacher role.");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login successful!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(
            "Login successful, but token is missing or invalid in response.",
          );
        }
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? jsonDecode(response.body)['message'] ??
                  "Invalid username or password"
            : "Invalid username or password. Please try again.";

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Login Failed"),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Error during login request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: Failed to connect to server or parse response. $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply a subtle gradient background for a modern feel
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8EC5FC), // Light blue
              Color(0xFFE0C3FC), // Light purple
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // Added SingleChildScrollView to prevent overflow on small screens/keyboard
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400, // Max width for a clean, focused form
              ),
              child: Container(
                padding: const EdgeInsets.all(32), // Increased padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    28,
                  ), // More rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15), // Deeper shadow
                      blurRadius: 25, // More blur
                      offset: const Offset(0, 15), // Offset downwards
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Header with custom icon and title ---
                    const Icon(
                      Icons.lock_open_rounded, // More inviting lock icon
                      size: 70,
                      color: Color(0xFF673AB7), // A deep purple accent
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333), // Darker text for contrast
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sign in to continue to your account",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // --- Email Input Field ---
                    _buildTextField(
                      "Email Address",
                      controller: emailController,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20), // Increased spacing
                    // --- Password Input Field ---
                    _buildTextField(
                      "Password",
                      isPassword: true,
                      controller: passwordController,
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 25), // Spacing before login button
                    // --- Login Button ---
                    _buildMainButton(
                      "Log In",
                      color: const Color(0xFF673AB7), // Primary accent color
                      onTap: () => login(context),
                      icon: Icons.login, // Icon for the login button
                    ),

                    const SizedBox(height: 25), // Spacing after login button
                    // --- Or divider with improved styling ---
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Colors.grey, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Colors.grey, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // --- Social Login Buttons ---
                    _buildSocialButton(
                      icon: Icons.mail_outline, // Generic Google icon
                      text: "Continue with Google",
                      color: Colors.white,
                      textColor: Colors.black87,
                      borderColor: Colors.grey[300],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Google Sign-in not implemented"),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildSocialButton(
                      icon: Icons.account_circle, // Generic Twitter icon
                      text: "Continue with Twitter",
                      color: const Color(0xFF1DA1F2), // Twitter blue
                      textColor: Colors.white,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Twitter Sign-in not implemented"),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30), // Spacing before sign up link
                    // --- Sign Up Link ---
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(
                          0xFF673AB7,
                        ), // Matches primary accent
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for building customized text fields
  Widget _buildTextField(
    String hint, {
    bool isPassword = false,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint, // Floating label effect
        prefixIcon: Icon(
          icon,
          color: Colors.grey[600],
        ), // Icon inside the text field
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // More rounded corners
          borderSide: BorderSide.none, // No visible border initially
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.5,
          ), // Subtle border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: const Color(0xFF673AB7),
            width: 2.5,
          ), // Accent border on focus
        ),
        filled: true,
        fillColor: Colors.grey[50], // Light grey fill
      ),
    );
  }

  // Helper method for building customized main action buttons
  Widget _buildMainButton(
    String text, {
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55, // Taller button
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white, // Text/icon color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              15,
            ), // Matches text field rounding
          ),
          elevation: 10, // More pronounced shadow
          shadowColor: color.withOpacity(0.5), // Shadow matches button color
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8, // Slightly increased letter spacing
          ),
        ),
        icon: icon != null ? Icon(icon, size: 24) : const SizedBox.shrink(),
        label: Text(text),
      ),
    );
  }

  // Helper method for building customized social login buttons
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
      height: 55, // Taller button
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
          ), // Matches other elements
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        onPressed: onTap,
      ),
    );
  }
}
