import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class StressBoxGame extends StatefulWidget {
  const StressBoxGame({super.key});

  @override
  State<StressBoxGame> createState() => _StressBoxGameState();
}

class _StressBoxGameState extends State<StressBoxGame> {
  int _score = 0;
  int _health = 3;
  int _level = 1;
  final List<StressProblem> _problems = [];
  final List<PositivityBullet> _bullets = [];
  Timer? _gameLoop;
  bool _isGameOver = false;

  final List<String> _stressNames = [
    "Family Issues", "Tensions", "Anxiety", "Sadness", "Work Load", "Failure", "Overthinking"
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _health = 3;
    _problems.clear();
    _bullets.clear();
    _isGameOver = false;
    _gameLoop?.cancel();

    _gameLoop = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      _updateGame();
    });
  }

  void _updateGame() {
    setState(() {
      // 1. Problems ko niche lao
      for (var p in _problems) {
        p.y += 2 + (_level * 0.5);
      }

      // 2. Bullets ko oopar bhejo
      for (var b in _bullets) {
        b.y -= 10;
      }

      // 3. Spawning (Nayi problem paida karna)
      if (math.Random().nextInt(40) == 1) {
        _problems.add(StressProblem(
          name: _stressNames[math.Random().nextInt(_stressNames.length)],
          x: math.Random().nextDouble() * 300 + 20,
          y: -50,
        ));
      }

      // 4. Collision Detection (Bullet vs Problem)
      for (int i = _bullets.length - 1; i >= 0; i--) {
        for (int j = _problems.length - 1; j >= 0; j--) {
          double dist = (Offset(_bullets[i].x, _bullets[i].y) - Offset(_problems[j].x, _problems[j].y)).distance;
          if (dist < 30) {
            _bullets.removeAt(i);
            _problems.removeAt(j);
            _score += 10;
            HapticFeedback.lightImpact();
            if (_score >= _level * 100) _nextLevel();
            break;
          }
        }
      }

      // 5. Health Loss (Agar problem niche tak pohanch jaye)
      _problems.removeWhere((p) {
        if (p.y > MediaQuery.of(context).size.height - 100) {
          _health--;
          HapticFeedback.vibrate();
          if (_health <= 0) _endGame();
          return true;
        }
        return false;
      });
    });
  }

  void _nextLevel() {
    setState(() {
      _level++;
      _score = 0; // Score reset for next level challenge
    });
  }

  void _endGame() {
    _isGameOver = true;
    _gameLoop?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Game Over", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("Don't let the stress win! You fought well.\nFinal Level: $_level", style: const TextStyle(color: Colors.white70)),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              onPressed: () {
                Navigator.pop(context);
                _startGame();
              },
              child: const Text("FIGHT AGAIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _shoot(TapDownDetails details) {
    if (_isGameOver) return;
    setState(() {
      _bullets.add(PositivityBullet(x: details.localPosition.dx, y: MediaQuery.of(context).size.height - 150));
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12), // Dark Mystery Theme
      appBar: AppBar(
        title: Text("Positivity Warrior - Lvl $_level", style: const TextStyle(color: Colors.cyanAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTapDown: _shoot,
        child: Stack(
          children: [
            // Stars Background (Visual effect)
            ...List.generate(20, (i) => Positioned(
              left: math.Random().nextDouble() * 400,
              top: math.Random().nextDouble() * 800,
              child: Icon(Icons.star, size: 2, color: Colors.white.withValues(alpha: 0.2)),
            )),

            // Drawing Problems
            ..._problems.map((p) => Positioned(
              left: p.x - 40,
              top: p.y,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.redAccent, width: 1),
                ),
                child: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            )),

            // Drawing Bullets
            ..._bullets.map((b) => Positioned(
              left: b.x - 5,
              top: b.y,
              child: Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.cyanAccent, blurRadius: 10)]),
              ),
            )),

            // Player Shield
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 10, width: 100,
                decoration: BoxDecoration(color: Colors.cyanAccent, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.5), blurRadius: 20)]),
              ),
            ),

            // Health and Score UI
            Positioned(
              top: 20, left: 20,
              child: Row(
                children: List.generate(3, (index) => Icon(
                  index < _health ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                )),
              ),
            ),
            Positioned(
              top: 20, right: 20,
              child: Text("Score: $_score", style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class StressProblem {
  String name; double x, y;
  StressProblem({required this.name, required this.x, required this.y});
}

class PositivityBullet {
  double x, y;
  PositivityBullet({required this.x, required this.y});
}