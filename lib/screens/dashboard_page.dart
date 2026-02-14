import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

// --- Services & Models ---
import '../services/notification_service.dart';
import '../models/article.dart';
import 'article_data.dart';

// --- Screens ---
import 'sounds_screen.dart';
import 'games_screen.dart';
import 'journal_page.dart';
import 'settings_screen.dart';
import 'mood_history_page.dart';
import 'meditation_screen.dart';
// AI Chat import yahan se hata diya gaya hai

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final user = FirebaseAuth.instance.currentUser;
  String selectedMood = '';
  bool _showCelebration = false;
  String _celebrationMsg = "";
  String _celebrationEmoji = "";
  bool _showStreakOverlay = false;
  int _currentStreakForAnimation = 0;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  // --- LOGIC FUNCTIONS ---
  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning";
    else if (hour >= 12 && hour < 17) return "Good Afternoon";
    else if (hour >= 17 && hour < 21) return "Good Evening";
    else return "Good Night";
  }

  Future<void> _initializeDashboard() async {
    if (user == null) return;
    await updateStreak();
    var doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      int streak = doc.data()?['streak'] ?? 0;
      bool isNotifyEnabled = doc.data()?['notificationsEnabled'] ?? true;
      String lastShownAnimDate = doc.data()?['lastStreakAnimDate'] ?? "";
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (lastShownAnimDate != today) {
        setState(() {
          _currentStreakForAnimation = streak;
          _showStreakOverlay = true;
        });
        if (isNotifyEnabled) {
          NotificationService().showInstantNotification("🔥 Streak Updated!", "You are on a $streak day streak!");
        }
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'lastStreakAnimDate': today});
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _showStreakOverlay = false);
        });
      }
    }
  }

  Future<void> updateStreak() async {
    if (user == null) return;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
    try {
      var doc = await userDoc.get();
      if (doc.exists) {
        String lastActive = doc.data()?['last_active'] ?? "";
        int currentStreak = doc.data()?['streak'] ?? 0;
        if (lastActive != today) {
          int newStreak = currentStreak;
          if (lastActive.isNotEmpty) {
            DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastActive);
            int difference = DateTime.now().difference(lastDate).inDays;
            if (difference == 1) newStreak++;
            else if (difference > 1) newStreak = 1;
          } else { newStreak = 1; }
          await userDoc.update({'streak': newStreak, 'last_active': today});
        }
      }
    } catch (e) { debugPrint("Error updating streak: $e"); }
  }

  Future<void> recordActivity(String taskType) async {
    if (user == null) return;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var taskDoc = FirebaseFirestore.instance.collection('daily_tasks').doc("${user!.uid}_$today");
    var doc = await taskDoc.get();
    if (!doc.exists) {
      await taskDoc.set({'userId': user!.uid, 'date': today, 'games': 0, 'journal': 0, 'meditation': 0, 'articles': 0, 'allDoneShown': false});
    }
    await taskDoc.update({taskType: FieldValue.increment(1)});
    var updated = await taskDoc.get();
    var userDocSnap = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    bool isNotificationsEnabled = userDocSnap.data()?['notificationsEnabled'] ?? true;
    _checkGoalCompletion(updated, isNotificationsEnabled);
  }

  Future<void> _checkGoalCompletion(DocumentSnapshot doc, bool notify) async {
    var data = doc.data() as Map<String, dynamic>;
    bool isGamesDone = (data['games'] ?? 0) >= 3;
    bool isJournalDone = (data['journal'] ?? 0) >= 3;
    bool isMeditationDone = (data['meditation'] ?? 0) >= 1;
    bool isArticlesDone = (data['articles'] ?? 0) >= 1;
    bool alreadyShown = data['allDoneShown'] ?? false;

    if (isGamesDone && isJournalDone && isMeditationDone && isArticlesDone && !alreadyShown) {
      await FirebaseFirestore.instance.collection('daily_tasks').doc(doc.id).update({'allDoneShown': true});
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'completedGoalsCount': FieldValue.increment(1)});
      _triggerCelebration("Daily Goals Completed!", "🏆", notify);
    }
  }

  void _triggerCelebration(String msg, String emoji, bool notify) {
    if (notify) NotificationService().showInstantNotification(emoji, msg);
    setState(() { _celebrationMsg = msg; _celebrationEmoji = emoji; _showCelebration = true; });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _showCelebration = false); });
  }

  Future<void> saveMoodToFirebase(String moodName) async {
    if (user == null) return;
    String emoji = (moodName == 'Happy') ? '😊' : (moodName == 'Sad') ? '😔' : (moodName == 'Anxious') ? '😰' : '😌';
    try {
      await FirebaseFirestore.instance.collection('mood_history').add({'userId': user!.uid, 'mood': moodName, 'date': FieldValue.serverTimestamp(), 'emoji': emoji});
    } catch (e) { debugPrint("Error: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text("Please Login")));

    return Stack(
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
          builder: (context, snapshot) {
            String name = "User"; int streakCount = 0;
            if (snapshot.hasData && snapshot.data!.exists) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              name = data['name'] ?? "User";
              streakCount = data['streak'] ?? 0;
            }
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildHeader(context, name, streakCount),
                      const SizedBox(height: 25),
                      _buildMoodCard(context),
                      const SizedBox(height: 30),
                      _buildArticleSection(context),
                      const SizedBox(height: 30),
                      _buildQuickActions(context),
                      const SizedBox(height: 30),
                      _buildTodayProgress(context),
                    ]),
                  ),
                ),
              ),
              // Gemini Chat FloatingActionButton yahan se hata diya gaya hai
            );
          },
        ),
        if (_showStreakOverlay) _buildStreakOverlay(context),
        if (_showCelebration) _buildTaskCelebration(context, _celebrationMsg, _celebrationEmoji),
      ],
    );
  }

  // --- WIDGET BUILDERS (Header, Mood Card, etc. same as before) ---
  // [Baqi saare builders code mein mojood hain...]

  Widget _buildHeader(BuildContext context, String name, int streakValue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${getGreeting()},\n$name!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2, color: isDark ? Colors.white : Colors.black87)),
        Text('MindEase is here for you.', style: TextStyle(fontSize: 15, color: isDark ? Colors.white60 : Colors.grey)),
      ]),
      Row(children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text('$streakValue', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16))
            ])
        ),
        const SizedBox(width: 12),
        GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4CE6).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6B4CE6).withOpacity(0.2)),
              ),
              child: const Icon(Icons.settings_outlined, color: Color(0xFF6B4CE6), size: 24),
            )
        ),
      ]),
    ]);
  }

  Widget _buildMoodCard(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6B4CE6), Color(0xFF8E71F3)]), borderRadius: BorderRadius.circular(25)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('How are you feeling?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        Center(child: Wrap(spacing: 15, runSpacing: 15, children: [
          _moodIcon(context, '😊', 'Happy'), _moodIcon(context, '😌', 'Calm'), _moodIcon(context, '😔', 'Sad'), _moodIcon(context, '😰', 'Anxious')
        ]))
      ]),
    );
  }

  Widget _moodIcon(BuildContext context, String emoji, String mood) {
    bool isSelected = selectedMood == mood;
    return GestureDetector(
      onTap: () async { setState(() => selectedMood = mood); await saveMoodToFirebase(mood); },
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            Text(mood, style: TextStyle(color: isSelected ? const Color(0xFF6B4CE6) : Colors.white, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))
          ])
      ),
    );
  }

  Widget _buildArticleSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<Article> articles = getRecommendedArticles();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(selectedMood.isEmpty ? 'MindEase Insights' : 'Help for $selectedMood mood', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(height: 15),
      SizedBox(height: 235, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: articles.length, physics: const BouncingScrollPhysics(), itemBuilder: (context, index) => _articleCard(context, articles[index])))
    ]);
  }

  Widget _articleCard(BuildContext context, Article art) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () { _showArticleDetails(art); recordActivity('articles'); },
      child: Container(
          width: 220, margin: const EdgeInsets.only(right: 15, bottom: 5),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: CachedNetworkImage(imageUrl: art.imageUrl, height: 110, width: double.infinity, fit: BoxFit.cover)),
            Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(art.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Text(art.description, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis)
            ]))
          ])
      ),
    );
  }

  void _showArticleDetails(Article art) {
    showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5,
            builder: (_, scrollController) => Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
                child: ListView(controller: scrollController, padding: const EdgeInsets.all(25), children: [
                  Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  ClipRRect(borderRadius: BorderRadius.circular(20), child: CachedNetworkImage(imageUrl: art.imageUrl, height: 200, fit: BoxFit.cover)),
                  const SizedBox(height: 20),
                  Text(art.moodTag.toUpperCase(), style: const TextStyle(color: Color(0xFF6B4CE6), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(art.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Divider(height: 30),
                  Text(art.content, style: TextStyle(fontSize: 16, height: 1.6, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87)),
                  const SizedBox(height: 50),
                ])
            )
        )
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(height: 15),
      Row(children: [
        Expanded(child: _actionTile(context, '🧘', 'Meditation', isDark ? const Color(0xFF1B3022) : const Color(0xFFE8F5E9), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeditationScreen())))),
        const SizedBox(width: 15),
        Expanded(child: _actionTile(context, '🎮', 'Relax Games', isDark ? const Color(0xFF352616) : const Color(0xFFFFF3E0), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamesScreen())))),
      ]),
      const SizedBox(height: 15),
      Row(children: [
        Expanded(child: _actionTile(context, '📝', 'Journal', isDark ? const Color(0xFF351B1D) : const Color(0xFFFFEBEE), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalPage())))),
        const SizedBox(width: 15),
        Expanded(child: _actionTile(context, '📊', 'Mood History', isDark ? const Color(0xFF2B1B35) : const Color(0xFFF3E5F5), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodHistoryPage())))),
      ]),
    ]);
  }

  Widget _actionTile(BuildContext context, String emoji, String title, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Text(emoji, style: const TextStyle(fontSize: 30)),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : Colors.black87))
            ])
        )
    );
  }

  Widget _buildTodayProgress(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('daily_tasks').doc("${user!.uid}_$today").snapshots(),
      builder: (context, snapshot) {
        int gCount = 0, jCount = 0, mCount = 0, aCount = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          gCount = data['games'] ?? 0; jCount = data['journal'] ?? 0; mCount = data['meditation'] ?? 0; aCount = data['articles'] ?? 0;
        }
        double progress = (gCount.clamp(0, 3) + jCount.clamp(0, 3) + mCount.clamp(0, 1) + aCount.clamp(0, 1)) / 8;
        return Container(
          padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 15)]),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Today Goal Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFF6B4CE6), fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 15),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, backgroundColor: isDark ? Colors.white10 : const Color(0xFFF0F0F0), color: const Color(0xFF6B4CE6), minHeight: 12)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _taskIcon(context, '🎮', gCount, 3, 'Games'), _taskIcon(context, '📝', jCount, 3, 'Journal'), _taskIcon(context, '🧘', mCount, 1, 'Zen'), _taskIcon(context, '📖', aCount, 1, 'Read')
            ]),
          ]),
        );
      },
    );
  }

  Widget _taskIcon(BuildContext context, String emoji, int count, int total, String label) {
    bool isDone = count >= total;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isDone ? const Color(0xFF6B4CE6).withOpacity(0.1) : (isDark ? Colors.white10 : Colors.grey.shade50), shape: BoxShape.circle, border: Border.all(color: isDone ? const Color(0xFF6B4CE6) : Colors.transparent, width: 2)),
        child: Opacity(opacity: isDone ? 1.0 : 0.4, child: Text(emoji, style: const TextStyle(fontSize: 22))),
      ),
      const SizedBox(height: 4),
      Text("$count/$total", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black)),
      Text(label, style: TextStyle(fontSize: 10, color: isDone ? (isDark ? Colors.white : Colors.black) : Colors.grey)),
    ]);
  }

  Widget _buildStreakOverlay(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent, body: Stack(children: [
      BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(color: Colors.black.withOpacity(0.85))),
      Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TweenAnimationBuilder(tween: Tween<double>(begin: 0, end: 1), duration: const Duration(seconds: 1), curve: Curves.elasticOut, builder: (context, double value, child) => Transform.scale(scale: value * 2.0, child: const Text('🔥', style: TextStyle(fontSize: 80)))),
        const SizedBox(height: 40),
        const Text("STREAK ON FIRE!", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        TweenAnimationBuilder(tween: IntTween(begin: 0, end: _currentStreakForAnimation), duration: const Duration(seconds: 2), builder: (context, int value, child) => Text("$value", style: const TextStyle(color: Colors.orangeAccent, fontSize: 100, fontWeight: FontWeight.w900))),
        const Text("DAYS STRONG", style: TextStyle(color: Colors.white70, fontSize: 18)),
      ])),
    ]));
  }

  Widget _buildTaskCelebration(BuildContext context, String message, String emoji) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(backgroundColor: Colors.transparent, body: Center(child: Container(margin: const EdgeInsets.symmetric(horizontal: 30), padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [Text(emoji, style: const TextStyle(fontSize: 80)), const SizedBox(height: 20), Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF6B4CE6)))]))));
  }

  List<Article> getRecommendedArticles() {
    if (selectedMood.isEmpty) return allArticles.take(4).toList();
    return allArticles.where((a) => a.moodTag == selectedMood).toList();
  }
}