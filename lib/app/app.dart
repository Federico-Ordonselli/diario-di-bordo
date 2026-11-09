import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/widgets.dart';
import 'router.dart';

class DiaryApp extends ConsumerWidget {
  const DiaryApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Diario di Bordo',
    debugShowCheckedModeBanner: false,
    routerConfig: ref.watch(routerProvider),
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.dark,
        primary: gold,
        surface: const Color(0xFF151E30),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1422),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      cardTheme: const CardThemeData(color: Color(0xFF151E30), elevation: 0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1422),
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF111A2A),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Color(0xFF111A2A),
      ),
    ),
  );
}
