import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isProcessing = false;

  Future<void> _scheduleDeletion() async {
    setState(() => _isProcessing = true);

    final user = FirebaseAuth.instance.currentUser;
    // 30 din baad ki date calculate karein
    final deletionDate = DateTime.now().add(const Duration(days: 30));

    try {
      // Firestore mein account status update karein
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'accountStatus': 'pending_deletion',
        'scheduledDeletionDate': deletionDate.toIso8601String(),
      }, SetOptions(merge: true));

      // User ko logout karwa dein
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // Confirmation Dialog dikhayein
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Account Scheduled"),
          content: const Text("Your account will be permanently deleted in 30 days. Log in anytime before then to cancel this request."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              },
              child: const Text("Understand"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Safety"), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 100),
            const SizedBox(height: 20),
            const Text("Are you sure?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Text(
              "By proceeding, your account will be disabled immediately. You have 30 days to log back in and restore your data. After 30 days, your journals, moods, and profile will be deleted permanently.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            _isProcessing
                ? const CircularProgressIndicator()
                : Column(
              children: [
                ElevatedButton(
                  onPressed: _scheduleDeletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Delete My Account", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Keep My Account", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}