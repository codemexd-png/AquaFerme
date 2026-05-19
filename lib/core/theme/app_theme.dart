import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs extraites de la maquette
  static const Color aquaBlueHeader = Color(0xFF004AAD); // Le bleu foncé du haut
  static const Color bgLight = Color(0xFFF4F6F9);        // Le fond gris très clair
  static const Color surfaceWhite = Color(0xFFFFFFFF);    // Le blanc des cartes
  static const Color textDark = Color(0xFF1A1A1A);       // Le texte principal
  static const Color textGrey = Color(0xFF666666);       // Le texte secondaire
  static const Color alertRedBg = Color(0xFFFFEBEB);     // Fond du bandeau "Hors site"
  static const Color alertRedText = Color(0xFFD32F2F);   // Texte du bandeau "Hors site"

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: aquaBlueHeader,
      
      colorScheme: const ColorScheme.light(
        primary: aquaBlueHeader,
        background: bgLight,
        surface: surfaceWhite,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
        bodyLarge: TextStyle(fontSize: 16, color: textDark, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14, color: textGrey),
      ),

      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0, // Les cartes de la maquette ont plutôt des bordures fines ou des ombres très légères
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1), // Bordure légère style Figma
        ),
      ),
    );
  }
}