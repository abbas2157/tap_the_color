import 'package:flutter/material.dart';
import 'package:tap_the_color/screens/home_screen.dart';
import 'package:tap_the_color/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap the Color',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2D1B3D), // Dark purple from the image
        scaffoldBackgroundColor: const Color(0xFF2D1B3D), // Dark purple background
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
            fontSize: 14.0,
          ),
        ),
        colorScheme: const ColorScheme.light().copyWith(
          brightness: Brightness.light,
          primary: const Color(0xFF9C27B0), // Accent purple
          secondary: const Color(0xFF9C27B0), // Accent purple
          surface: const Color(0xFF3D294F), // Lighter purple for cards
          background: const Color(0xFF2D1B3D), // Dark purple
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF3D294F), // Lighter purple for cards
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2D1B3D), // Dark purple from the image
        scaffoldBackgroundColor: const Color(0xFF201429), // Even darker purple for dark mode
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
            fontSize: 14.0,
          ),
        ),
        colorScheme: const ColorScheme.dark().copyWith(
          brightness: Brightness.dark,
          primary: const Color(0xFF9C27B0), // Accent purple
          secondary: const Color(0xFF9C27B0), // Accent purple
          surface: const Color(0xFF2D1B3D), // Dark purple for cards
          background: const Color(0xFF201429), // Even darker purple
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF2D1B3D), // Dark purple for cards
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
      themeMode: ThemeMode.system, // Default to system theme
      home: const SplashScreen(), // Start with the splash screen
    );
  }
}