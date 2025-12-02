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

class ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin {
  final AuthController authController = Get.find();

  @override
  bool get wantKeepAlive => true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _pickedProfilePhotoPath;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          color: colorScheme.primary,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 600;
              final maxContentWidth = isWideScreen ? 800.0 : double.infinity;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen ? 48.0 : 20.0,
                      vertical: 24.0,
                    ),
                    child: Obx(() {
                      final user = authController.user;
                      if (user == null) {
                        return SizedBox(
                          height: constraints.maxHeight - 48,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_circle_outlined,
                                  size: 80,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No user data available',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      _nameController.text = user.name;
                      _usernameController.text = user.username ?? '';
                      _phoneController.text = user.phoneNumber ?? '';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Profile',
                                      style: textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage your account information',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.logout_rounded),
                                onPressed: () => authController.logout(),
                                tooltip: 'Logout',
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Profile Photo Section
                          Center(
                            child: _buildProfilePhotoSection(colorScheme, user),
                          ),
                          const SizedBox(height: 40),

                          // User Info Card
                          _buildInfoCard(
                            colorScheme,
                            textTheme,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline_rounded,
                                  colorScheme: colorScheme,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  icon: Icons.alternate_email_rounded,
                                  colorScheme: colorScheme,
                                  enabled: user.usernameChangedAt == null,
                                  helperText: user.usernameChangedAt != null
                                      ? 'Username can only be changed once'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  colorScheme: colorScheme,
                                  keyboardType: TextInputType.phone,
                                  enabled: user.phoneChangedAt == null,
                                  helperText: user.phoneChangedAt != null
                                      ? 'Phone number can only be changed once'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: TextEditingController(
                                    text: user.email,
                                  ),
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  colorScheme: colorScheme,
                                  enabled: false,
                                ),
                                const SizedBox(height: 16),
                                _buildRoleBadge(
                                  user.role,
                                  colorScheme,
                                  textTheme,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Change Password Card
                          _buildInfoCard(
                            colorScheme,
                            textTheme,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Change Password',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Leave blank to keep current password',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildPasswordField(
                                  controller: _passwordController,
                                  label: 'New Password',
                                  colorScheme: colorScheme,
                                  isVisible: _isPasswordVisible,
                                  onToggle: () => setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm Password',
                                  colorScheme: colorScheme,
                                  isVisible: _isConfirmPasswordVisible,
                                  onToggle: () => setState(
                                    () => _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _updateProfile,
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                              ),
                              label: const Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(ColorScheme colorScheme, user) {
    return Column(
      children: [
        Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: _pickedProfilePhotoPath != null
                    ? FileImage(File(_pickedProfilePhotoPath!))
                    : (user.profilePhoto != null
                              ? NetworkImage(user.profilePhoto!)
                              : null)
                          as ImageProvider?,
                child:
                    _pickedProfilePhotoPath == null && user.profilePhoto == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Material(
                color: colorScheme.primary,
                shape: const CircleBorder(),
                elevation: 4,
                child: InkWell(
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (result != null && result.files.isNotEmpty) {
                      setState(() {
                        _pickedProfilePhotoPath = result.files.single.path;
                      });
                    }
                  },
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_pickedProfilePhotoPath != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'New photo selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    bool enabled = true,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(
        color: enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
      ),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: TextStyle(color: colorScheme.error, fontSize: 12),
        prefixIcon: Icon(icon, color: colorScheme.primary),
        filled: true,
        fillColor: enabled
            ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : colorScheme.surfaceContainerHighest.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required ColorScheme colorScheme,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(
    String role,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isDosen = role == 'dosen';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDosen
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDosen ? Icons.school_rounded : Icons.person_rounded,
            size: 20,
            color: isDosen
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            isDosen ? 'Dosen' : 'Mahasiswa',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDosen
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  void _updateProfile() async {
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Get.snackbar(
          'Error',
          'Passwords do not match',
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          colorText: Theme.of(context).colorScheme.onErrorContainer,
        );
        return;
      }
      if (_passwordController.text.length < 8) {
        Get.snackbar(
          'Error',
          'Password must be at least 8 characters',
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          colorText: Theme.of(context).colorScheme.onErrorContainer,
        );
        return;
      }
    }

    try {
      await authController.updateProfile(
        name: _nameController.text,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        username: _usernameController.text.isNotEmpty
            ? _usernameController.text
            : null,
        phoneNumber: _phoneController.text.isNotEmpty
            ? _phoneController.text
            : null,
        profilePhotoPath: _pickedProfilePhotoPath,
      );
      await authController.getUserProfile();
      setState(() {
        _pickedProfilePhotoPath = null;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      // Error already handled in controller
    }
  }
}
