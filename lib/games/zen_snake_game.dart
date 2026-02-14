import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';

class ZenSnakeGame extends StatefulWidget {
  const ZenSnakeGame({super.key});

  @override
  State<ZenSnakeGame> createState() => _ZenSnakeGameState();
}

enum Direction { up, down, left, right }

class _ZenSnakeGameState extends State<ZenSnakeGame> {
  // Game Settings
  static const int _gridSize = 20;
  List<Offset> _snake = [const Offset(10, 10), const Offset(10, 11)];
  Offset _food = const Offset(5, 5);
  Direction _direction = Direction.up;
  Timer? _gameTimer;
  int _score = 0;
  int _level = 1;
  bool _isGameOver = false;
  double _speed = 250; // Milliseconds

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _snake = [const Offset(10, 10), const Offset(10, 11)];
    _direction = Direction.up;
    _score = 0;
    _isGameOver = false;
    _speed = 250;
    _spawnFood();
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(Duration(milliseconds: _speed.toInt()), (timer) {
      _moveSnake();
    });
  }

  void _spawnFood() {
    _food = Offset(
      Random().nextInt(_gridSize).toDouble(),
      Random().nextInt(_gridSize).toDouble(),
    );
  }

  void _moveSnake() {
    if (_isGameOver) return;

    setState(() {
      Offset newHead;
      switch (_direction) {
        case Direction.up: newHead = Offset(_snake.first.dx, _snake.first.dy - 1); break;
        case Direction.down: newHead = Offset(_snake.first.dx, _snake.first.dy + 1); break;
        case Direction.left: newHead = Offset(_snake.first.dx - 1, _snake.first.dy); break;
        case Direction.right: newHead = Offset(_snake.first.dx + 1, _snake.first.dy); break;
      }

      // Check Collision (Wall or Self)
      if (newHead.dx < 0 || newHead.dx >= _gridSize ||
          newHead.dy < 0 || newHead.dy >= _gridSize ||
          _snake.contains(newHead)) {
        _endGame();
        return;
      }

      _snake.insert(0, newHead);

      // Check Food
      if (newHead == _food) {
        _score += 10;
        HapticFeedback.mediumImpact();
        _spawnFood();
        // Speed Increase on Level Up
        if (_score % 50 == 0) {
          _level++;
          _speed = (_speed * 0.9).clamp(100, 250);
          _gameTimer?.cancel();
          _gameTimer = Timer.periodic(Duration(milliseconds: _speed.toInt()), (t) => _moveSnake());
        }
      } else {
        _snake.removeLast();
      }
    });
  }

  void _endGame() {
    _isGameOver = true;
    _gameTimer?.cancel();
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Game Over", style: TextStyle(color: Colors.pinkAccent)),
        content: Text("Score: $_score\nLevel: $_level", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _startGame(); },
            child: const Text("Try Again", style: TextStyle(color: Colors.cyanAccent)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: Text('Zen Snake - Lvl $_level', style: const TextStyle(color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text("Score: $_score", style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          // Game Board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _gridSize),
                    itemCount: _gridSize * _gridSize,
                    itemBuilder: (context, index) {
                      Offset pos = Offset((index % _gridSize).toDouble(), (index ~/ _gridSize).toDouble());
                      bool isHead = _snake.first == pos;
                      bool isBody = _snake.contains(pos);
                      bool isFood = _food == pos;

                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: isFood
                              ? Colors.pinkAccent
                              : (isHead ? Colors.cyanAccent : (isBody ? Colors.cyanAccent.withValues(alpha: 0.4) : Colors.transparent)),
                          shape: isFood ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius: isBody ? BorderRadius.circular(2) : null,
                          boxShadow: isFood || isHead ? [BoxShadow(color: isFood ? Colors.pinkAccent : Colors.cyanAccent, blurRadius: 5)] : [],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Controls
          _buildControls(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, size: 50, color: Colors.white38),
          onPressed: () { if (_direction != Direction.down) _direction = Direction.up; },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left, size: 50, color: Colors.white38),
              onPressed: () { if (_direction != Direction.right) _direction = Direction.left; },
            ),
            const SizedBox(width: 50),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right, size: 50, color: Colors.white38),
              onPressed: () { if (_direction != Direction.left) _direction = Direction.right; },
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 50, color: Colors.white38),
          onPressed: () { if (_direction != Direction.up) _direction = Direction.down; },
        ),
      ],
    );
  }
}