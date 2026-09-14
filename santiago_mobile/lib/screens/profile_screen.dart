// Enhancement 3: Profile screen rendering user details, login type, and account management actions
import 'package:flutter/material.dart';

// Import ScreenUtil package for responsive screen dimensions and font scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import User model for data typing and structure
import '../models/user.dart' as app_user;

// Import UserService to read saved session, update profile, and execute logout/account deletion
import '../services/user_service.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Callback invoked once the user logs out, letting the parent handle navigation
typedef VoidAsyncCallback = void Function();

// Screen rendering the currently logged-in user's profile data and management options
class ProfileScreen extends StatefulWidget {
  // Callback fired after session has been cleared, letting caller navigate to sign-in
  final VoidAsyncCallback onLoggedOut;

  // Constructor initializing ProfileScreen widget
  const ProfileScreen({super.key, required this.onLoggedOut});

  // Creates mutable state instance for ProfileScreen widget
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// State class managing profile data fetching, dialog interactions, and Firebase account actions
class _ProfileScreenState extends State<ProfileScreen> {
  // Service instance used to manage session and Firebase authentication
  final UserService _userService = UserService();

  // Future holding async profile read operation
  late Future<Map<String, dynamic>> _userDataFuture;

  // Lifecycle method initializing profile fetch
  @override
  void initState() {
    super.initState();
    _refreshUserData();
  }

  void _refreshUserData() {
    setState(() {
      _userDataFuture = _userService.getUserData();
    });
  }

  // Enhancement 1 & 3: Logs out user and triggers parent navigation
  Future<void> _logout() async {
    await _userService.signOut();
    if (!mounted) return;
    widget.onLoggedOut();
  }

  // Enhancement 3: Dialog prompting user to update their display username
  void _showUpdateUsernameDialog(String currentUsername) {
    final TextEditingController usernameController =
        TextEditingController(text: currentUsername);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Username'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'New Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Username required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _userService.updateUsername(
                    username: usernameController.text.trim(),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _refreshUserData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username updated successfully!')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Enhancement 3: Dialog prompting user for current and new password to change password
  void _showChangePasswordDialog(String email) {
    final TextEditingController currentPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val.length < 6) return 'At least 6 characters';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _userService.resetPasswordFromCurrentPassword(
                    currentPassword: currentPassController.text,
                    newPassword: newPassController.text,
                    email: email,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully!')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password change failed: ${e.toString()}'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Enhancement 3: Dialog confirming account deletion with password verification
  void _showDeleteAccountDialog(String email) {
    final TextEditingController passController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 16.h),
            Form(
              key: formKey,
              child: TextFormField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter Password to Confirm',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Password required' : null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _userService.deleteAccount(
                    email: email,
                    password: passController.text,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  widget.onLoggedOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account permanently deleted.')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Delete failed: ${e.toString()}'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Helper widget building info rows
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

  // Builds and returns profile layout
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final Map<String, dynamic> data = snapshot.data ?? {};
          final app_user.User user = app_user.User.fromJson(data);
          final String loginType = data['loginType'] ?? 'dummyjson';
          final bool isFirebase = loginType == 'firebase' || _userService.currentUser != null;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),

                // Avatar image with fallback icon
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

                // Full Name
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
                  color: primaryColor,
                ),
                SizedBox(height: 12.h),

                // Enhancement 2 & 3: Login Type Badge Indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isFirebase
                        ? Colors.deepPurple.withValues(alpha: 0.12)
                        : Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isFirebase ? Colors.deepPurple : Colors.blue,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFirebase ? Icons.local_fire_department : Icons.api,
                        size: 16.sp,
                        color: isFirebase ? Colors.deepPurple : Colors.blue,
                      ),
                      SizedBox(width: 6.w),
                      CustomText(
                        text: isFirebase
                            ? 'Login Type: Firebase Auth'
                            : 'Login Type: DummyJSON API',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isFirebase ? Colors.deepPurple : Colors.blue,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // User details card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    child: Column(
                      children: [
                        _infoRow(Icons.email_outlined, 'Email', user.email.isNotEmpty ? user.email : 'N/A'),
                        const Divider(height: 1),
                        _infoRow(Icons.wc_outlined, 'Gender', user.gender.isNotEmpty ? user.gender : 'N/A'),
                        const Divider(height: 1),
                        _infoRow(
                          Icons.badge_outlined,
                          'User ID',
                          user.id > 0 ? '#${user.id}' : (user.accessToken.isNotEmpty ? user.accessToken.substring(0, 8) : 'N/A'),
                        ),
                        if (data['contactNo'] != null && data['contactNo'].toString().isNotEmpty) ...[
                          const Divider(height: 1),
                          _infoRow(Icons.phone_outlined, 'Contact', data['contactNo'].toString()),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Enhancement 3: Account management buttons for Firebase Auth users
                if (isFirebase) ...[
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit_outlined, color: primaryColor),
                          title: const Text('Update Username', style: TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showUpdateUsernameDialog(user.username),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.lock_reset_outlined, color: primaryColor),
                          title: const Text('Change Password', style: TextStyle(fontSize: 14)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showChangePasswordDialog(user.email),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
                          title: const Text(
                            'Delete Account',
                            style: TextStyle(fontSize: 14, color: Colors.redAccent),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                          onTap: () => _showDeleteAccountDialog(user.email),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // Log Out button
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
