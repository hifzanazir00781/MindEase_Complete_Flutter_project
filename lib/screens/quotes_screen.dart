import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  // Caching variables
  List<dynamic> cachedQuotes = [];
  int quoteIndex = 0;

  String currentQuote = "Loading inspiration...";
  String currentAuthor = "Please wait";
  String userName = "Friend";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialQuotes(); // Ek sath 50 quotes fetch karein
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) setState(() => userName = doc.data()?['name'] ?? "Friend");
      }
    } catch (e) { debugPrint(e.toString()); }
  }

  // --- FAST LOADING LOGIC ---
  Future<void> _fetchInitialQuotes() async {
    try {
      // '/quotes' endpoint ek sath 50 quotes deta hai!
      final response = await http.get(Uri.parse('https://zenquotes.io/api/quotes'));
      if (response.statusCode == 200) {
        cachedQuotes = json.decode(response.body);
        _updateQuote(); // Pehla quote foran dikhao
      }
    } catch (e) {
      setState(() {
        currentQuote = "Offline Mode: Stay positive!";
        currentAuthor = "MindEase";
        isLoading = false;
      });
    }
  }

  void _updateQuote() {
    if (cachedQuotes.isNotEmpty) {
      setState(() {
        currentQuote = cachedQuotes[quoteIndex]['q'];
        currentAuthor = cachedQuotes[quoteIndex]['a'];
        isLoading = false;
      });
      // Index barhao, agar 50 khatam ho jayein to wapis 0 par jao
      quoteIndex = (quoteIndex + 1) % cachedQuotes.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Inspiring Quotes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, foregroundColor: mainTextColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFB4A7D6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Daily Inspiration for $userName',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- QUOTE CARD (Instant Change) ---
            Expanded(
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark ? [const Color(0xFF4A34A4), const Color(0xFF6B4CE6)]
                        : [const Color(0xFFB4A7D6), const Color(0xFF6B4CE6)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('"$currentQuote"',
                          style: const TextStyle(fontSize: 22, color: Colors.white, height: 1.4),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      Text("- $currentAuthor", style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(icon: Icons.refresh, onPressed: _updateQuote, isDark: isDark),
                _buildNavButton(icon: Icons.favorite_border, isAction: true, onPressed: () {}, isDark: isDark),
                _buildNavButton(icon: Icons.arrow_forward, onPressed: _updateQuote, isDark: isDark),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _updateQuote,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4CE6)),
                child: const Text('🎲 Get Random Quote', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, VoidCallback? onPressed, bool isAction = false, required bool isDark}) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAction ? const Color(0xFF6B4CE6) : (isDark ? Colors.white10 : Colors.black12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isAction ? Colors.white : (isDark ? Colors.white : Colors.black87)),
      ),
    );
  }
}