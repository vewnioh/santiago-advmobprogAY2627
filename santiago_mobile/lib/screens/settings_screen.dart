// Enhancement 3: Added Settings Page for Theme Switcher
import 'package:flutter/material.dart';

// Import Provider package to listen to application-wide state changes
import 'package:provider/provider.dart';

// Import ThemeProvider class to read and update theme state
import '../providers/theme_provider.dart';

// Import CustomText widget for consistent typography styling
import '../widgets/custom_text.dart';

// Enhancement 3: Settings screen component housing application preferences and theme controls
class SettingsScreen extends StatelessWidget {
  // Constructor initializing SettingsScreen widget
  const SettingsScreen({super.key});

  // Builds and returns settings page view containing theme mode toggle switch
  @override
  Widget build(BuildContext context) {
    // Enhancement 3: Accesses ThemeProvider instance from widget tree context
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // Top app bar displaying 'Settings' screen title
      appBar: AppBar(
        title: const CustomText(
          text: 'Settings',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Padding wrapper containing preference category sections
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section heading label for appearance and theme preferences
            const CustomText(
              text: 'Appearance',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 12),
            // Enhancement 3: Interactive Card wrapping SwitchListTile for toggling dark/light mode
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                // Label text title for Dark Mode toggle item
                title: const CustomText(
                  text: 'Dark Mode',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                // Subtitle text indicating current active theme status
                subtitle: CustomText(
                  text: themeProvider.isDark
                      ? 'Dark theme is currently active'
                      : 'Light theme is currently active',
                  fontSize: 12,
                ),
                // Leading icon reflecting sun or moon based on active theme
                secondary: Icon(
                  themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: themeProvider.isDark ? Colors.amber : Colors.orange,
                ),
                // Boolean switch value matching ThemeProvider state
                value: themeProvider.isDark,
                // Callback function executed when user toggles the switch control
                onChanged: (bool value) {
                  // Enhancement 3: Triggers theme state inversion via ThemeProvider method
                  themeProvider.toggleTheme();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
