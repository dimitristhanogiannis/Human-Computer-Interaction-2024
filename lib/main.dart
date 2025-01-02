import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camconnect/notification_service.dart';
import 'package:camconnect/login.dart';
import 'package:camconnect/swipes.dart';
import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/matches.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    
    final notificationService = NotificationService(navigatorKey: navigatorKey);
    await notificationService.initialize();
    
    runApp(const MyApp());
  } catch (e) {
    print("Error during initialization: $e");
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: 'CamConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/swipes', page: () => SwipePage()),
        GetPage(name: '/matches', page: () => MatchesScreen()),
        GetPage(name: '/leaderboard', page: () => LeaderboardScreen()),
      ],
    );
  }
}