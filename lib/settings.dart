import 'package:camconnect/leaderboard.dart';
import 'package:camconnect/login.dart';
import 'package:camconnect/matches.dart';
import 'package:camconnect/swipes.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool useLocation = true;
  String sexPreference = "Not set";
  String username = "DefaultUsername";
  String bio = "This is my bio";
  String age = "25";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                SwitchListTile(
                  title: const Text('Use my location'),
                  value: useLocation,
                  onChanged: (bool value) {
                    setState(() {
                      useLocation = value;
                    });
                  },
                ),
                _SettingsOption(
                  title: 'Sex Preference: $sexPreference',
                  onTap: () async {
                    String? result = await _showInputDialog(context, 'Sex Preference', sexPreference);
                    if (result != null) {
                      setState(() {
                        sexPreference = result;
                      });
                    }
                  },
                ),
                _SettingsOption(
                  title: 'Change Profile Picture',
                  onTap: () {
                    // Implement picture picker
                    print('Change Profile Picture');
                  },
                ),
                _SettingsOption(
                  title: 'Age: $age',
                  onTap: () async {
                    String? result = await _showInputDialog(context, 'Change Age', age);
                    if (result != null) {
                      setState(() {
                        age = result;
                      });
                    }
                  },
                ),
                _SettingsOption(
                  title: 'Username: $username',
                  onTap: () async {
                    String? result = await _showInputDialog(context, 'Change Username', username);
                    if (result != null) {
                      setState(() {
                        username = result;
                      });
                    }
                  },
                ),
                _SettingsOption(
                  title: 'Bio: $bio',
                  onTap: () async {
                    String? result = await _showInputDialog(context, 'Change Bio', bio);
                    if (result != null) {
                      setState(() {
                        bio = result;
                      });
                    }
                  },
                ),
                _SettingsOption(
                  title: 'Change Password',
                  onTap: () {
                    // Implement password change
                    print('Change Password');
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      print('Logged out');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SwipePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MatchesScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LeaderboardScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.swipe),
            label: 'Swipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }

  Future<String?> _showInputDialog(BuildContext context, String title, String initialValue) {
    TextEditingController controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new $title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingsOption({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}




