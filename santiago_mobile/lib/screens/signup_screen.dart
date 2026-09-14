// Enhancement 2: Signup screen collecting user details and registering a new account via Firebase Auth
import 'package:flutter/material.dart';

// Import ScreenUtil package for responsive screen dimensions and font scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import UserService to execute account registration and session persistence
import '../services/user_service.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Screen collecting new user registration details and registering account
class SignupScreen extends StatefulWidget {
  // Constructor initializing SignupScreen widget
  const SignupScreen({super.key});

  // Creates mutable state instance for SignupScreen widget
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

// State class managing the signup form, validation, and Firebase Auth account creation
class _SignupScreenState extends State<SignupScreen> {
  // Global key used to validate form input fields
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for all required input fields
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Toggles password fields visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Tracks whether a registration request is currently in progress
  bool _isLoading = false;

  // Lifecycle method disposing text controllers to prevent memory leaks
  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _ageController.dispose();
    _contactNoController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handles form submission, Firebase Auth account creation, and user session initialization
  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final UserService userService = UserService();
    setState(() {
      _isLoading = true;
    });

    try {
      // Create Firebase Auth user account with email and password
      final credential = await userService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (credential.user != null) {
        // Set display name in Firebase Auth
        final String fullName = '${_fNameController.text.trim()} ${_lNameController.text.trim()}';
        await userService.updateUsername(username: _usernameController.text.trim());
        await credential.user!.updateDisplayName(fullName);

        // Save session details into SharedPreferences
        await userService.saveFirebaseUserData(
          user: credential.user!,
          extraDetails: {
            'fName': _fNameController.text.trim(),
            'lName': _lNameController.text.trim(),
            'age': _ageController.text.trim(),
            'contactNo': _contactNoController.text.trim(),
            'username': _usernameController.text.trim(),
            'emailAddress': _emailController.text.trim(),
          },
        );

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Welcome.')),
        );

        // Navigate to Home screen replacing the authentication stack
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      String errorMessage = e.toString();
      if (errorMessage.contains('email-already-in-use')) {
        errorMessage = 'This email address is already registered.';
      } else if (errorMessage.contains('weak-password')) {
        errorMessage = 'Password is too weak. Please use at least 6 characters.';
      } else if (errorMessage.contains('invalid-email')) {
        errorMessage = 'Please enter a valid email address.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed: $errorMessage'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Helper method creating consistent decorated input fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        prefixIcon: Icon(prefixIcon, size: 20.sp),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator ??
          (value) => (value == null || value.trim().isEmpty) ? '$label is required' : null,
    );
  }

  // Builds and returns the sign up screen layout
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: const CustomText(
          text: 'Create Account',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomText(
                      text: 'Join Us Today',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text: 'Fill in the details below to register',
                      fontSize: 13.sp,
                      textAlign: TextAlign.center,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(height: 24.h),

                    // First Name & Last Name row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _fNameController,
                            label: 'First Name',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _lNameController,
                            label: 'Last Name',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Age & Contact Number row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            prefixIcon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Required';
                              final int? age = int.tryParse(value);
                              if (age == null || age <= 0) return 'Invalid age';
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: _contactNoController,
                            label: 'Contact No',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Username
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      prefixIcon: Icons.account_circle_outlined,
                    ),
                    SizedBox(height: 14.h),

                    // Email Address
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),

                    // Password
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),

                    // Confirm Password
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      prefixIcon: Icons.lock_reset_outlined,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Sign Up Submit Button
                    SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Navigate to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'Already have an account? ',
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: CustomText(
                            text: 'Sign In',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
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
}
