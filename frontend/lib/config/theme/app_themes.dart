import 'package:flutter/material.dart';

ThemeData theme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.black,
    primary: Colors.black,
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Muli',
    appBarTheme: appBarTheme(),
    textTheme: appTextTheme(colorScheme),
    colorScheme: colorScheme,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: snackBarTheme(),
  );
}

TextTheme appTextTheme(ColorScheme colorScheme) {
  return const TextTheme(
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.25,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.45,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.35,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      height: 1.35,
    ),
    labelLarge: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ).apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    surfaceTintColor: Colors.white,
    elevation: 8,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
        color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
  );
}

SnackBarThemeData snackBarTheme() {
  return const SnackBarThemeData(
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
    ),
  );
}
