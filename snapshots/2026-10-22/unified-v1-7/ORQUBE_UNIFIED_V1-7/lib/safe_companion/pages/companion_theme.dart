import 'package:flutter/material.dart';
ThemeData companionLightTheme() => ThemeData(fontFamily: 'OrqubeHangul', 
  useMaterial3: true, brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF3F6F4),
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B53), brightness: Brightness.light),
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF3F6F4), foregroundColor: Color(0xFF183A30), elevation: 0),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Color(0xFF344B43), height: 1.6), bodySmall: TextStyle(color: Color(0xFF526B60), height: 1.5)),
  listTileTheme: const ListTileThemeData(textColor: Color(0xFF183A30), iconColor: Color(0xFF176B53), tileColor: Colors.white),
  dividerColor: const Color(0xFFDFE8E2),
);
