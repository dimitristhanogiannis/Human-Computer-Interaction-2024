import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _sex = 'Male';
  String _preference = 'Female';
  String _location = 'Location not selected';
  String? _profilePhoto;
  bool useLocation = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePhoto = image.path;
      });
    }
  }

  Future<String?> _uploadProfilePhoto(String userId) async {
    if (_profilePhoto == null) return null;

    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_photos/$userId.jpg');
      await storageRef.putFile(File(_profilePhoto!));
      return await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading profile photo: $e')),
      );
      return null;
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
      setState(() {
        _location = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error retrieving location: $e'),
      ));
    }
  }

  Future<void> _registerUser() async {
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // Create user in Firebase Authentication
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Upload profile photo
      String? profilePhotoUrl =
          await _uploadProfilePhoto(userCredential.user!.uid);

      // Extract location if enabled
      GeoPoint? geoLocation;
      if (useLocation) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          geoLocation = GeoPoint(position.latitude, position.longitude);
        } catch (e) {
          print('Error retrieving location: $e');
        }
      }

      // Save user details in Firestore
      try {
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'bio': _bioController.text.trim(),
          'sex': _sex,
          'preference': _preference,
          'location': geoLocation ?? 'Location not provided',
          'profilePhoto': profilePhotoUrl,
          'useLocation': useLocation,
          'swipes': {
            'liked': [],
            'disliked': [],
          },
          'matches': [],
          'score': 0,
        });
        print('User added to Firestore successfully');
      } catch (e) {
        print('Error adding user to Firestore: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User registered successfully!'),
      ));

      // Navigate to another screen if needed
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.message}'),
      ));
    } catch (e) {
      print('Unknown error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color lightGray = Color(0xFFE0E0E0);
    const Color deepPurple = Color(0xFF7B1FA2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'CamConnect',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 120),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sex,
                      onChanged: (value) {
                        setState(() {
                          _sex = value!;
                        });
                      },
                      items: ['Male', 'Female', 'Other']
                          .map((sex) => DropdownMenuItem<String>(
                                value: sex,
                                child: Text(sex),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Sex',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _preference,
                      onChanged: (value) {
                        setState(() {
                          _preference = value!;
                        });
                      },
                      items: ['Male', 'Female', 'Both']
                          .map((preference) => DropdownMenuItem<String>(
                                value: preference,
                                child: Text(preference),
                              ))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Preference',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: lightGray,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _profilePhoto == null
                            ? 'Add Profile Photo'
                            : 'Change Profile Photo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Use my location'),
                      value: useLocation,
                      activeColor: deepPurple,
                      onChanged: (bool value) {
                        setState(() {
                          useLocation = value;
                          if (useLocation) {
                            _getLocation();
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
