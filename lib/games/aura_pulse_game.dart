import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class NeonOdysseyGame extends StatefulWidget {
  const NeonOdysseyGame({super.key});

  @override
  State<NeonOdysseyGame> createState() => _NeonOdysseyGameState();
}

class _NeonOdysseyGameState extends State<NeonOdysseyGame> {
  // Game Stats
  int level = 1;
  int score = 0;
  int health = 3;
  bool isPlaying = false;
  String gameStatus = "TAP TO START";

  // Player & Game Objects
  Offset ballPos = const Offset(0, 200);
  List<GameObject> objects = [];
  Timer? gameTimer;
  late math.Random random;

  @override
  void initState() {
    super.initState();
    random = math.Random();
  }

  void _startGame() {
    setState(() {
      score = 0;
      level = 1;
      health = 3;
      isPlaying = true;
      ballPos = const Offset(0, 200);
      objects.clear();
    });
    _nextChallenge();
  }

  void _nextChallenge() {
    objects.clear();
    // Level ke hisab se objects spawn karna
    int count = 5 + (level * 2);
    for (int i = 0; i < count; i++) {
      objects.add(GameObject(
        pos: Offset(random.nextDouble() * 300 - 150, -400.0 - (i * 200)),
        type: level % 2 == 0 ? "enemy" : "star",
        speed: 2.0 + (level * 0.5),
      ));
    }
    _runGameLoop();
  }

  void _runGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isPlaying) return;

      setState(() {
        for (var i = objects.length - 1; i >= 0; i--) {
          // Move objects down
          objects[i].pos = Offset(objects[i].pos.dx, objects[i].pos.dy + objects[i].speed);

          // Collision Check
          double distance = (ballPos - objects[i].pos).distance;
          if (distance < 40) {
            if (objects[i].type == "star") {
              score += 10;
              objects.removeAt(i);
            } else {
              health--;
              objects.removeAt(i);
              if (health <= 0) _gameOver();
            }
            continue;
          }

          // Boundary Check (Screen se bahar nikalna)
          if (objects[i].pos.dy > 400) {
            if (objects[i].type == "star" && level % 2 != 0) {
              // Star miss hone par penalty (Optional)
            }
            objects.removeAt(i);
          }
        }

        // Win Condition: Saare objects khatam ho gaye
        if (objects.isEmpty && isPlaying) {
          level++;
          _nextChallenge();
        }
      });
    });
  }

  void _gameOver() {
    gameTimer?.cancel();
    setState(() {
      isPlaying = false;
      gameStatus = "GAME OVER! Final Score: $score";
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (isPlaying) {
            setState(() {
              // Ball ko screen ke borders ke andar rakhna
              double newX = (ballPos.dx + details.delta.dx).clamp(-150.0, 150.0);
              double newY = (ballPos.dy + details.delta.dy).clamp(-300.0, 300.0);
              ballPos = Offset(newX, newY);
            });
          }
        },
        child: Stack(
          children: [
            // Stars Background Effect
            const Positioned.fill(child: StarBackground()),

            // Game UI
            _buildHeader(),

            // Game Objects & Player
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ...objects.map((obj) => _drawObject(obj)),

                  // Player (Neon Ball)
                  Transform.translate(
                    offset: ballPos,
                    child: _buildPlayer(),
                  ),
                ],
              ),
            ),

            // Start/Over Overlay
            if (!isPlaying) _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return Container(
      width: 45, height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.cyanAccent,
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: const Icon(Icons.rocket_launch, color: Colors.black, size: 20),
    );
  }

  Widget _drawObject(GameObject obj) {
    return Transform.translate(
      offset: obj.pos,
      child: Icon(
        obj.type == "star" ? Icons.stars : Icons.coronavirus,
        color: obj.type == "star" ? Colors.yellowAccent : Colors.redAccent,
        size: 40,
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statTile("LEVEL", level.toString(), Colors.white),
            _statTile("HEALTH", "❤️" * health, Colors.redAccent),
            _statTile("SCORE", score.toString(), Colors.cyanAccent),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.5), fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyanAccent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(gameStatus, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              child: const Text("PLAY NOW", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

class GameObject {
  Offset pos;
  String type;
  double speed;
  GameObject({required this.pos, required this.type, required this.speed});
}

class StarBackground extends StatelessWidget {
  const StarBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter());
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3);
    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), 1, paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}