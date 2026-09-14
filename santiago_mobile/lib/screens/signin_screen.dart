// Enhancement 2: Dual Sign-in screen supporting both DummyJSON API and Firebase Auth
import 'package:flutter/material.dart';

// Import ScreenUtil package for responsive screen dimensions and font scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import UserService to authenticate against API/Firebase and persist session
import '../services/user_service.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Screen collecting credentials and authenticating the user via DummyJSON API or Firebase Auth
class SigninScreen extends StatefulWidget {
  // Constructor initializing SigninScreen widget
  const SigninScreen({super.key});

  // Creates mutable state instance for SigninScreen widget
  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

// State class managing the sign-in form, login type selection, and authentication requests
class _SigninScreenState extends State<SigninScreen> {
  // Key used to validate the sign-in form fields
  final _formKey = GlobalKey<FormState>();

  // Tracks authentication provider mode: true for Firebase Auth (Email), false for DummyJSON (Username)
  bool _isFirebaseLogin = true;

  // Text controllers pre-filled with demo credentials
  final TextEditingController _identifierController =
      TextEditingController(text: '');
  final TextEditingController _passwordController =
      TextEditingController(text: '');

  // Toggles password field visibility
  bool _obscurePassword = true;

  // Tracks whether a login request is currently in flight
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateDefaultCredentials();
  }

  void _updateDefaultCredentials() {
    if (_isFirebaseLogin) {
      _identifierController.text = '';
      _passwordController.text = '';
    } else {
      _identifierController.text = 'emilys';
      _passwordController.text = 'emilyspass';
    }
  }

  // Lifecycle method disposing text controllers to release system resources
  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handles login attempt depending on selected mode (Firebase vs DummyJSON)
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final UserService userService = UserService();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFirebaseLogin) {
        // Authenticate via Firebase Auth SDK
        await userService.signIn(
          email: _identifierController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Firebase Sign In Successful!')),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Authenticate via DummyJSON REST API
        final response = await userService.loginUser(
          _identifierController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DummyJSON API Sign In Successful!')),
        );

        Navigator.pushReplacementNamed(context, '/home', arguments: response);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      String errorMessage = e.toString();
      if (errorMessage.contains('user-not-found') || errorMessage.contains('invalid-credential')) {
        errorMessage = 'Invalid email or password.';
      } else if (errorMessage.contains('wrong-password')) {
        errorMessage = 'Incorrect password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $errorMessage'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Builds and returns the sign-in form layout
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
                    // App logo
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
                      text: 'Welcome Back',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text: 'Sign in to continue to your account',
                      fontSize: 13.sp,
                      textAlign: TextAlign.center,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(height: 20.h),

                    // Enhancement 2: Authentication Mode Toggle Segment (Firebase Auth vs DummyJSON)
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!_isFirebaseLogin) {
                                  setState(() {
                                    _isFirebaseLogin = true;
                                    _updateDefaultCredentials();
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: _isFirebaseLogin
                                      ? primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: CustomText(
                                  text: 'Firebase Auth',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  textAlign: TextAlign.center,
                                  color: _isFirebaseLogin ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_isFirebaseLogin) {
                                  setState(() {
                                    _isFirebaseLogin = false;
                                    _updateDefaultCredentials();
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: !_isFirebaseLogin
                                      ? primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: CustomText(
                                  text: 'DummyJSON API',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  textAlign: TextAlign.center,
                                  color: !_isFirebaseLogin ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Dynamic Identifier Field (Email for Firebase, Username for DummyJSON)
                    TextFormField(
                      controller: _identifierController,
                      keyboardType: _isFirebaseLogin
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: _isFirebaseLogin ? 'Email Address' : 'Username',
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                        prefixIcon: Icon(
                          _isFirebaseLogin ? Icons.email_outlined : Icons.person_outline,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _isFirebaseLogin ? 'Email is required' : 'Username is required';
                        }
                        if (_isFirebaseLogin &&
                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Password input field
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

                    // Log In submit button
                    SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
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
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isFirebaseLogin ? 'Sign In with Firebase' : 'Sign In with DummyJSON',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Enhancement 2: Sign Up link redirecting to signup_screen
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: "Don't have an account? ",
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: CustomText(
                            text: 'Sign Up',
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
