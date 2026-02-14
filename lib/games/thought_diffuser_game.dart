import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class ThoughtDiffuserGame extends StatefulWidget {
  const ThoughtDiffuserGame({super.key});

  @override
  State<ThoughtDiffuserGame> createState() => _ThoughtDiffuserGameState();
}

class _ThoughtDiffuserGameState extends State<ThoughtDiffuserGame> {
  int _level = 1;
  int _timeLeft = 20;
  List<CloudModel> _clouds = [];
  Timer? _timer;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewLevel();
  }

  void _startNewLevel() {
    _isGameOver = false;
    _timeLeft = 20 - (_level > 10 ? 10 : _level); // Level ke sath waqt kam hoga
    _clouds = List.generate(5 + _level, (index) => CloudModel(
      id: index,
      offset: Offset(
        math.Random().nextDouble() * 250 + 50,
        math.Random().nextDouble() * 400 + 100,
      ),
      size: math.Random().nextDouble() * 60 + 60,
    ));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            if (_clouds.isNotEmpty) _endGame(false);
          }
        });
      }
    });
  }

  void _diffuseCloud(int id) {
    if (_isGameOver) return;
    HapticFeedback.lightImpact(); // Soft touch feel
    setState(() {
      _clouds.removeWhere((c) => c.id == id);
      if (_clouds.isEmpty) _endGame(true);
    });
  }

  void _endGame(bool won) {
    _isGameOver = true;
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: won ? const Color(0xFFE3F2FD) : const Color(0xFF37474F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Icon(won ? Icons.wb_sunny : Icons.cloud_off,
            size: 60, color: won ? Colors.orange : Colors.grey),
        content: Text(
          won ? "Clear Sky! Level $_level Complete." : "The sky is too heavy. Take a deep breath.",
          textAlign: TextAlign.center,
          style: TextStyle(color: won ? Colors.black87 : Colors.white),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (won) _level++;
                _startNewLevel();
              },
              child: Text(won ? "NEXT CLOUD" : "RETRY",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF81D4FA), // Calm Sky Blue
      body: Stack(
        children: [
          // The Background Sun
          const Center(
            child: Icon(Icons.wb_sunny, size: 250, color: Color(0xFFFFE082)),
          ),

          // Cloud Layer
          ..._clouds.map((cloud) => Positioned(
            left: cloud.offset.dx,
            top: cloud.offset.dy,
            child: GestureDetector(
              onTap: () => _diffuseCloud(cloud.id),
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 500),
                tween: Tween<double>(begin: 0.8, end: 1.0),
                builder: (context, double scale, child) => Transform.scale(
                  scale: scale,
                  child: Icon(Icons.cloud, size: cloud.size, color: Colors.white.withOpacity(0.9)),
                ),
              ),
            ),
          )),

          // UI Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statWidget(Icons.timer_outlined, "$_timeLeft s", Colors.redAccent),
                  Text("Lvl $_level", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  _statWidget(Icons.cloud_done_outlined, "${_clouds.length}", Colors.white),
                ],
              ),
            ),
          ),

          const Positioned(
            bottom: 40, left: 0, right: 0,
            child: Center(
              child: Text("Tap clouds to find your inner sun",
                  style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statWidget(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CloudModel {
  final int id;
  final Offset offset;
  final double size;
  CloudModel({required this.id, required this.offset, required this.size});
}