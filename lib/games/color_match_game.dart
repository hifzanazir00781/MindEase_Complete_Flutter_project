import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/services.dart';

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> with SingleTickerProviderStateMixin {
  // Vibrant Zen Palette
  final List<Color> _allColors = [
    const Color(0xFFFF6B9D), const Color(0xFF6B4CE6),
    const Color(0xFF9BE9A8), const Color(0xFFFFC75F),
    const Color(0xFF94C5F8), const Color(0xFF4DB6AC),
    const Color(0xFFE91E63), const Color(0xFF00BCD4),
    const Color(0xFFFF5722), const Color(0xFF8BC34A),
  ];

  late List<Color> _currentOptions;
  late Color _targetColor;
  int _score = 0;
  int _level = 1;
  int _timeLeft = 15;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startNewGame();
  }

  void _startNewGame() {
    _score = 0;
    _level = 1;
    _nextRound();
  }

  void _nextRound() {
    _timer?.cancel();
    _timeLeft = _level < 5 ? 15 : 10; // Level 5 ke baad time kam ho jayega

    // Level ke hisab se colors ki tadad
    int colorCount = (_level < 3) ? 4 : (_level < 6 ? 6 : 9);
    _currentOptions = List.from(_allColors)..shuffle();
    _currentOptions = _currentOptions.take(colorCount).toList();
    _targetColor = _currentOptions[math.Random().nextInt(_currentOptions.length)];

    setState(() {});
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);
        } else {
          _timer?.cancel();
          _showGameOver();
        }
      }
    });
  }

  void _handleColorTap(Color selectedColor) {
    if (selectedColor == _targetColor) {
      HapticFeedback.lightImpact();
      _score += 10;
      // Har 30 points par level up
      if (_score % 30 == 0) {
        _level++;
      }
      _nextRound();
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _score = math.max(0, _score - 5);
        _timeLeft = math.max(0, _timeLeft - 2); // Galat answer par penalty
      });
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Focus Broken', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('You reached Level $_level with a score of $_score.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: const Text('Try Again', style: TextStyle(color: Color(0xFF6B4CE6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text('Level $_level', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTopStats(isDark),
          const Spacer(),
          _buildTargetCircle(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Text('Find the matching aura', style: TextStyle(fontSize: 16, color: Colors.grey, letterSpacing: 1.2)),
          ),
          _buildColorGrid(),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildTopStats(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem('Score', '$_score', Colors.blue),
          _statItem('Time', '${_timeLeft}s', _timeLeft < 5 ? Colors.red : Colors.orange),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTargetCircle() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.05).animate(_pulseController),
        child: Container(
          width: 140, height: 140,
          decoration: BoxDecoration(
            color: _targetColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: _targetColor.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10),
              BoxShadow(color: Colors.white.withValues(alpha: 0.2), offset: const Offset(-5, -5), blurRadius: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: _currentOptions.map((color) => GestureDetector(
          onTap: () => _handleColorTap(color),
          child: Container(
            width: 75, height: 75,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}