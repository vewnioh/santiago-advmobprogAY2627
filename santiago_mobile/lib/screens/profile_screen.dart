// Enhancement 3: Profile screen rendering the saved User model's data
import 'package:flutter/material.dart';

// Import ScreenUtil package for responsive screen dimensions and font scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import User model for data typing and structure
import '../models/user.dart';

// Import UserService to read the saved session and perform logout
import '../services/user_service.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Callback invoked once the user logs out, letting the parent handle navigation
typedef VoidAsyncCallback = void Function();

// Screen rendering the currently logged-in user's saved profile data
class ProfileScreen extends StatefulWidget {
  // Callback fired after SharedPreferences has been cleared, so the caller can navigate to sign-in
  final VoidAsyncCallback onLoggedOut;

  // Constructor initializing ProfileScreen widget
  const ProfileScreen({super.key, required this.onLoggedOut});

  // Creates mutable state instance for ProfileScreen widget
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// State class managing async user loading and logout handling
class _ProfileScreenState extends State<ProfileScreen> {
  // Service instance used to read and clear the saved session
  final UserService _userService = UserService();

  // Future variable holding the asynchronous saved-user read operation
  late Future<User> _userFuture;

  // Lifecycle method initializing the saved user fetch when widget enters tree
  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUser();
  }

  // Enhancement 3: Clears the saved session and hands control back to the caller to navigate away
  Future<void> _logout() async {
    await _userService.logout();
    if (!mounted) return;
    widget.onLoggedOut();
  }

  // Builds a single labeled row displaying one piece of saved user data
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
          SizedBox(width: 12.w),
          CustomText(text: label, fontSize: 13.sp, fontWeight: FontWeight.w600),
          const Spacer(),
          Flexible(
            child: CustomText(
              text: value,
              fontSize: 13.sp,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Builds and returns the async FutureBuilder resolving saved-user connection states
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          // Renders centered loading spinner while reading from SharedPreferences
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final User? user = snapshot.data;

          // Renders error/empty state if no saved user data was found
          if (snapshot.hasError || user == null || user.username.isEmpty) {
            return Center(
              child: CustomText(
                text: 'No profile data found.',
                fontSize: 14.sp,
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                // Circular avatar image with a fallback person icon
                CircleAvatar(
                  radius: 48.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      user.image.isNotEmpty ? NetworkImage(user.image) : null,
                  child: user.image.isEmpty
                      ? Icon(Icons.person, size: 48.sp, color: Colors.grey)
                      : null,
                ),
                SizedBox(height: 14.h),
                // Full name heading
                CustomText(
                  text: user.fullName.isNotEmpty ? user.fullName : user.username,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 2.h),
                // Username handle
                CustomText(
                  text: '@${user.username}',
                  fontSize: 13.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 24.h),
                // Card containing the saved user's details
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    child: Column(
                      children: [
                        _infoRow(Icons.email_outlined, 'Email', user.email),
                        const Divider(height: 1),
                        _infoRow(Icons.wc_outlined, 'Gender', user.gender),
                        const Divider(height: 1),
                        _infoRow(Icons.badge_outlined, 'User ID', '#${user.id}'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Log Out button clearing the saved session
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
