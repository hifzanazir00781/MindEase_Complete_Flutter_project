import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class ForestGrowthGame extends StatefulWidget {
  const ForestGrowthGame({super.key});

  @override
  State<ForestGrowthGame> createState() => _ForestGrowthGameState();
}

class _ForestGrowthGameState extends State<ForestGrowthGame> {
  int _level = 1;
  int _dropsCollected = 0;
  int _targetDrops = 15;
  int _timeLeft = 30;
  bool _isGameOver = false;

  List<math.Point<double>> _rainDrops = [];
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    setState(() {
      _dropsCollected = 0;
      _timeLeft = 30;
      _targetDrops = 15 + (_level * 5);
      _isGameOver = false;
      _rainDrops.clear();
    });

    _gameTimer?.cancel();
    _spawnTimer?.cancel();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _checkGameOver();
          }
        });
      }
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted && !_isGameOver) {
        setState(() {
          _rainDrops.add(math.Point(_random.nextDouble() * 300, -50));
        });
      }
    });

    // Rain Movement
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _isGameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        for (int i = 0; i < _rainDrops.length; i++) {
          _rainDrops[i] = math.Point(_rainDrops[i].x, _rainDrops[i].y + 5);
        }
        _rainDrops.removeWhere((p) => p.y > 600);
      });
    });
  }

  void _checkGameOver() {
    if (_dropsCollected < _targetDrops) {
      _stopGame();
      // Icons.potted_plant ko local_florist se change kiya
      _showStatusDialog("Forest Withered", "Not enough water for the trees.", Icons.local_florist, false);
    }
  }

  void _stopGame() {
    setState(() => _isGameOver = true);
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
  }

  void _collectDrop(int index) {
    if (_isGameOver) return;
    HapticFeedback.lightImpact();
    setState(() {
      if(index < _rainDrops.length) _rainDrops.removeAt(index);
      _dropsCollected++;
    });

    if (_dropsCollected >= _targetDrops) {
      _stopGame();
      _showStatusDialog("Forest Bloom!", "You've grown a beautiful tree.", Icons.park, true);
    }
  }

  void _showStatusDialog(String title, String desc, IconData icon, bool next) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B3022),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Icon(icon, size: 60, color: Colors.greenAccent),
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
                if (next) _level++;
                _startLevel();
              },
              child: Text(next ? "Next Stage" : "Retry",
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double growthPercent = _dropsCollected / _targetDrops;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A120D) : const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: Text('Forest Growth - Stage $_level', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Stats
          Positioned(
            top: 20, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statChip(Icons.timer, "$_timeLeft s", Colors.orange),
                _statChip(Icons.water_drop, "$_dropsCollected/$_targetDrops", Colors.blue),
              ],
            ),
          ),

          // Rain Drops
          ..._rainDrops.asMap().entries.map((entry) {
            return Positioned(
              left: entry.value.x,
              top: entry.value.y,
              child: GestureDetector(
                onTap: () => _collectDrop(entry.key),
                child: const Icon(Icons.water_drop, color: Colors.blueAccent, size: 35),
              ),
            );
          }).toList(),

          // The Tree (Grows with collection)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              // Fixed: EdgeInsets.only use kiya
              padding: const EdgeInsets.only(bottom: 70),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 500),
                scale: 1.0 + (growthPercent * 0.5),
                child: Text(
                  _getTreeEmoji(),
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),
          ),

          // Ground
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                // withValues agar error de raha ho to .withOpacity use karein
                color: Colors.brown.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getTreeEmoji() {
    if (_dropsCollected < (_targetDrops * 0.3)) return '🌱';
    if (_dropsCollected < (_targetDrops * 0.7)) return '🌿';
    return _level % 2 == 0 ? '🌸' : '🌲';
  }

  Widget _statChip(IconData icon, String val, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: col),
          const SizedBox(width: 8),
          Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}