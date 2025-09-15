import 'package:draw_fun/features/profile/view/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'const/app_colors.dart';
import 'features/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');
  final initialUserId = userId ?? Random().nextInt(1000000).toString();
  runApp(DrawingGameApp(
      initialUserId: initialUserId, isRegistered: userId != null));
}

class DrawingGameApp extends StatelessWidget {
  final String initialUserId;
  final bool isRegistered;

  DrawingGameApp({required this.initialUserId, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kids Drawing Game',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor),
          bodyLarge: TextStyle(fontSize: 18, color: AppColors.textColor),
        ),
      ),
      initialRoute: isRegistered ? '/main' : '/profileSetup',
      getPages: [
        GetPage(name: '/profileSetup', page: () => ProfileSetupScreen()),
        GetPage(name: '/main', page: () => MainScreen(userId: initialUserId)),
      ],
      home: isRegistered
          ? MainScreen(userId: initialUserId)
          : ProfileSetupScreen(),
    );
  }
}
