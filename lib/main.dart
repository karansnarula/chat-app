import 'package:chat_app/core/constants/app_colors.dart';
import 'package:chat_app/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}

/// Root widget. Placeholder shell until the router, theme, and DI wiring
/// land in the core-infrastructure phase.
class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const Scaffold(
        body: Center(child: Text(AppStrings.appName)),
      ),
    );
  }
}
