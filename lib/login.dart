import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';
import 'register.dart';

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
    await Future.delayed(Duration(seconds: 0));  // Simulate a delay

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
    const Color lightGray = Color(0xFFE0E0E0);
    const Color deepPurple = Color(0xFF7B1FA2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 160.0, // Increased significantly
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0), // Further adjustment
              child: Center(
                child: Text(
                  'CamConnect',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 120), // Huge gap to push fields down
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username', // Back to labelText
                        border: OutlineInputBorder( // Back to OutlineInputBorder
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: lightGray,
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password', // Back to labelText
                        border: OutlineInputBorder( // Back to OutlineInputBorder
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: lightGray,
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Login', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}