import 'package:flutter/material.dart';
import 'config/theam_data.dart';
import 'config/route.dart';
import 'constants/app_constants.dart';
import 'data/app_data.dart';

void main() {
  // Initialize sample data for development
  AppData.initializeSampleData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
      initialRoute: AppConstants.splashRoute,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
