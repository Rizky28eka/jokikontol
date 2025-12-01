import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/auth_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> with AutomaticKeepAliveClientMixin {
  final AuthController authController = Get.find();

  @override
  bool get wantKeepAlive => true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _pickedProfilePhotoPath;

  Future<void> _refreshProfile() async {
    await authController.getUserProfile();
  }

  void refresh() => _refreshProfile();

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              final user = authController.user;
              if (user == null) {
                return const Center(child: Text('No user data available'));
              }

              _nameController.text = user.name;
              _usernameController.text = user.username ?? '';
              _phoneController.text = user.phoneNumber ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Name'),
                    subtitle: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('Username'),
                    subtitle: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Username (change once)',
                      ),
                      enabled: user.usernameChangedAt == null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone Number'),
                    subtitle: TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        hintText: 'Phone Number (change once)',
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: user.phoneChangedAt == null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: user.profilePhoto != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.profilePhoto!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: const Text('Profile Photo'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Pick Photo'),
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );
                            if (result != null && result.files.isNotEmpty) {
                              setState(() {
                                _pickedProfilePhotoPath = result.files.single.path;
                              });
                            }
                          },
                        ),
                        if (_pickedProfilePhotoPath != null) ...[
                          const SizedBox(height: 8),
                          Image.file(
                            File(_pickedProfilePhotoPath!),
                            width: 120,
                            height: 120,
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('Role'),
                    subtitle: Text(
                      user.role == 'dosen' ? 'Dosen' : 'Mahasiswa',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Change Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _updateProfile(),
                      child: const Text('Update Profile'),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  void _updateProfile() async {
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Get.snackbar('Error', 'Passwords do not match');
        return;
      }
      if (_passwordController.text.length < 8) {
        Get.snackbar('Error', 'Password must be at least 8 characters');
        return;
      }
    }

    try {
      await authController.updateProfile(
        name: _nameController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        username: _usernameController.text.isNotEmpty ? _usernameController.text : null,
        phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        profilePhotoPath: _pickedProfilePhotoPath,
      );
      // After successful update, refresh user info from API
      await authController.getUserProfile();
    } catch (e) {
      // Error already handled in controller with snackbar
    }
  }
}
