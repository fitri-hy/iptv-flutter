import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/http_override.dart';
import 'screens/home_screen.dart';
import 'themes/theme_manager.dart';
import 'themes/app_theme.dart';
import 'services/update_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  final themeManager = ThemeManager();
  await themeManager.loadTheme();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeManager,
      child: const IPTVApp(),
    ),
  );
}

class IPTVApp extends StatefulWidget {
  const IPTVApp({super.key});

  @override
  State<IPTVApp> createState() => _IPTVAppState();
}

class _IPTVAppState extends State<IPTVApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      title: 'IPTV',
      themeMode: themeManager.themeMode,
      theme: AppTheme.light(themeManager.accentColor),
      darkTheme: AppTheme.dark(themeManager.accentColor),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
