import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class ZenFlowGame extends StatefulWidget {
  const ZenFlowGame({super.key});

  @override
  State<ZenFlowGame> createState() => _ZenFlowGameState();
}

class _ZenFlowGameState extends State<ZenFlowGame> {
  int _level = 1;
  final List<int> _sequence = [];
  final List<int> _userSequence = [];
  bool _isShowingSequence = false;
  int _score = 0;
  int _activeDot = -1;

  @override
  void initState() {
    super.initState();
    _startNewLevel();
  }

  void _startNewLevel() {
    _userSequence.clear();
    _sequence.clear();
    int sequenceLength = 2 + _level;

    for (int i = 0; i < sequenceLength; i++) {
      _sequence.add(math.Random().nextInt(9));
    }

    _showSequence();
  }

  Future<void> _showSequence() async {
    if (!mounted) return;
    setState(() => _isShowingSequence = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    for (int step in _sequence) {
      if (!mounted) return;
      setState(() => _activeDot = step);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _activeDot = -1);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (mounted) setState(() => _isShowingSequence = false);
  }

  void _handleTap(int index) {
    if (_isShowingSequence) return;

    HapticFeedback.lightImpact();
    setState(() => _userSequence.add(index));

    if (_userSequence.last != _sequence[_userSequence.length - 1]) {
      _gameOver();
      return;
    }

    if (_userSequence.length == _sequence.length) {
      _levelUp();
    }
  }

  void _levelUp() {
    _score += 10 * _level;
    // Standard haptic feedback use kiya hai
    HapticFeedback.mediumImpact();
    _showStatusDialog("Sequence Matched!", "Level $_level Complete.", Icons.check_circle, true);
  }

  void _gameOver() {
    HapticFeedback.vibrate();
    _showStatusDialog("Flow Broken", "Try again to focus.", Icons.error_outline, false);
  }

  void _showStatusDialog(String title, String desc, IconData icon, bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(icon, size: 50, color: won ? Colors.cyanAccent : Colors.pinkAccent),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (won) {
                  setState(() => _level++);
                } else {
                  setState(() {
                    _level = 1;
                    _score = 0;
                  });
                }
                _startNewLevel();
              },
              child: Text(won ? "Next Level" : "Restart",
                  style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Zen Flow', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Level: $_level  |  Score: $_score", style: const TextStyle(color: Colors.cyanAccent, fontSize: 18)),
          const SizedBox(height: 20),
          Text(
            _isShowingSequence ? "Watch the Pattern..." : "Repeat the Sequence",
            style: TextStyle(color: _isShowingSequence ? Colors.orangeAccent : Colors.white54),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 20
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                bool isActive = _activeDot == index;
                return GestureDetector(
                  onTap: () => _handleTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.05),
                      boxShadow: isActive ? [
                        BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 5)
                      ] : [],
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Center(
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 60),
          // FIX: Image 7 ka error yahan tha. 'const' hataya gaya hai.
          if (!_isShowingSequence)
            Text("${_userSequence.length} / ${_sequence.length}",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.24), fontSize: 24)),
        ],
      ),
    );
  }
}