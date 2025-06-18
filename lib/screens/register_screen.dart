import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'home_screen.dart'; // Import HomeScreen for navigation after registration

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final guardianNameController = TextEditingController();
  final guardianContactController = TextEditingController();
  final bioController = TextEditingController();
  final qualificationsController = TextEditingController();
  final languagesController = TextEditingController();
  final fullNameController = TextEditingController(); // Added for full_name
  DateTime? selectedDateOfBirth; // Added for dob
  String? selectedGender; // Added for gender
  final addressController = TextEditingController(); // Added for address

  String selectedRole = 'student'; // Default role
  String? selectedLanguage;
  File? profileImage;
  bool passwordVisible = false;
  bool isLoading = false;
  final serverUrl = dotenv.env['SERVER_URL'];

  final List<String> languageOptions = [
    'English',
    'Hindi',
    'Telugu',
    'Tamil',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Gujarati',
    'Marathi',
    'Punjabi',
    'Urdu',
    'Other',
  ];

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  // Error messages for validation
  String? passwordError;
  String? languageError;
  String? genderError; // Error for gender dropdown
  String? dobError; // Error for date of birth picker

  @override
  void dispose() {
    // Dispose controllers to free up memory
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    guardianNameController.dispose();
    guardianContactController.dispose();
    bioController.dispose();
    qualificationsController.dispose();
    languagesController.dispose();
    fullNameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
        print('Profile image updated: ${profileImage?.path}'); // Debug print
      });
    } else {
      print('Image picking cancelled or failed.'); // Debug print
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(
                context,
              ).primaryColor, // Use app's primary color
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(
                  context,
                ).primaryColor, // Text color for buttons
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDateOfBirth) {
      setState(() {
        selectedDateOfBirth = picked;
        dobError = null; // Clear error on selection
      });
    }
  }

  Future<void> register() async {
    // Reset all error messages
    setState(() {
      passwordError = null;
      languageError = null;
      genderError = null;
      dobError = null;
    });

    bool hasError = false;

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        passwordError = "Passwords do not match.";
      });
      hasError = true;
    }
    if (selectedLanguage == null) {
      setState(() {
        languageError = "Please select a language preference.";
      });
      hasError = true;
    }
    if (selectedGender == null) {
      setState(() {
        genderError = "Please select your gender.";
      });
      hasError = true;
    }
    if (selectedDateOfBirth == null) {
      setState(() {
        dobError = "Please select your date of birth.";
      });
      hasError = true;
    }

    if (hasError) return; // Stop if there are validation errors

    setState(() => isLoading = true);

    final url = Uri.parse('$serverUrl/auth/register');
    final body = {
      "email": emailController.text.trim(),
      "password": passwordController.text,
      "roles": [selectedRole],
      "language_preference": selectedLanguage,
      "guardian_name": guardianNameController.text,
      "guardian_contact": guardianContactController.text,
      "bio": bioController.text,
      "qualifications": qualificationsController.text,
      "languages": languagesController.text,
      "profile_picture":
          profileImage?.path ?? "", // In production, upload image and send URL

      "full_name": fullNameController.text.trim(), // Added field
      "dob": selectedDateOfBirth
          ?.toIso8601String()
          .split('T')
          .first, // Added field
      "gender": selectedGender, // Added field
      "address": addressController.text.trim(), // Added field
    };
    print("Registering with: $body");

    try {
      final response = await http.post(
        url,
        headers: {"accept": "*/*", "Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      setState(() => isLoading = false);

      if (response.statusCode == 201 || response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Registration Successful"),
            content: const Text("Your account has been created."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        ).then((_) {
          // Navigate to HomeScreen using pushReplacement to prevent going back to registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Registration Failed"),
            content: Text(response.body),
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
      setState(() => isLoading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to register: ${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
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
              Color(0xFFBBDEFB), // Light blue
              Color(0xFFD1C4E9), // Light purple
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450, // Max width for a clean, focused form
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
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // Stretch children
                  children: [
                    // --- Header with custom icon and title ---
                    const Icon(
                      Icons
                          .person_add_alt_1, // More inviting icon for registration
                      size: 70,
                      color: Color(0xFF673AB7), // A deep purple accent
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333), // Darker text for contrast
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Fill in your details to get started!",
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
                    const SizedBox(height: 20),

                    // --- Full Name Input Field ---
                    _buildTextField(
                      "Full Name",
                      controller: fullNameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    // --- Password Input Field ---
                    _buildTextField(
                      "Password",
                      isPassword: true,
                      controller: passwordController,
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () =>
                            setState(() => passwordVisible = !passwordVisible),
                      ),
                    ),
                    if (passwordError != null) _buildErrorText(passwordError!),
                    const SizedBox(height: 20),

                    // --- Confirm Password Input Field ---
                    _buildTextField(
                      "Confirm Password",
                      isPassword: true,
                      controller: confirmPasswordController,
                      icon: Icons.lock_reset_outlined,
                    ),
                    const SizedBox(height: 25),

                    // --- Role Selection (ToggleButtons) ---
                    const Text(
                      "Register As:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(12),
                      selectedBorderColor: Theme.of(context).primaryColor,
                      selectedColor: Colors.white,
                      fillColor: Theme.of(context).primaryColor,
                      color: Colors.grey[700],
                      borderColor: Colors.grey[300],
                      borderWidth: 1.5,
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            'Student',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            'Teacher',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                      onPressed: (int index) {
                        setState(() {
                          selectedRole = index == 0 ? 'student' : 'teacher';
                        });
                      },
                      isSelected: <bool>[
                        selectedRole == 'student',
                        selectedRole == 'teacher',
                      ],
                    ),
                    const SizedBox(height: 25),

                    // --- Date of Birth Picker ---
                    _buildDateOfBirthPicker(context),
                    if (dobError != null) _buildErrorText(dobError!),
                    const SizedBox(height: 20),

                    // --- Gender Dropdown ---
                    _buildDropdownFormField(
                      value: selectedGender,
                      items: genderOptions,
                      hintText: "Select Gender",
                      labelText: "Gender",
                      onChanged: (val) {
                        setState(() {
                          selectedGender = val;
                          genderError = null;
                        });
                      },
                      errorText: genderError,
                      icon: Icons.person_search_outlined,
                    ),
                    const SizedBox(height: 20),

                    // --- Language Preference Dropdown ---
                    _buildDropdownFormField(
                      value: selectedLanguage,
                      items: languageOptions,
                      hintText: "Select Language Preference",
                      labelText: "Language Preference",
                      onChanged: (val) {
                        setState(() {
                          selectedLanguage = val;
                          languageError = null;
                        });
                      },
                      errorText: languageError,
                      icon: Icons.language_outlined,
                    ),
                    const SizedBox(height: 20),

                    // --- Address Input Field ---
                    _buildTextField(
                      "Address",
                      controller: addressController,
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // --- Conditional Fields for Student/Teacher ---
                    if (selectedRole == 'student') ...[
                      _buildTextField(
                        'Guardian Name',
                        controller: guardianNameController,
                        icon: Icons.family_restroom_outlined,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Guardian Contact',
                        controller: guardianContactController,
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 20),
                    ] else if (selectedRole == 'teacher') ...[
                      _buildTextField(
                        'Bio',
                        controller: bioController,
                        icon: Icons.badge_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Qualifications',
                        controller: qualificationsController,
                        icon: Icons.school_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Languages (comma-separated)',
                        controller: languagesController,
                        icon: Icons.translate_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // --- Profile Picture Section ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: profileImage != null
                                ? FileImage(profileImage!)
                                : null,
                            child: profileImage == null
                                ? Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey[600],
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: pickProfileImage,
                              icon: const Icon(Icons.image_outlined),
                              label: const Text("Select Profile Picture"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ), // Consistent rounding
                                ),
                                elevation: 5,
                                shadowColor: Colors.blue.withOpacity(0.3),
                                backgroundColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.8),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- SIGN UP Button ---
                    _buildMainButton(
                      "CREATE ACCOUNT",
                      color: const Color(0xFF673AB7), // Primary accent color
                      onTap: isLoading ? null : () => register(),
                      icon: Icons.person_add_alt_1, // Icon for register button
                    ),
                    const SizedBox(height: 20),

                    // --- Already have an account? ---
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Go back to login screen
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(
                          0xFF673AB7,
                        ), // Matches primary accent
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text(
                        "Already have an account? Sign In",
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

  // Helper method for consistent text field styling
  Widget _buildTextField(
    String hint, {
    bool isPassword = false,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: suffixIcon, // Added suffixIcon support
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
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
          borderSide: BorderSide(color: const Color(0xFF673AB7), width: 2.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  // Helper method for building customized main action buttons (reused from login_screen)
  Widget _buildMainButton(
    String text, {
    required Color color,
    required VoidCallback? onTap,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        icon: icon != null ? Icon(icon, size: 24) : const SizedBox.shrink(),
        label: Text(text),
      ),
    );
  }

  // Helper method for consistent dropdown styling (adapted from previous register_screen but enhanced)
  Widget _buildDropdownFormField<T>({
    required T? value,
    required List<T> items,
    required String hintText,
    required String labelText,
    required ValueChanged<T?> onChanged,
    String? errorText,
    required IconData icon, // Added icon for consistency
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: Icon(
          icon,
          color: Colors.grey[600],
        ), // Prefix icon for dropdown
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
          borderSide: BorderSide(color: const Color(0xFF673AB7), width: 2.5),
        ),
        errorText: errorText,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item.toString(),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  // Helper widget for Date of Birth picker (adapted and enhanced)
  Widget _buildDateOfBirthPicker(BuildContext context) {
    return InkWell(
      onTap: () => _selectDateOfBirth(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          hintText: 'Select Date',
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
            color: Colors.grey[600],
          ), // Icon for date picker
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
            borderSide: BorderSide(color: const Color(0xFF673AB7), width: 2.5),
          ),
          errorText: dobError,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        baseStyle: Theme.of(context).textTheme.titleMedium,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              selectedDateOfBirth == null
                  ? 'Select Date'
                  : '${selectedDateOfBirth!.toLocal().day}/${selectedDateOfBirth!.toLocal().month}/${selectedDateOfBirth!.toLocal().year}',
              style: TextStyle(
                color: selectedDateOfBirth == null
                    ? Colors.grey[700]
                    : Colors.black87,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[600],
            ), // Dropdown arrow icon
          ],
        ),
      ),
    );
  }

  // Helper for consistent error text styling
  Widget _buildErrorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
        left: 16,
        bottom: 8,
      ), // Adjusted padding
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.red, fontSize: 13),
        ),
      ),
    );
  }
}
