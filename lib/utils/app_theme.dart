import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales
  static const Color primaryColor = Color(0xFF3D5CFF);
  static const Color secondaryColor = Color(0xFF00D9F5);
  static const Color accentColor = Color(0xFFFF3D6E);
  
  // Colores neutros
  static const Color darkColor = Color(0xFF1A1A2E);
  static const Color lightColor = Color(0xFFF5F5F7);
  static const Color greyColor = Color(0xFF8F8F8F);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFFFF9E3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Estilos de texto
  static TextStyle headingStyle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: darkColor,
    letterSpacing: 0.5,
  );
  
  static TextStyle subheadingStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: darkColor,
    letterSpacing: 0.3,
  );
  
  static TextStyle bodyStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: darkColor,
    letterSpacing: 0.2,
  );
  
  // Decoraciones
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: darkColor.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 5),
      ),
    ],
  );
  
  static BoxDecoration glassmorphismDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0.1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
  );
  
  // Tema de la aplicación
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: lightColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkColor),
      titleTextStyle: TextStyle(
        color: darkColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    ),
  );
}
