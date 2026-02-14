import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isUpdating = false;
  String? _profileImageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    var doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? user!.email ?? '';
        _bioController.text = data['bio'] ?? '';
        _profileImageUrl = data['profilePic'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final XFile? pickedFile = await showModalBottomSheet<XFile>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF6B4CE6)),
              title: Text('Photo Gallery', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
                if (mounted) Navigator.pop(context, img);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6B4CE6)),
              title: Text('Camera', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.camera, imageQuality: 30);
                if (mounted) Navigator.pop(context, img);
              },
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name cannot be empty")));
      return;
    }

    setState(() => _isUpdating = true);
    try {
      String? finalImageData = _profileImageUrl;

      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        finalImageData = base64Encode(bytes);
      }

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'profilePic': finalImageData,
        'email': _emailController.text.trim(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: mainTextColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Image Section
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 20
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? Image.memory(
                          base64Decode(_profileImageUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => Icon(Icons.person, size: 60, color: isDark ? Colors.white24 : const Color(0xFF6B4CE6)))
                          : Icon(Icons.person, size: 60, color: isDark ? Colors.white24 : const Color(0xFF6B4CE6))),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF6B4CE6), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Input Fields
            _buildEditField(context, 'Full Name', _nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildEditField(context, 'Email Address', _emailController, Icons.email_outlined, enabled: false),
            const SizedBox(height: 20),
            _buildEditField(context, 'Bio', _bioController, Icons.info_outline, maxLines: 3),

            const SizedBox(height: 40),

            _isUpdating
                ? const CircularProgressIndicator(color: Color(0xFF6B4CE6))
                : SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4CE6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(BuildContext context, String label, TextEditingController controller, IconData icon, {int maxLines = 1, bool enabled = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF2D2D2D))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                : (isDark ? Colors.black26 : Colors.grey.shade100),
            prefixIcon: Icon(icon, color: const Color(0xFF6B4CE6)),
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}