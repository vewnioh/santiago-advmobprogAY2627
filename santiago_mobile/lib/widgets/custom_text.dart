// Import Flutter material library for UI widget styling and themes
import 'package:flutter/material.dart';

// Custom reusable text widget that standardizes typography across the entire application
class CustomText extends StatelessWidget {
  // Constructor initializing typography properties with sensible default values
  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 12,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.letterSpacing = 0,
    this.fontStyle = FontStyle.normal,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontFamily = 'Poppins',
  });

  // String content to be rendered on screen
  final String text;

  // Font size and character letter spacing configuration
  final double fontSize, letterSpacing;

  // Optional maximum lines limit before truncating text
  final int? maxLines;

  // Optional overflow behavior when text exceeds maximum lines
  final TextOverflow? overflow;

  // Font weight specifying light, normal, or bold styling
  final FontWeight fontWeight;

  // Horizontal text alignment within its container
  final TextAlign textAlign;

  // Target font family name defaulting to Poppins
  final String fontFamily;

  // Font style indicating normal or italic text
  final FontStyle fontStyle;

  // Optional custom text color overriding default theme color
  final Color? color;

  // Builds and returns styled Text widget based on configured parameters
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}
