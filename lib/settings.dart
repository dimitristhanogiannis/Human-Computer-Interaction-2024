import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _profilePicture;

  // Function to get location
  Future<void> _getLocation() async {
    print("Requesting location...");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enable location services'),
      ));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are denied'),
        ));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Permissions Permanently Denied'),
          content: const Text(
            'Please enable location permissions for this app in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
      setState(() {
        _location = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Location retrieved: $_location'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error retrieving location: $e'),
      ));
      print("Error retrieving location: $e");
    }
  }

  // Function to pick an image using image picker
  Future<void> _pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 500,
        maxWidth: 500,
        imageQuality: 80,
      );

      if (pickedImage != null) {
        setState(() {
          _profilePicture = File(pickedImage.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile picture updated successfully!'),
        ));
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error picking image: $e'),
      ));
    }
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
                // Profile Picture Display
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profilePicture != null
                          ? FileImage(_profilePicture!)
                          : const AssetImage('assets/default_avatar.png') as ImageProvider,
                      child: _profilePicture == null
                          ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Use my location'),
                  value: useLocation,
                  onChanged: (bool value) {
                    setState(() {
                      useLocation = value;
                      if (useLocation) {
                        _getLocation();
                      } else {
                        _location = 'Location not selected';
                        print('Location tracking disabled');
                      }
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
