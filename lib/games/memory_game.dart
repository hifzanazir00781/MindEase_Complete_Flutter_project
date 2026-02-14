import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  int _gridSize = 4;
  int _timeLeft = 60;
  int _hintsLeft = 2;
  bool _gameStarted = false;

  final List<String> _allEmojis = ['🧘', '🍵', '🕯️', '🌿', '☁️', '🌙', '🌊', '🌸', '🏮', '🎐', '🎋', '🕉️'];
  late List<String> _gameBoard;
  late List<bool> _cardFlips;
  late List<bool> _matchedCards;

  int? _previousIndex;
  bool _isProcessing = false;
  int _score = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupGame(4);
  }

  void _setupGame(int size) {
    _gridSize = size;
    int pairsNeeded = (size * size) ~/ 2;
    List<String> selectedEmojis = _allEmojis.take(pairsNeeded).toList();

    _gameBoard = [...selectedEmojis, ...selectedEmojis];
    _gameBoard.shuffle();
    _cardFlips = List.generate(_gameBoard.length, (_) => false);
    _matchedCards = List.generate(_gameBoard.length, (_) => false);
    _score = 0;
    _timeLeft = size == 3 ? 40 : (size == 4 ? 60 : 90);
    _hintsLeft = size == 3 ? 1 : 2;
    _previousIndex = null;
    _isProcessing = false;
    _gameStarted = false;
    _timer?.cancel();
    setState(() {});
  }

  void _startTimer() {
    _gameStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _showEndDialog(false);
      }
    });
  }

  void _useHint() {
    if (_hintsLeft > 0 && !_isProcessing) {
      HapticFeedback.mediumImpact();
      setState(() {
        _hintsLeft--;
        _isProcessing = true;
        List<bool> oldFlips = List.from(_cardFlips);
        _cardFlips = List.generate(_cardFlips.length, (i) => !_matchedCards[i]);

        Timer(const Duration(seconds: 1), () {
          setState(() {
            _cardFlips = oldFlips;
            _isProcessing = false;
          });
        });
      });
    }
  }

  void _onCardTap(int index) {
    if (!_gameStarted) _startTimer();
    if (_isProcessing || _cardFlips[index] || _matchedCards[index]) return;

    HapticFeedback.selectionClick();
    setState(() => _cardFlips[index] = true);

    if (_previousIndex == null) {
      _previousIndex = index;
    } else {
      _isProcessing = true;
      if (_gameBoard[_previousIndex!] == _gameBoard[index]) {
        setState(() {
          _matchedCards[_previousIndex!] = true;
          _matchedCards[index] = true;
          _score++;
          _previousIndex = null;
          _isProcessing = false;
        });
        if (_score == _gameBoard.length ~/ 2) {
          _timer?.cancel();
          _showEndDialog(true);
        }
      } else {
        Timer(const Duration(milliseconds: 600), () {
          setState(() {
            _cardFlips[_previousIndex!] = false;
            _cardFlips[index] = false;
            _previousIndex = null;
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _showEndDialog(bool win) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: win ? Colors.green : Colors.red, width: 2)
        ),
        title: Text(win ? '🌟 Inner Peace Found' : '⏳ Mind Drifted',
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        content: Text(win ? 'Your focus is sharp. All symbols are in harmony.' : 'The time slipped away. Take a breath and try again.',
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () { Navigator.pop(context); _setupGame(_gridSize); },
              child: const Text('Try Again', style: TextStyle(color: Color(0xFF6B4CE6)))
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Zen Match', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(Icons.remove_red_eye, color: _hintsLeft > 0 ? const Color(0xFF6B4CE6) : Colors.grey),
              onPressed: _useHint
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsRow(isDark),
          _buildDifficultySelector(isDark),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridSize,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10
              ),
              itemCount: _gameBoard.length,
              itemBuilder: (context, index) => _buildCard(index, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoChip(Icons.timer, '$_timeLeft s', Colors.orange),
          _infoChip(Icons.lightbulb, 'Hints: $_hintsLeft', Colors.purple),
          _infoChip(Icons.star, '$_score', Colors.amber),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15)
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold))
      ]),
    );
  }

  Widget _buildDifficultySelector(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [3, 4].map((size) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ChoiceChip(
          label: Text(size == 3 ? 'Easy (3x3)' : 'Hard (4x4)'),
          selected: _gridSize == size,
          onSelected: (bool val) {
            if (val) _setupGame(size);
          },
          selectedColor: const Color(0xFF6B4CE6),
          labelStyle: TextStyle(color: _gridSize == size ? Colors.white : Colors.grey),
        ),
      )).toList(),
    );
  }

  Widget _buildCard(int index, bool isDark) {
    bool revealed = _cardFlips[index] || _matchedCards[index];
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: revealed ? (isDark ? const Color(0xFF1E1E2E) : Colors.white) : const Color(0xFF6B4CE6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _matchedCards[index] ? Colors.green : Colors.transparent, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Center(
          child: Text(revealed ? _gameBoard[index] : '?',
              style: TextStyle(
                  fontSize: _gridSize == 3 ? 40 : 30,
                  color: revealed ? (isDark ? Colors.white : Colors.black) : Colors.white
              )),
        ),
      ),
    );
  }
}