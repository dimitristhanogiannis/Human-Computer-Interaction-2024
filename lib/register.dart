import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

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

  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color deepPurple = Color(0xFF7B1FA2);

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePhoto = image.path;
      });
    }
  }

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Remove the app bar space
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CamConnect logo
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
              // Add extra space below the logo
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
                      onChanged: (bool value) {
                        setState(() {
                          useLocation = value;
                          if (useLocation) _getLocation();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
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
