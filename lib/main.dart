import 'package:flutter/material.dart';
import 'package:wanderscout/davin/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
Widget build(BuildContext context) {
  return Provider<CookieRequest>(
    create: (_) => CookieRequest(), // Initialize CookieRequest
    child: MaterialApp(
      title: 'Wanderscout',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1E3A8A), // Tailwind's bg-blue-900
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF1E3A8A), // bg-blue-900
          secondary: const Color(0xFF3B82F6), // Tailwind's bg-blue-500
        ),
      ),
      home: LoginPage(), // Replace with your login or home screen
    ),
  );
}

}
