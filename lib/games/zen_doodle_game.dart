import 'package:flutter/material.dart';
import 'dart:async';

class ZenGravityGame extends StatefulWidget {
  const ZenGravityGame({super.key});

  @override
  State<ZenGravityGame> createState() => _ZenGravityGameState();
}

class _ZenGravityGameState extends State<ZenGravityGame> {
  // --- Game State ---
  int currentLevel = 1;
  double inkLevel = 1.0;
  bool isPlaying = false;

  Offset ballPos = const Offset(50, 80);
  Offset ballVelocity = const Offset(0, 0);
  List<Offset> drawPoints = [];

  // --- Level Config ---
  Offset portalPos = const Offset(300, 600);
  List<Rect> obstacles = [];

  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    loadLevel(1);
  }

  void loadLevel(int level) {
    setState(() {
      currentLevel = level;
      inkLevel = 1.0;
      drawPoints.clear();
      ballPos = const Offset(50, 80);
      ballVelocity = const Offset(0, 0);
      isPlaying = false;

      // Levels Easy to Difficult
      if (level == 1) {
        portalPos = const Offset(300, 650);
        obstacles = [];
      } else if (level == 2) {
        portalPos = const Offset(100, 650);
        obstacles = [Rect.fromLTWH(80, 400, 250, 20)];
      } else if (level == 3) {
        portalPos = const Offset(200, 700);
        obstacles = [
          Rect.fromLTWH(30, 300, 150, 20),
          Rect.fromLTWH(200, 500, 150, 20)
        ];
      }
    });
  }

  void startGame() {
    if (gameTimer?.isActive ?? false) return;
    setState(() => isPlaying = true);
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updatePhysics();
    });
  }

  void updatePhysics() {
    setState(() {
      // 1. Gravity
      ballVelocity += const Offset(0, 0.5);
      ballPos += ballVelocity;

      // 2. Obstacle Collision
      for (var rect in obstacles) {
        if (rect.contains(ballPos)) {
          gameOver("Oops! Hit an obstacle. 💥");
          return;
        }
      }

      // 3. Line Collision
      for (int i = 0; i < drawPoints.length - 1; i++) {
        if ((ballPos - drawPoints[i]).distance < 15) {
          ballVelocity = Offset(ballVelocity.dx * 0.8 + 2, -ballVelocity.dy * 0.6);
          ballPos = Offset(ballPos.dx, drawPoints[i].dy - 16);
        }
      }

      // 4. Win / Lose Logic
      if ((ballPos - portalPos).distance < 40) {
        winGame();
      } else if (ballPos.dy > MediaQuery.of(context).size.height || ballPos.dx < 0 || ballPos.dx > MediaQuery.of(context).size.width) {
        gameOver("Lost in space! 🌌");
      }
    });
  }

  void winGame() {
    gameTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("Level Cleared! 🎉", style: TextStyle(color: Colors.cyanAccent)),
        content: Text("Amazing! Level $currentLevel complete."),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(ctx);
            loadLevel(currentLevel + 1);
          }, child: const Text("Next Level", style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  void gameOver(String msg) {
    gameTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("Game Over", style: TextStyle(color: Colors.redAccent)),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(ctx);
            loadLevel(currentLevel);
          }, child: const Text("Retry", style: TextStyle(color: Colors.white)))
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
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          // Background Glow - Error Fixed: Removed borderRadius to avoid conflict with BoxShape.circle
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.1),
              ),
            ),
          ),

          // --- TOP UI ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("LEVEL $currentLevel", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("INK", style: TextStyle(color: Colors.cyanAccent, fontSize: 10)),
                      const SizedBox(height: 5),
                      Container(
                        width: 100, height: 8,
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)),
                        child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: inkLevel.clamp(0.0, 1.0),
                            child: Container(decoration: BoxDecoration(color: Colors.cyanAccent, borderRadius: BorderRadius.circular(5)))
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // --- GAME AREA ---
          GestureDetector(
            onPanUpdate: (details) {
              if (isPlaying || inkLevel <= 0) return;
              setState(() {
                drawPoints.add(details.localPosition);
                inkLevel -= 0.005;
              });
            },
            child: CustomPaint(
                painter: GamePainter(points: drawPoints, portal: portalPos, ball: ballPos, obstacles: obstacles),
                size: Size.infinite
            ),
          ),

          // --- CONTROL BUTTON ---
          if (!isPlaying)
            Positioned(
              bottom: 40, left: 0, right: 0,
              child: Center(
                child: FloatingActionButton.extended(
                  onPressed: startGame,
                  backgroundColor: Colors.cyanAccent,
                  label: const Text("RELEASE BALL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<Offset> points;
  final Offset portal;
  final Offset ball;
  final List<Rect> obstacles;

  GamePainter({required this.points, required this.portal, required this.ball, required this.obstacles});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Portal
    final portalPaint = Paint()
      ..shader = const RadialGradient(colors: [Colors.purpleAccent, Colors.transparent]).createShader(Rect.fromCircle(center: portal, radius: 40));
    canvas.drawCircle(portal, 40, portalPaint);
    canvas.drawCircle(portal, 15, Paint()..color = Colors.white.withOpacity(0.5));

    // 2. Obstacles
    final obsPaint = Paint()..color = Colors.redAccent.withOpacity(0.7);
    for (var rect in obstacles) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), obsPaint);
    }

    // 3. Lines
    final linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // 4. Ball
    canvas.drawCircle(ball, 14, Paint()..color = Colors.cyanAccent.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawCircle(ball, 10, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}