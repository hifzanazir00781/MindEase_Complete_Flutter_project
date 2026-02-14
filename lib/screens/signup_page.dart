import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _handleSignup() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // 1. Basic Validations
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    // Email format validation
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      _showError("Please enter a valid email address");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match!");
      return;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    // Loading Show karein
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF6B4CE6)),
      ),
    );

    try {
      // 2. AuthService se Signup call karein
      final user = await AuthService().signUp(email, password, name);

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (user != null) {
        // 3. Email Verification Bhejein (Most Important)
        await user.sendEmailVerification();

        _showSuccessDialog();
      } else {
        _showError("Signup failed. Email might already be in use.");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError("Error: ${e.toString()}");
    }
  }

  // Success Message aur Redirect
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Verify Your Email"),
        content: const Text(
          "A verification link has been sent to your email. Please click the link to activate your account before logging in.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text("Go to Login", style: TextStyle(color: Color(0xFF6B4CE6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              _buildBackButton(isDark, mainTextColor),
              const SizedBox(height: 30),
              Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: mainTextColor)),
              const SizedBox(height: 8),
              Text('Join MindEase and start your journey.', style: TextStyle(fontSize: 16, color: secondaryTextColor)),
              const SizedBox(height: 30),

              _buildTextField(context, _nameController, 'Full Name', 'John Doe', Icons.person_outline_rounded),
              const SizedBox(height: 20),
              _buildTextField(context, _emailController, 'Email Address', 'example@gmail.com', Icons.email_outlined),
              const SizedBox(height: 20),
              _buildTextField(context, _passwordController, 'Password', '••••••••', Icons.lock_outline_rounded, isPassword: true),
              const SizedBox(height: 20),
              _buildTextField(context, _confirmPasswordController, 'Confirm Password', '••••••••', Icons.lock_clock_outlined, isPassword: true),

              const SizedBox(height: 40),
              _buildSignupButton(),
              const SizedBox(height: 24),
              _buildLoginRedirect(secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components ---
  Widget _buildBackButton(bool isDark, Color mainTextColor) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: mainTextColor),
      style: IconButton.styleFrom(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B4CE6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginRedirect(Color secondaryTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: TextStyle(color: secondaryTextColor)),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          child: const Text('Login', style: TextStyle(color: Color(0xFF6B4CE6), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, String hint, IconData icon, {bool isPassword = false}) {
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
            obscureText: isPassword && !_isPasswordVisible,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(icon, color: const Color(0xFF6B4CE6), size: 22),
              suffixIcon: isPassword ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}