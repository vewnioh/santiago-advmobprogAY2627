// Enhancement 2: Sign-in screen implementing UserService and the login/authentication logic
import 'package:flutter/material.dart';

// Import ScreenUtil package for responsive screen dimensions and font scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import UserService to authenticate against the API and persist the session
import '../services/user_service.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Screen collecting credentials and authenticating the user against the API
class SigninScreen extends StatefulWidget {
  // Constructor initializing SigninScreen widget
  const SigninScreen({super.key});

  // Creates mutable state instance for SigninScreen widget
  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

// State class managing the sign-in form, validation, and login request
class _SigninScreenState extends State<SigninScreen> {
  // Key used to validate the sign-in form fields
  final _formKey = GlobalKey<FormState>();

  // Text controllers pre-filled with a known DummyJSON demo account for convenience
  final TextEditingController _usernameController =
      TextEditingController(text: 'emilys');
  final TextEditingController _passwordController =
      TextEditingController(text: 'emilyspass');

  // Toggles password field visibility
  bool _obscurePassword = true;

  // Tracks whether a login request is currently in flight
  bool _isLoading = false;

  // Lifecycle method disposing text controllers to release system resources
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Enhancement 2: Validates the form, calls UserService.loginUser, persists the session, then navigates home
  void _login() async {
    UserService userService = UserService();
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        final response = await userService.loginUser(
          _usernameController.text,
          _passwordController.text,
        );

        // Save user data to SharedPreferences
        await userService.saveUserData(response);

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacementNamed(context, '/home', arguments: response);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Builds and returns the sign-in form layout
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Light neutral backdrop so the white form card stands out
      backgroundColor: isDark ? Colors.black : const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
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
                    // App logo above the welcome heading
                    Image.asset(
                      'assets/images/nubdexchange_logo.png',
                      height: 56.h,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.shopping_bag,
                        size: 44.sp,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const CustomText(
                      text: 'Welcome',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text: 'Sign in to continue',
                      fontSize: 13.sp,
                      textAlign: TextAlign.center,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(height: 28.h),
                    // Username input field with a required-field validator
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Username is required'
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    // Password input field with visibility toggle and a required-field validator
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Password is required'
                          : null,
                    ),
                    SizedBox(height: 28.h),
                    // Submit button showing a spinner while the login request is in flight
                    SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
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
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Log In',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
}
