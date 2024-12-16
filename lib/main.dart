import 'package:camconnect/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camconnect/swipes.dart'; // Import other screens as needed

void main() {
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
        // Define other pages here...
      ],
    );
  }
}
