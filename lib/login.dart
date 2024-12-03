import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';
import 'register.dart';  // Import the Register Screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CamConnect Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon at the top
              Icon(
                Icons.video_call,
                size: 100,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),

              // Username text field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),

              // Password text field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),

              // Login button
              ElevatedButton(
                onPressed: () {
                   // Navigate to SwipeScreen (replace with your swipe page widget)
                   Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => SwipePage()), // Replace SwipeScreen with your actual widget name
                   );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full-width button
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.deepPurple,
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),

              // Sign-up button that navigates to Register Screen
              TextButton(
                onPressed: () {
                  // Navigate to SignUp Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()), // Navigate to Register Screen
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
