import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

//////////////////////// SOUNDS SCREEN ////////////////////////
class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  _SoundsScreenState createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final List<Map<String, dynamic>> sounds = [
    {'name': 'Rain Sounds', 'emoji': '🌧️', 'color': const Color(0xFF94C5F8), 'file': 'rain.mp3'},
    {'name': 'Ocean Waves', 'emoji': '🌊', 'color': const Color(0xFF6B9BD1), 'file': 'ocean.mp3'},
    {'name': 'Forest Birds', 'emoji': '🌲', 'color': const Color(0xFF9BE9A8), 'file': 'forest.mp3'},
    {'name': 'Night Crickets', 'emoji': '🦗', 'color': const Color(0xFF8B7FB8), 'file': 'cricket.mp3'},
    {'name': 'Peaceful Piano', 'emoji': '🎹', 'color': const Color(0xFFB4A7D6), 'file': 'piano.mp3'},
    {'name': 'Wind Chimes', 'emoji': '🎐', 'color': const Color(0xFFFFC75F), 'file': 'chimes.mp3'},
  ];

  AudioPlayer? _audioPlayer;
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _togglePlayPause(int index) async {
    if (_currentlyPlayingIndex == index && _isPlaying) {
      await _audioPlayer!.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer!.stop();
      await _audioPlayer!.play(
        AssetSource('sounds/${sounds[index]['file']}'),
      );

      setState(() {
        _currentlyPlayingIndex = index;
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Colors fetch karna
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = Theme.of(context).cardColor;
    final mainTextColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      // Background color main.dart se automatically aayega
      appBar: AppBar(
        title: const Text('Peaceful Sounds', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // AppBar ka icon aur text color automatic change hoga
        foregroundColor: mainTextColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          bool isCurrentlyPlaying = _currentlyPlayingIndex == index && _isPlaying;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // CHANGE: Hardcoded Colors.white ki jagah dynamic cardColor
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black38 : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    // Dark mode mein opacity thori kam rakhi hai taake sukoon de
                    color: sounds[index]['color'].withOpacity(isDark ? 0.15 : 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      sounds[index]['emoji'],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    sounds[index]['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // CHANGE: Hardcoded color ki jagah dynamic text color
                      color: mainTextColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isCurrentlyPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 40,
                  ),
                  // Button ka color wahi rahega jo sound ka hai, ye professional lagta hai
                  color: sounds[index]['color'],
                  onPressed: () => _togglePlayPause(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}