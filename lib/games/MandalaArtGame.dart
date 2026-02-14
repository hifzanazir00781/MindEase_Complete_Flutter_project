import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'dart:async';

class MandalaGame extends StatefulWidget {
  const MandalaGame({super.key});

  @override
  State<MandalaGame> createState() => _MandalaGameState();
}

class _MandalaGameState extends State<MandalaGame> with SingleTickerProviderStateMixin {
  final List<Color> _palette = [
    Colors.amber, Colors.pinkAccent, Colors.cyanAccent, Colors.limeAccent, Colors.purpleAccent
  ];

  Color _selectedColor = Colors.amber;
  int _level = 1;
  int _lives = 3;
  Map<int, Color> _layerColors = {};
  late AnimationController _pulseController;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  void _paintLayer(int layerIndex) {
    if (_isGameOver) return;

    setState(() {
      // Out Concept: Agar layer pehle se rang chuki hai to Life kam hogi
      if (_layerColors.containsKey(layerIndex)) {
        _reduceLife("Layer already filled!");
        return;
      }

      // Timing Logic: Pulse level ke mutabiq check (Simple challenge)
      _layerColors[layerIndex] = _selectedColor;
      HapticFeedback.mediumImpact();

      if (_layerColors.length >= 3) {
        _showGameOver(true);
      }
    });
  }

  void _reduceLife(String reason) {
    HapticFeedback.vibrate();
    setState(() {
      _lives--;
      if (_lives <= 0) {
        _showGameOver(false);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(reason), duration: const Duration(milliseconds: 500), backgroundColor: Colors.redAccent),
    );
  }

  void _showGameOver(bool won) {
    _isGameOver = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(won ? "Masterpiece Ready! ✨" : "Zen Broken 💔",
            style: TextStyle(color: won ? Colors.cyanAccent : Colors.redAccent)),
        content: Text(won ? "You maintained perfect focus." : "You lost your concentration."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (won) _level++;
                _lives = 3;
                _layerColors.clear();
                _isGameOver = false;
              });
            },
            child: Text(won ? "Next Level" : "Try Again", style: const TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('Zen Mandala - Lvl $_level', style: const TextStyle(color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: List.generate(3, (i) => Icon(
                i < _lives ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent, size: 20,
              )),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Pulse Ring
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 100 + (_pulseController.value * 200),
                        height: 100 + (_pulseController.value * 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                        ),
                      );
                    },
                  ),
                  _buildMandalaLayer(radius: 140, segments: 12, layerIndex: 3),
                  _buildMandalaLayer(radius: 90, segments: 8, layerIndex: 2),
                  _buildMandalaLayer(radius: 40, segments: 6, layerIndex: 1),
                ],
              ),
            ),
          ),
          _buildColorPicker(),
        ],
      ),
    );
  }

  Widget _buildMandalaLayer({required double radius, required int segments, required int layerIndex}) {
    return GestureDetector(
      onTap: () => _paintLayer(layerIndex),
      child: CustomPaint(
        size: Size(radius * 2, radius * 2),
        painter: SymmetryPainter(
          segments: segments,
          color: _layerColors[layerIndex] ?? Colors.white.withValues(alpha: 0.05),
          radius: radius,
          isFilled: _layerColors.containsKey(layerIndex),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      color: const Color(0xFF151515),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _palette.map((color) => GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 45, height: 45,
            decoration: BoxDecoration(
              color: color, shape: BoxShape.circle,
              border: _selectedColor == color ? Border.all(color: Colors.white, width: 3) : null,
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class SymmetryPainter extends CustomPainter {
  final int segments; final Color color; final double radius; final bool isFilled;
  SymmetryPainter({required this.segments, required this.color, required this.radius, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke..strokeWidth = 2.0;
    for (int i = 0; i < segments; i++) {
      double angle = (2 * math.pi / segments) * i;
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(angle);
      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(radius / 2, -radius, 0, -radius);
      path.quadraticBezierTo(-radius / 2, -radius, 0, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => true;
}