import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class AquaGuardianGame extends StatefulWidget {
  const AquaGuardianGame({super.key});

  @override
  State<AquaGuardianGame> createState() => _AquaGuardianGameState();
}

class _AquaGuardianGameState extends State<AquaGuardianGame> {
  int level = 1;
  int score = 0;
  int lives = 5;
  bool isPlaying = false;
  bool isSlowed = false; // Frost Power-up state

  Offset shieldPos = const Offset(200, 600);
  double oasisX = 200; // Moving plant position
  List<GameObject> objects = [];
  Timer? gameTimer;

  void startGame() {
    setState(() {
      score = 0;
      lives = 5;
      level = 1;
      objects.clear();
      isPlaying = true;
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateGame();
    });
  }

  void _updateGame() {
    if (!isPlaying) return;

    setState(() {
      // 1. Moving Oasis (Plant moves slowly)
      oasisX = 150 + 100 * math.sin(DateTime.now().millisecondsSinceEpoch / 1000);

      // 2. Spawn Logic (Rocks, Hearts, Frost)
      double spawnChance = 0.03 + (level * 0.01);
      if (math.Random().nextDouble() < spawnChance) {
        _spawnObject();
      }

      // 3. Object Physics and Collisions
      for (int i = objects.length - 1; i >= 0; i--) {
        double currentSpeed = isSlowed && objects[i].type == "rock"
            ? objects[i].speed * 0.3
            : objects[i].speed;

        objects[i].pos += Offset(0, currentSpeed);

        // Collision with Shield
        double dist = (objects[i].pos - shieldPos).distance;
        if (dist < 55) {
          _handleCollision(objects[i]);
          objects.removeAt(i);
          continue;
        }

        // Falling Out of Bounds
        if (objects[i].pos.dy > MediaQuery.of(context).size.height) {
          if (objects[i].type == "rock") {
            // Check if rock hit the Oasis (Plant)
            if ((objects[i].pos.dx - oasisX).abs() < 40) {
              lives--;
              if (lives <= 0) _endGame();
            }
          }
          objects.removeAt(i);
        }
      }
    });
  }

  void _spawnObject() {
    double rand = math.Random().nextDouble();
    String type = "rock";
    Color color = Colors.orange;

    if (rand > 0.95) { type = "heart"; color = Colors.pinkAccent; }
    else if (rand > 0.90) { type = "frost"; color = Colors.blueAccent; }

    objects.add(GameObject(
      pos: Offset(math.Random().nextDouble() * MediaQuery.of(context).size.width, -20),
      speed: (3 + math.Random().nextDouble() * 3) * (1 + level * 0.2),
      size: type == "rock" ? 15 + math.Random().nextDouble() * 10 : 20,
      type: type,
      color: color,
    ));
  }

  void _handleCollision(GameObject obj) {
    if (obj.type == "rock") {
      score += 10;
      if (score % 150 == 0) level++;
    } else if (obj.type == "heart") {
      if (lives < 5) lives++;
    } else if (obj.type == "frost") {
      _activateFrost();
    }
  }

  void _activateFrost() {
    isSlowed = true;
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => isSlowed = false);
    });
  }

  void _endGame() {
    gameTimer?.cancel();
    isPlaying = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("Game Over! 🏜️", style: TextStyle(color: Colors.white)),
        content: Text("The Oasis withered at Level $level.\nScore: $score"),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); startGame(); },
              child: const Text("Try Again", style: TextStyle(color: Colors.cyanAccent)))
        ],
      ),
    );
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
        onPanUpdate: (details) => setState(() => shieldPos = details.localPosition),
        child: Stack(
          children: [
            // Oasis (The moving plant you must protect)
            Positioned(
              bottom: 20,
              left: oasisX,
              child: const Text("🌿", style: TextStyle(fontSize: 50)),
            ),

            CustomPaint(
              painter: AquaPainter(objects: objects, shieldPos: shieldPos, isSlowed: isSlowed),
              size: Size.infinite,
            ),

            // UI
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _topStat("LVL", level.toString(), Colors.cyanAccent),
                    _topStat("LIVES", "❤️" * lives, Colors.redAccent),
                    _topStat("SCORE", score.toString(), Colors.amberAccent),
                  ],
                ),
              ),
            ),

            if (!isPlaying)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("SHIELD THE OASIS", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: startGame,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                      child: const Text("START GAME", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _topStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}

class GameObject {
  Offset pos; double speed; double size; String type; Color color;
  GameObject({required this.pos, required this.speed, required this.size, required this.type, required this.color});
}

class AquaPainter extends CustomPainter {
  final List<GameObject> objects;
  final Offset shieldPos;
  final bool isSlowed;
  AquaPainter({required this.objects, required this.shieldPos, required this.isSlowed});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Objects
    for (var obj in objects) {
      final paint = Paint()..color = obj.color;
      if (obj.type == "rock") {
        paint.shader = RadialGradient(colors: [obj.color, Colors.red]).createShader(Rect.fromCircle(center: obj.pos, radius: obj.size));
      }
      canvas.drawCircle(obj.pos, obj.size, paint);

      // Glow for power-ups
      if (obj.type != "rock") {
        canvas.drawCircle(obj.pos, obj.size + 5, Paint()..color = obj.color.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      }
    }

    // Draw Shield
    final shieldPaint = Paint()
      ..color = isSlowed ? Colors.blueAccent.withOpacity(0.5) : Colors.cyanAccent.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(shieldPos, 50, shieldPaint);
    canvas.drawCircle(shieldPos, 50, Paint()..color = isSlowed ? Colors.blue : Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}