import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool useLocation = true;
  String username = "DefaultUsername";
  String bio = "This is my bio";
  String age = "Select your age";
  String _sex = 'Change your sex';
  String _preference = 'Change your preference';
  String _location = 'Location: Enabled';
  File? _profilePicture;
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          username = data['username'] ?? username;
          bio = data['bio'] ?? bio;
          age = data['age'] ?? age;
          _sex = data['sex'] ?? _sex;
          _preference = data['preference'] ?? _preference;
          _profilePhotoUrl = data['profilePhoto'];
          useLocation = data['useLocation'] ?? true;
          _location = useLocation ? 'Location: Enabled' : 'Location: Disabled';
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _updateUserInfo(String field, dynamic value) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userDoc.update({field: value});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$field updated successfully!'),
      ));
    } catch (e) {
      print('Error updating $field: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating $field: $e'),
      ));
    }
  }

  Future<void> _uploadProfilePicture(File file) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_photos/$userId.jpg');

      await storageRef.putFile(file);

      final downloadUrl = await storageRef.getDownloadURL();
      await _updateUserInfo('profilePhoto', downloadUrl);

      setState(() {
        _profilePhotoUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile photo uploaded successfully!'),
      ));
    } catch (e) {
      print('Error uploading profile photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading profile photo: $e'),
      ));
    }
  }

  Future<void> _getLocation() async {
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

      _updateUserLocation(true, position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error retrieving location: $e'),
      ));
      print("Error retrieving location: $e");
    }
  }

  Future<void> _updateUserLocation(
      bool useLocation, double latitude, double longitude) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      String latDirection = latitude >= 0 ? 'N' : 'S';
      String lonDirection = longitude >= 0 ? 'E' : 'W';

      await userDoc.update({
        'useLocation': useLocation,
        'location': useLocation
            ? '[$latitude° $latDirection, $longitude° $lonDirection]'
            : FieldValue.delete(),
      });

      if (mounted) {
        setState(() {
          _location = useLocation ? 'Location: Enabled' : 'Location: Disabled';
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(useLocation
            ? 'Location enabled and saved.'
            : 'Location disabled.'),
      ));
    } catch (e) {
      print('Error updating location: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating location: $e'),
      ));
    }
  }

  Future<void> _toggleLocation(bool value) async {
    setState(() {
      useLocation = value;
      _location = value ? 'Location: Enabled' : 'Location: Disabled';
    });

    if (value) {
      await _getLocation();
    } else {
      await _updateUserLocation(false, 0.0, 0.0);
    }

    await _updateUserInfo('useLocation', value);
  }

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

        await _uploadProfilePicture(_profilePicture!);
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
    const Color deepPurple = Color(0xFF7B1FA2);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
              fontSize: 30, color: deepPurple, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pop(context);
          },
          color: deepPurple,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicture != null
                    ? FileImage(_profilePicture!)
                    : (_profilePhotoUrl != null
                        ? NetworkImage(_profilePhotoUrl!)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider),
                child: _profilePicture == null
                    ? const Icon(Icons.camera_alt,
                        size: 50, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _SettingsOption(
                  title: _location,
                  trailing: Switch(
                    value: useLocation,
                    onChanged: _toggleLocation,
                    activeColor: deepPurple,
                  ),
                ),
                _SettingsOption(
                  title: 'Sex: $_sex',
                  onTap: () async {
                    await _showDropdown(
                        context, 'Sex', ['Male', 'Female', 'Other'], (value) {
                      setState(() => _sex = value);
                      _updateUserInfo('sex', value);
                    });
                  },
                ),
                _SettingsOption(
                  title: 'Preference: $_preference',
                  onTap: () async {
                    await _showDropdown(
                        context, 'Preference', ['Male', 'Female', 'Both'],
                        (value) {
                      setState(() => _preference = value);
                      _updateUserInfo('preference', value);
                    });
                  },
                ),
                _SettingsOption(
                  title: 'Age: $age',
                  onTap: () async {
                    String? result =
                        await _showInputDialog(context, 'Change Age', age);
                    if (result != null) {
                      setState(() {
                        age = result;
                      });
                      await _updateUserInfo('age', result);
                    }
                  },
                ),
                _SettingsOption(
                  title: 'Username: $username',
                  onTap: () async {
                    String? result = await _showInputDialog(
                        context, 'Change Username', username);
                    if (result != null) {
                      setState(() {
                        username = result;
                      });
                      await _updateUserInfo('username', result);
                    }
                  },
                ),
                _SettingsOption(
                  title: 'Bio: $bio',
                  onTap: () async {
                    String? result =
                        await _showInputDialog(context, 'Change Bio', bio);
                    if (result != null) {
                      setState(() {
                        bio = result;
                      });
                      await _updateUserInfo('bio', result);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut().then((_) {
                        if (!mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      }).catchError((error) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error logging out: $error'),
                        ));
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                    ),
                    child: const Text('Logout',
                        style: TextStyle(color: Colors.white)),
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

  Future<String?> _showInputDialog(
      BuildContext context, String title, String initialValue) {
    TextEditingController controller =
        TextEditingController(text: initialValue);
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
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsOption({
    required this.title,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
      trailing: trailing,
    );
  }
}