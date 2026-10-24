import 'package:flutter/material.dart';

ThemeData darkControlTheme() => ThemeData.dark(useMaterial3: true).copyWith(
  colorScheme: const ColorScheme.dark(primary: Color(0xff74dfca), onPrimary: Color(0xff071c19), secondary: Color(0xffb8a9ff), onSecondary: Color(0xff17102d), surface: Color(0xff15243d), onSurface: Colors.white),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.white, disabledForegroundColor: Colors.white54)),
  outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, disabledForegroundColor: Colors.white54, side: const BorderSide(color: Colors.white54))),
  filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: const Color(0xff74dfca), foregroundColor: const Color(0xff071c19), disabledForegroundColor: Colors.white54, disabledBackgroundColor: const Color(0xff28374a))),
  elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff74dfca), foregroundColor: const Color(0xff071c19), disabledForegroundColor: Colors.white54)),
  chipTheme: const ChipThemeData(labelStyle: TextStyle(color: Colors.white), secondaryLabelStyle: TextStyle(color: Colors.white), selectedColor: Color(0xff374d68), backgroundColor: Color(0xff202f45)),
);
