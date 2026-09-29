import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController = TextEditingController();
  final ChatService _chatService = ChatService();
  String? _currentUserEmail;
  String _searchText = '';

  // Created once so typing in the search bar does not resubscribe to Firestore (no loading flicker)
  late final Stream<List<Map<String, dynamic>>> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = _chatService.getUsersStream();
    _loadCurrentUserEmail();
  }

  // Enhancement 1 & 2: Removes the logged-in user, then keeps users whose name or email match the search text
  List<Map<String, dynamic>> _filterUsers(List<Map<String, dynamic>> allUsers) {
    // Enhancement 1: Exclude the current logged-in user from the list
    final String? currentUserId = userService.value.currentUser?.uid;
    final otherUsers = allUsers.where((user) => user['uid'] != currentUserId);

    // Enhancement 2: Match the search text against first name, last name, and email (case-insensitive)
    final String query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return otherUsers.toList();

    return otherUsers.where((user) {
      final String searchable = [
        user['firstName'],
        user['lastName'],
        user['email'],
      ].where((value) => value != null).join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  Future<void> _loadCurrentUserEmail() async {
    final userData = await userService.value.getUserData();
    setState(() {
      _currentUserEmail = userData['email'];
    });
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Opened from the HomeScreen FloatingActionButton, so the chat list gets its own Scaffold
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Chat',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.w),
              child: TextField(
                controller: _searchChatController,
                textInputAction: TextInputAction.search,
                // Enhancement 2: Filter the list on every keystroke
                onChanged: (value) => setState(() => _searchText = value),
                decoration: InputDecoration(
                  hintText: 'Search chat...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: (_searchChatController.text.isNotEmpty)
                      ? IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            setState(() {
                              _searchChatController.clear();
                              _searchText = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Users Stream
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: ScreenUtil().screenHeight * 0.6,
                    padding: EdgeInsets.all(16.sp),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    height: ScreenUtil().screenHeight * 0.6,
                    padding: EdgeInsets.all(16.sp),
                    child: Center(
                      child: CustomText(
                        text: 'Error loading users',
                        fontSize: 16.sp,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: ScreenUtil().screenHeight * 0.6,
                    padding: EdgeInsets.all(16.sp),
                    child: Center(
                      child: CustomText(
                        text: 'No users found',
                        fontSize: 16.sp,
                      ),
                    ),
                  );
                }

                // Enhancement 1 & 2: Everyone except the current user, narrowed by the search text
                final users = _filterUsers(snapshot.data!);

                if (users.isEmpty) {
                  return Container(
                    height: ScreenUtil().screenHeight * 0.6,
                    padding: EdgeInsets.all(16.sp),
                    child: Center(
                      child: CustomText(
                        text: _searchText.trim().isEmpty
                            ? 'No users found'
                            : 'No users match "${_searchText.trim()}"',
                        fontSize: 16.sp,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              currentUserEmail: _currentUserEmail!,
                              tappedUser: user,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: CustomText(
                              text:
                                  user['firstName'] != null &&
                                          user['firstName'].toString().isNotEmpty
                                      ? user['firstName'][0].toUpperCase()
                                      : '?',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          title: CustomText(
                            text: user['firstName'] ?? 'Unknown',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          subtitle: CustomText(
                            text: user['email'] ?? 'No email',
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
