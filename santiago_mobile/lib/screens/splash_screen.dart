// Enhancement 1: Splash screen implementing persistent authentication
import 'package:flutter/material.dart';

// Import ScreenUtil package for responsive screen dimensions and font scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import UserService to check whether a session is already saved on-device
import '../services/user_service.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Entry screen shown while the app decides whether to route to home or sign-in
class SplashScreen extends StatefulWidget {
  // Constructor initializing SplashScreen widget
  const SplashScreen({super.key});

  // Creates mutable state instance for SplashScreen widget
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// State class managing the authentication check performed on startup
class _SplashScreenState extends State<SplashScreen> {
  // Service instance used to check persisted login state
  final UserService _userService = UserService();

  // Lifecycle method kicking off the authentication check when widget enters tree
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // Enhancement 1: Checks SharedPreferences for a saved session and routes accordingly
  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final loggedIn = await _userService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      final userData = await _userService.getUserData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: userData,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  // Builds and returns a simple branded splash layout with a loading indicator
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Same light neutral background used on the sign-in screen, for visual consistency
      backgroundColor: isDark ? Colors.black : const Color(0xFFF3F4F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // White rounded container giving the logo a soft card-like backdrop
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/nubdexchange_logo.png',
                width: 90.w,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.shopping_bag,
                  size: 60.sp,
                  color: primaryColor,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            CustomText(
              text: 'NUBD Exchange',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            SizedBox(height: 6.h),
            CustomText(
              text: 'Your campus marketplace',
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
            SizedBox(height: 36.h),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
