import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool useLocation = true;
  String sexPreference = "Female";
  String username = "DefaultUsername";
  String bio = "This is my bio";
  String age = "25";
  String _sex = 'Male';
  String _preference = 'Female';
  String _location = 'Location not selected';

  // Function to get location
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
    });
  }

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
                      if (useLocation) _getLocation();
                    });
                  },
                ),
                _SettingsOption(
                  title: 'Sex: $_sex',
                  onTap: () async {
                    await _showDropdown(context, 'Sex', ['Male', 'Female', 'Other'], (value) {
                      setState(() => _sex = value);
                    });
                  },
                ),
                _SettingsOption(
                  title: 'Preference: $_preference',
                  onTap: () async {
                    await _showDropdown(context, 'Preference', ['Male', 'Female', 'Both'], (value) {
                      setState(() => _preference = value);
                    });
                  },
                ),
                _SettingsOption(
                  title: 'Change Profile Picture',
                  onTap: () {
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
                    print('Change Password');
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      print('Logged out');
                      Navigator.pushReplacementNamed(context, '/login');
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
            Navigator.pushReplacementNamed(context, '/swipes');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/matches');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/leaderboard');
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

  Future<void> _showDropdown(
    BuildContext context,
    String title,
    List<String> options,
    ValueChanged<String> onSelected,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(title),
          children: options
              .map((option) => SimpleDialogOption(
                    onPressed: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },
                    child: Text(option),
                  ))
              .toList(),
        );
      },
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
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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

  const _SettingsOption({required this.title, required this.onTap});

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
