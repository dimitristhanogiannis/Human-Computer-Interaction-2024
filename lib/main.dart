import 'package:camconnect/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camconnect/swipes.dart';
import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/matches.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CamConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Initial route for your app
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/swipes', page: () => SwipePage()),
        GetPage(
            name: '/matches',
            page: () => MatchesScreen()), // Add MatchesScreen route
        GetPage(name: '/leaderboard', page: () => LeaderboardScreen()),
      ],
    );
  }
}
