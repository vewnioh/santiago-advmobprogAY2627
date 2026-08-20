// Import Flutter core material design package
import 'package:flutter/material.dart';

// Import services package for configuring platform orientation preferences
import 'package:flutter/services.dart';

// Import dotenv package to load environment variables from assets/.env
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import ScreenUtil package for responsive screen design scaling
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import Provider package for application-wide state management
import 'package:provider/provider.dart';

// Import HomeScreen component widget
import 'screens/home_screen.dart';

// Import SettingsScreen component widget
import 'screens/settings_screen.dart';

// Enhancement 1: Import SplashScreen, the new initial route implementing persistent authentication
import 'screens/splash_screen.dart';

// Enhancement 2: Import SigninScreen, shown when no session is saved
import 'screens/signin_screen.dart';

// Import ThemeProvider state manager class
import 'providers/theme_provider.dart';

// Asynchronous main entry point function executing app initialization logic
void main() async {
  // Ensures Flutter widget binding engine is initialized before running async tasks
  WidgetsFlutterBinding.ensureInitialized();

  // Locks device screen orientation strictly to portrait orientation mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) async {
      // Loads environment configuration variables asynchronously from assets/.env file
      await dotenv.load(fileName: 'assets/.env');

      // Launches the root application widget tree
      runApp(const SantiagoMobile());
    },
  );
}

// Root application widget configuring providers, screen utilities, and navigation routes
class SantiagoMobile extends StatelessWidget {
  // Constructor initializing SantiagoMobile root widget
  const SantiagoMobile({super.key});

  // Builds and returns MaterialApp widget tree wrapped with ThemeProvider and ScreenUtilInit
  @override
  Widget build(BuildContext context) {
    // Provides ThemeProvider instance globally to all descendant widgets in the tree
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      // Initializes ScreenUtil for responsive UI dimension scaling based on design size
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (build, child) {
          // Watches ThemeProvider state changes reactively to rebuild MaterialApp theme
          final themeModel = build.watch<ThemeProvider>();

          // Configures MaterialApp with dynamic light/dark themes and named routes
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeModel.lightTheme,
            darkTheme: themeModel.darkTheme,
            themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
            title: 'E-Commerce App',
            // Enhancement 1: App now boots into SplashScreen, which decides between /home and /signin
            initialRoute: '/splash',
            // Table of named application navigation routes mapped to screen widgets
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/signin': (context) => const SigninScreen(),
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
