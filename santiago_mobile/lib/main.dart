/*
  Ephemeral vs. App State Discussion & Activity
  ----------------------------------------------
  What is State Management in Flutter?
  State management refers to how an application manages, passes, and updates data (state) 
  across widgets and screens in response to user actions or system events.

  Difference Between Ephemeral State and App State:
  1. Ephemeral (Local) State:
     - Short-lived state that only affects a single widget or localized screen.
     - Managed locally within a StatefulWidget using `setState()`.
     - Resets when the widget is rebuilt or when switching screens.
     - Example: The counter value on CounterScreen resets to 0 when returning from Settings Screen.

  2. App State:
     - Long-lived state that affects the entire application across multiple screens.
     - Managed globally using Provider (`ChangeNotifier`, `ChangeNotifierProvider`).
     - Persists across screen navigation, notifying listening widgets when changes occur.
     - Example: Dark/Light mode theme preferences configured in SettingsScreen via SwitchListTile.
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

// Global App State for Theme Management
class ThemeModel with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

// Root Widget of the Application with smooth theme animation duration and curve
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          return MaterialApp(
            title: 'Ephemeral vs App State',
            debugShowCheckedModeBanner: false,
            // Smooth theme transition animation setup
            themeAnimationDuration: const Duration(milliseconds: 300),
            themeAnimationCurve: Curves.easeInOut,
            themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorSchemeSeed: Colors.deepPurple,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorSchemeSeed: Colors.deepPurple,
            ),
            home: const CounterScreen(),
          );
        },
      ),
    );
  }
}

// Screen 1: Counter Screen (Ephemeral State)
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  // Ephemeral local state variable
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ).then((_) {
      // Resets counter to 0 every time you return to this screen from Settings
      if (mounted) {
        setState(() {
          _counter = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Screen'),
        actions: [
          // Settings icon button in the upper right corner
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Screen 2: Settings Screen (App State with Dividers & Performance Optimization)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Optimizing rebuilds using context.select for specific value listening
    final isDark = context.select<ThemeModel, bool>((model) => model.isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'APPEARANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
          ),
          const Divider(height: 1),
          // Dark Mode Switch Tile enclosed in dividers
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme across the application'),
            value: isDark,
            onChanged: (_) => context.read<ThemeModel>().toggleTheme(),
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
