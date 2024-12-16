import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';
import 'register.dart'; // Import the Register Screen


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      // Handle error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    // Test username and password values (for testing purposes)
    // You can add more test cases as needed
    Map<String, String> validCredentials = {
      'testuser': 'password123',
      'admin': 'admin123',
      'user1': 'userpass1',
    };

    // Simulate login (replace this with actual login logic like API calls)
    await Future.delayed(Duration(seconds: 2));  // Simulate a delay

    // Check if entered username and password match valid credentials
    if (validCredentials.containsKey(username) && validCredentials[username] == password) {
    // If login is successful, navigate to the next page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SwipePage()), // Navigate to the actual screen
    );
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

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
                 onPressed: () async {
                   await _login();  // Call the asynchronous login function
                 },
                 style: ElevatedButton.styleFrom(
                   minimumSize: Size(double.infinity, 50), // Full-width button
                   padding: const EdgeInsets.symmetric(vertical: 16.0),
                   backgroundColor: Colors.deepPurple,
                   textStyle: TextStyle(fontSize: 16),
                 ),
                 child: const Text('Login', style: TextStyle(color: Colors.white)),
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
