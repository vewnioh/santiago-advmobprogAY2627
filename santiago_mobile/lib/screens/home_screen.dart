// Import Flutter material framework widgets for layout and navigation
import 'package:flutter/material.dart';

// Import ScreenUtil package for responsive screen dimensions and font scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import ProductScreen displaying the grid of products
import 'product_screen.dart';

// Enhancement 1: Import CartScreen displaying the logged-in user's cart
import 'cart_screen.dart';

// Enhancement 3 (Lab 4): Import ProfileScreen rendering the saved user's data
import 'profile_screen.dart';

// Import CustomText widget for standardized typography formatting
import '../widgets/custom_text.dart';

// Import UserService to read the logged-in user's name for the AppBar title
import '../services/user_service.dart';

// Index of the Cart tab within the bottom navigation bar and PageView
const int _cartTabIndex = 1;

// Index of the Profile tab within the bottom navigation bar and PageView
const int _profileTabIndex = 2;

// Main container screen holding bottom navigation bar and page view tabs
class HomeScreen extends StatefulWidget {
  // Optional username parameter passed during navigation
  final String username;

  // Constructor initializing HomeScreen widget with key parameter
  const HomeScreen({super.key, this.username = ''});

  // Creates mutable state object for HomeScreen widget
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// State class managing tab selection and page view scrolling behavior
class _HomeScreenState extends State<HomeScreen> {
  // Index of currently active bottom navigation tab
  int _selectedIndex = 0;

  // Controller regulating PageView page switches programmatically
  final PageController _pageController = PageController();

  // Logged-in user's first name, used as the AppBar title on the Profile tab
  String _firstName = '';

  // Lifecycle method loading the saved user's first name when widget enters tree
  @override
  void initState() {
    super.initState();
    _loadFirstName();
  }

  // Enhancement 3 (Lab 4): Reads the saved session's first name from SharedPreferences
  Future<void> _loadFirstName() async {
    final userData = await UserService().getUserData();
    if (!mounted) return;
    setState(() {
      _firstName = userData['firstName'] ?? '';
    });
  }

  // Enhancement 1: Clears the saved session and returns to sign-in, removing the whole navigation stack
  void _handleLoggedOut() {
    Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
  }

  // Builds and returns top AppBar, PageView body, and BottomNavigationBar
  @override
  Widget build(BuildContext context) {
    // Prevents accidental back button pops from exiting the application root screen
    return PopScope(
      canPop: false,
      child: Scaffold(
        // Top application bar displaying dynamic title branding and action buttons
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          // Renders logo image for shop tab or text title for secondary tabs
          title: _selectedIndex == 0
              ? Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  scale: 11.sp,
                  errorBuilder: (context, error, stackTrace) => const CustomText(
                    text: 'E-Commerce App',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : CustomText(
                  // Enhancement 2: Chat tab removed from the bottom bar (now a FloatingActionButton), Cart takes its place
                  // Enhancement 3 (Lab 4): Profile tab shows the logged-in user's first name once loaded
                  text: _selectedIndex == _cartTabIndex
                      ? 'Cart'
                      : _selectedIndex == _profileTabIndex
                          ? (_firstName.isNotEmpty ? _firstName : 'Profile')
                          : 'Home',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
          // Action button array navigating user to Settings page
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        // Swipeable PageView displaying current tab screen content
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          // Updates active tab index state when page changes
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
          // Enhancement 1, 2 & 3: List of tab view screens (Shop, Cart, Profile) - Chat is now a FloatingActionButton instead of a tab
          children: [
            const ProductScreen(),
            const CartScreen(),
            ProfileScreen(onLoggedOut: _handleLoggedOut),
          ],
        ),
        // Bottom navigation bar displaying navigation icons and handling tab switches
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          // Enhancement 1 & 2: List of bottom navigation bar items (Shop, Cart, Profile) - Chat moved out to a FloatingActionButton
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shop_2),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onTappedBar,
        ),
        // Enhancement 2: Chat FloatingActionButton, hidden while the Cart tab is active
        floatingActionButton: _selectedIndex == _cartTabIndex
            ? null
            : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const _ChatPlaceholderScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.chat),
              ),
      ),
    );
  }

  // Callback function executed when user taps a bottom navigation bar item
  void _onTappedBar(int value) {
    // Updates selected tab index in local component state
    setState(() {
      _selectedIndex = value;
    });

    // Jumps PageView controller directly to the selected tab page
    _pageController.jumpToPage(value);
  }
}

// Enhancement 2: Placeholder screen opened by the Chat FloatingActionButton
class _ChatPlaceholderScreen extends StatelessWidget {
  // Constructor initializing the private chat placeholder widget
  const _ChatPlaceholderScreen();

  // Builds and returns a simple screen carrying over the previous Chat tab placeholder text
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Chat',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: const Center(
        child: CustomText(
          text: 'Chat Screen Placeholder',
          fontSize: 16,
        ),
      ),
    );
  }
}
