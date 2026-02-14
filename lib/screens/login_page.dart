import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore ke liye
import '../services/auth_service.dart';
import 'signup_page.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // --- LOGIN + RESTORE LOGIC ---
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter both email and password");
      return;
    }

    _showLoading();

    try {
      final user = await AuthService().logIn(email, password);

      if (!mounted) return;
      Navigator.pop(context); // Loading khata

      if (user != null) {
        // 1. Check Email Verification
        if (user.emailVerified) {

          // --- REAL MAGIC: RESTORE ACCOUNT LOGIC ---
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

          if (userDoc.exists && userDoc.data()?['accountStatus'] == 'pending_deletion') {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'accountStatus': 'active',
              'scheduledDeletionDate': FieldValue.delete(), // Timer khatam
            });
            _showSnackBar("Welcome back! Your account has been restored.");
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          await AuthService().signOut();
          _showVerificationDialog(user);
        }
      } else {
        _showSnackBar("Invalid email or password.");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  // --- FORGOT PASSWORD (Professional Link Flow) ---
  Future<void> _handleForgotPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("Please enter your email address above first");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Professional way: Dialog dikhana code mangne ke bajaye
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Reset Link Sent"),
          content: Text("A professional secure link has been sent to $email. Please click the link to set your new password, then return here to login."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    }
  }

  // --- UI HELPERS ---
  void _showVerificationDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Verify Your Email"),
        content: const Text("A verification link was sent. Please check your email (and Spam folder)."),
        actions: [
          TextButton(
            onPressed: () async {
              await user.sendEmailVerification();
              _showSnackBar("New link sent! Please check your email.");
              Navigator.pop(context);
            },
            child: const Text("Resend Link", style: TextStyle(color: Color(0xFF6B4CE6))),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF6B4CE6))),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF888888);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome Back', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: mainTextColor)),
              const SizedBox(height: 8),
              Text('Log in to your MindEase account.', style: TextStyle(fontSize: 16, color: secondaryTextColor)),
              const SizedBox(height: 40),

              _buildTextField(context, controller: _emailController, label: 'Email Address', hint: 'example@gmail.com', icon: Icons.email_outlined),
              const SizedBox(height: 20),
              _buildTextField(context, controller: _passwordController, label: 'Password', hint: '••••••••', icon: Icons.lock_outline_rounded, isPassword: true, isPasswordVisible: _isPasswordVisible,
                  onPasswordToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF6B4CE6), fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4CE6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account? ', style: TextStyle(color: secondaryTextColor)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage())),
                    child: const Text('Sign Up', style: TextStyle(color: Color(0xFF6B4CE6), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, {required TextEditingController controller, required String label, required String hint, required IconData icon, bool isPassword = false, bool isPasswordVisible = false, VoidCallback? onPasswordToggle}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF6B4CE6)),
              suffixIcon: isPassword ? IconButton(icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: onPasswordToggle, color: Colors.grey) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}