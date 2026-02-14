import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _entryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final User? user = FirebaseAuth.instance.currentUser;

  // --- 1. NEW LOGIC: INCREMENT TASK ONLY ON SAVE ---
  Future<void> _recordJournalActivity() async {
    if (user == null) return;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var taskDoc = FirebaseFirestore.instance.collection('daily_tasks').doc("${user!.uid}_$today");

    try {
      var doc = await taskDoc.get();
      if (!doc.exists) {
        await taskDoc.set({
          'userId': user!.uid,
          'date': today,
          'games': 0,
          'journal': 1, // Pehla journal record
          'meditation': 0,
          'articles': 0,
          'allDoneShown': false
        });
      } else {
        await taskDoc.update({'journal': FieldValue.increment(1)});
      }
      debugPrint("Journal task updated successfully!");
    } catch (e) {
      debugPrint("Error updating journal task count: $e");
    }
  }

  // --- 2. DATABASE LOGIC: SAVE ENTRY ---
  Future<void> _saveJournalEntry(String content) async {
    if (user == null) return;
    String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      await FirebaseFirestore.instance.collection('journals').add({
        'userId': user!.uid,
        'content': content,
        'date': dateKey,
        'timestamp': FieldValue.serverTimestamp(),
        'mood': '😊',
        'createdAt': DateTime.now().toString(),
      });

      // SIRF AAJ KI DATE PAR TASK INCREMENT HOGA
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (dateKey == today) {
        await _recordJournalActivity();
      }

    } catch (e) {
      debugPrint("Error saving journal: $e");
    }
  }

  // --- Theme-Aware Date Picker ---
  Future<void> _selectDateFromPicker(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(primary: Color(0xFF6B4CE6), onPrimary: Colors.white, surface: Color(0xFF1E1E1E))
                : const ColorScheme.light(primary: Color(0xFF6B4CE6), onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    String filterDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Personal Journal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: mainTextColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: mainTextColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF6B4CE6)),
            onPressed: () => _selectDateFromPicker(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            color: Colors.transparent,
            child: EasyDateTimeLine(
              initialDate: _selectedDate,
              onDateChange: (newDate) => setState(() => _selectedDate = newDate),
              activeColor: const Color(0xFF6B4CE6),
              headerProps: EasyHeaderProps(
                monthPickerType: MonthPickerType.switcher,
                selectedDateFormat: SelectedDateFormat.fullDateMonthAsStrDY,
                monthStyle: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
              ),
              dayProps: EasyDayProps(
                height: 85,
                width: 65,
                dayStructure: DayStructure.dayStrDayNum,
                inactiveDayStyle: DayStyle(
                  dayNumStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 18),
                  dayStrStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                activeDayStyle: const DayStyle(
                  borderRadius: 16,
                  decoration: BoxDecoration(color: Color(0xFF6B4CE6)),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('journals')
                  .where('userId', isEqualTo: user?.uid)
                  .where('date', isEqualTo: filterDate)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6B4CE6)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    return _buildJournalCard(context, doc['content'] ?? "", doc['mood'] ?? "😊");
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEntryDialog(context),
        backgroundColor: const Color(0xFF6B4CE6),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("Write Today", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 80, color: isDark ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 15),
          Text("No journal entries found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 5),
          Text("Tap the button below to record your thoughts.", style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildJournalCard(BuildContext context, String content, String mood) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mood, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 15),
          Expanded(child: Text(content, style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? Colors.white : Colors.black87))),
        ],
      ),
    );
  }

  void _showEntryDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Journal Entry", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: TextField(
          controller: _entryController,
          maxLines: 4,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
              hintText: "What's on your mind?",
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
              border: InputBorder.none
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_entryController.text.trim().isNotEmpty) {
                // AB YE DONO KAAM KAREGA: SAVE BHI AUR COUNT BHI
                _saveJournalEntry(_entryController.text);
                _entryController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4CE6)),
            child: const Text("Save Entry", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}