import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Sahi imports aapki file structure ke mutabiq
import 'onboarding_screen.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import 'delete_account_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  Uint8List? _imageBytes;
  String? _lastBase64String;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text("Please Login")));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // StreamBuilder live updates ke liye behtareen hai
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting && _imageBytes == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6B4CE6)));
          }

          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            String name = userData['name'] ?? "User";
            int streak = userData['streak'] ?? 0;

            // Dashboard se update hone wala goal count
            int goalsMet = userData['completedGoalsCount'] ?? 0;

            String? profilePicBase64 = userData['profilePic'];
            if (profilePicBase64 != null && profilePicBase64 != _lastBase64String) {
              _lastBase64String = profilePicBase64;
              _imageBytes = base64Decode(profilePicBase64);
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('journals')
                  .where('userId', isEqualTo: user!.uid)
                  .snapshots(),
              builder: (context, journalSnapshot) {
                int realJournalCount = journalSnapshot.hasData ? journalSnapshot.data!.docs.length : 0;

                return SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // --- PROFILE HEADER ---
                          _buildProfileHeader(isDark, name),

                          const SizedBox(height: 24),

                          // --- STATS GRID ---
                          Row(
                            children: [
                              Expanded(child: _buildStatCard(context, '$streak', 'Day\nStreak', Icons.local_fire_department)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard(context, '$goalsMet', 'Goals\nMet', Icons.stars_rounded)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard(context, '$realJournalCount', 'Journal\nNotes', Icons.auto_stories)),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // --- MENU ITEMS ---
                          _buildMenuItems(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("No data found"));
        },
      ),
    );
  }

  // Header Widget logic
  Widget _buildProfileHeader(bool isDark, String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF4A34A4), const Color(0xFF6B4CE6)]
              : [const Color(0xFF6B4CE6), const Color(0xFF9B7EE8)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
            ),
            child: ClipOval(
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!, fit: BoxFit.cover, gaplessPlayback: true)
                  : const Icon(Icons.person, size: 50, color: Color(0xFF6B4CE6)),
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('Wellness Journey In Progress', style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Menu Items logic including Delete Account and Help
  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(context, Icons.person_outline, 'Edit Profile', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
        }),
        _buildMenuItem(context, Icons.notifications_outlined, 'Notifications', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
        }),
        _buildMenuItem(context, Icons.settings_outlined, 'Settings', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }),
        _buildMenuItem(context, Icons.help_outline, 'Help & Support', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
        }),
        _buildMenuItem(context, Icons.info_outline, 'About MindEase', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
        }),
        _buildMenuItem(context, Icons.person_off_outlined, 'Delete Account', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DeleteAccountScreen()));
        }, isDestructive: true),
        const SizedBox(height: 12),
        _buildMenuItem(context, Icons.logout, 'Logout', () => _showLogoutDialog(), isDestructive: true),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF6B4CE6)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2D2D2D))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : const Color(0xFF888888)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF6B4CE6)),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDestructive ? Colors.red : (isDark ? Colors.white : const Color(0xFF2D2D2D)))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFCCCCCC)),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()), (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}