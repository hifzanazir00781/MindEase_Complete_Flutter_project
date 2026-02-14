import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendEmail() async {
    final String message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please write your message first!")));
      return;
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'easemind.help@gmail.com',
      queryParameters: {'subject': 'MindEase Support Request', 'body': message},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open Email app")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true, elevation: 0, backgroundColor: Colors.transparent, foregroundColor: mainTextColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF6B4CE6).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.headset_mic_rounded, size: 60, color: Color(0xFF6B4CE6)),
                  ),
                  const SizedBox(height: 15),
                  Text('How can we help you?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: mainTextColor)),
                ],
              ),
            ),
            const SizedBox(height: 35),

            Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainTextColor)),
            const SizedBox(height: 15),
            _buildFAQItem('How do I complete my Daily Goals?', 'You need to complete 3 Games, write 3 Journals, do 1 Meditation session, and read 1 Article to hit 100%.'),
            _buildFAQItem('Why did my streak reset?', 'Streaks reset if you don\'t log in and complete at least one activity within 24 hours.'),
            _buildFAQItem('Is my journal data safe?', 'Yes! MindEase uses industry-standard encryption. Your personal thoughts are stored securely and are private to your account.'),
            _buildFAQItem('How can I change my profile picture?', 'Go to the Profile page and tap on "Edit Profile" to upload a new photo.'),
            _buildFAQItem('Can I delete my account?', 'Yes, you can find the "Delete Account" option at the bottom of the Profile menu under the Danger Zone.'),

            const SizedBox(height: 35),
            Text('Send us a Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainTextColor)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type your issue or feedback here...',
                  border: InputBorder.none, contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _sendEmail,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4CE6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text('Send Message', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            Center(child: Text('Email: easemind.help@gmail.com', style: TextStyle(color: Colors.grey[600], fontSize: 14))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(answer, style: TextStyle(color: Colors.grey[600], height: 1.5)),
          )
        ],
      ),
    );
  }
}