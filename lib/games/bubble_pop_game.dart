import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class BubblePopGame extends StatefulWidget {
  const BubblePopGame({super.key});

  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _BubblePopGameState extends State<BubblePopGame> {
  int _score = 0;
  int _level = 1;
  int _tapsRemaining = 20; // Win/Loss condition
  int _targetBubbles = 10;
  int _bubblesPopped = 0;

  List<ZenBubbleData> _bubbles = [];
  Timer? _spawnTimer;
  Timer? _movementTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    setState(() {
      _bubblesPopped = 0;
      _tapsRemaining = 25 - (_level * 2); // Level barhte hi game mushkil hogi
      _targetBubbles = 10 + (_level * 3);
      _bubbles.clear();
    });

    _spawnTimer?.cancel();
    _movementTimer?.cancel();

    // Spawning logic
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (mounted && _bubbles.length < 10) {
        _createNewBubble();
      }
    });

    // Movement physics logic
    _movementTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          for (var b in _bubbles) {
            b.y -= b.speed; // Bubbles float upwards
            b.x += math.sin(b.y / 50) * 2; // Swaying motion
          }
          // Remove bubbles that go off screen
          _bubbles.removeWhere((b) => b.y < -100);
        });
      }
    });
  }

  void _createNewBubble() {
    setState(() {
      _bubbles.add(ZenBubbleData(
        x: _random.nextDouble() * 300,
        y: 600, // Starts from bottom
        size: 50 + _random.nextDouble() * 30,
        speed: 1.0 + (_level * 0.2), // Speed increases with level
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)].withValues(alpha: 0.5),
      ));
    });
  }

  void _popBubble(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _bubblesPopped++;
      _score += 10;
      _bubbles.removeAt(index);
    });

    if (_bubblesPopped >= _targetBubbles) {
      _winLevel();
    }
  }

  void _onScreenTap() {
    setState(() {
      _tapsRemaining--;
    });
    if (_tapsRemaining <= 0 && _bubblesPopped < _targetBubbles) {
      _gameOver();
    }
  }

  void _winLevel() {
    _stopTimers();
    _showStatusDialog("Level $_level Cleared!", "Your mind is getting clearer.", Icons.auto_awesome, () {
      setState(() => _level++);
      _startLevel();
      Navigator.pop(context);
    });
  }

  void _gameOver() {
    _stopTimers();
    _showStatusDialog("Out of Energy", "Take a deep breath and try again.", Icons.refresh, () {
      setState(() {
        _level = 1;
        _score = 0;
      });
      _startLevel();
      Navigator.pop(context);
    });
  }

  void _stopTimers() {
    _spawnTimer?.cancel();
    _movementTimer?.cancel();
  }

  void _showStatusDialog(String title, String desc, IconData icon, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        actions: [Center(child: TextButton(onPressed: onRetry, child: const Text("Continue", style: TextStyle(fontSize: 18))))],
      ),
    );
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F9FF),
      appBar: AppBar(
        title: Text('Zen Bubbles - Level $_level', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: _onScreenTap,
        child: Stack(
          children: [
            // Stats Panel
            Positioned(
              top: 20, left: 20, right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statWidget("Target", "$_bubblesPopped/$_targetBubbles", Colors.blue),
                  _statWidget("Taps", "$_tapsRemaining", _tapsRemaining < 5 ? Colors.red : Colors.green),
                ],
              ),
            ),

            // Floating Bubbles
            ..._bubbles.asMap().entries.map((entry) {
              int index = entry.key;
              ZenBubbleData b = entry.value;
              return Positioned(
                left: b.x,
                top: b.y,
                child: GestureDetector(
                  onTap: () => _popBubble(index),
                  child: _buildBubbleUI(b),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _statWidget(String label, String val, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: col.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text("$label: $val", style: TextStyle(color: col, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBubbleUI(ZenBubbleData b) {
    return Container(
      width: b.size,
      height: b.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.4), b.color],
          center: const Alignment(-0.3, -0.3),
        ),
        boxShadow: [BoxShadow(color: b.color.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: Center(
        child: Container(
          width: b.size * 0.2, height: b.size * 0.1,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class ZenBubbleData {
  double x, y, size, speed;
  Color color;
  ZenBubbleData({required this.x, required this.y, required this.size, required this.speed, required this.color});
}