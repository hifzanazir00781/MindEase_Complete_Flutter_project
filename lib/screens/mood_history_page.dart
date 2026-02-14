import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MoodHistoryPage extends StatelessWidget {
  const MoodHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Theme references for Dynamic UI
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      // Dynamic background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
            "Mood History",
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.white)
        ),
        // Dark mode mein AppBar thora deep purple/blackish ho jayega professional look ke liye
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF6B4CE6),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('mood_history')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading history"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6B4CE6)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      Icons.wb_sunny_outlined,
                      size: 80,
                      color: isDark ? Colors.white24 : Colors.grey[300]
                  ),
                  const SizedBox(height: 10),
                  Text(
                      "No mood history yet.",
                      style: TextStyle(color: secondaryTextColor)
                  ),
                ],
              ),
            );
          }

          // --- MANUAL SORTING LOGIC ---
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          docs.sort((a, b) {
            var dateA = (a.data() as Map<String, dynamic>)['date'] as Timestamp?;
            var dateB = (b.data() as Map<String, dynamic>)['date'] as Timestamp?;
            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA);
          });

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;

              DateTime date;
              if (data['date'] is Timestamp) {
                date = (data['date'] as Timestamp).toDate();
              } else {
                date = DateTime.now();
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                // Dynamic Card Color
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: isDark ? 0 : 2, // Dark mode mein elevation ki jagah border better lagta hai
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4CE6).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                        data['emoji'] ?? '😊',
                        style: const TextStyle(fontSize: 25)
                    ),
                  ),
                  title: Text(
                    data['mood'] ?? 'Unknown',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: mainTextColor // Dynamic Text
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('EEEE, MMM d - hh:mm a').format(date),
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}