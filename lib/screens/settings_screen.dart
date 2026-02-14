import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart'; // Ensure themeNotifier is accessible

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _darkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final User? user = _auth.currentUser;
    if (user == null) return;
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _darkMode = data['darkMode'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTheme(bool value) async {
    final User? user = _auth.currentUser;
    if (user == null) return;
    setState(() {
      _darkMode = value;
      themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    });
    try {
      await _firestore.collection('users').doc(user.uid).update({'darkMode': value});
    } catch (e) {
      debugPrint("Error saving theme: $e");
    }
  }

  Future<void> _handleClearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("App cache cleared!"), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      debugPrint("Cache error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B4CE6)))
          : ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildSectionHeader('Appearance'),
          _buildSwitchTile('Dark Mode', Icons.dark_mode_outlined, _darkMode, (v) => _updateTheme(v)),

          const SizedBox(height: 25),
          _buildSectionHeader('Account & Security'),
          _buildSimpleTile('Privacy Policy', Icons.privacy_tip_outlined, () {
            _showInfoDialog('Privacy Policy', 'Your data is encrypted and secure. We never share your personal journal entries with anyone.');
          }),
          _buildSimpleTile('Terms of Service', Icons.gavel_rounded, () {
            _showInfoDialog('Terms of Service', 'By using MindEase, you agree to use our tools for personal well-being and growth.');
          }),

          const SizedBox(height: 25),
          _buildSectionHeader('System'),
          _buildSimpleTile('Clear App Cache', Icons.cleaning_services_rounded, _showClearCacheDialog, color: Colors.blueAccent),

          const SizedBox(height: 50),
          Center(
            child: Column(
              children: [
                const Icon(Icons.spa_rounded, color: Color(0xFF6B4CE6), size: 30),
                const SizedBox(height: 10),
                const Text('MindEase v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 10),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6B4CE6)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF6B4CE6)),
      ),
    );
  }

  Widget _buildSimpleTile(String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? const Color(0xFF6B4CE6)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(context: context, builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title), content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]
    ));
  }

  void _showClearCacheDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cache'), content: const Text('Refresh app performance by clearing temp files?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(context); _handleClearCache(); }, child: const Text('Clear', style: TextStyle(color: Colors.red)))
        ]
    ));
  }
}