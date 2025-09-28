import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class PopularFigureCallPage extends StatefulWidget {
  final Map<String, dynamic> character;

  const PopularFigureCallPage({
    super.key,
    required this.character,
  });

  @override
  State<PopularFigureCallPage> createState() => _PopularFigureCallPageState();
}

class _PopularFigureCallPageState extends State<PopularFigureCallPage> {
  Timer? _callTimer;
  int _remainingSeconds = 30;
  bool _isCallActive = true;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _startCallTimer();
    _playCallAudio();
  }

  Future<void> _playCallAudio() async {
    try {
      await _audioPlayer.play(AssetSource('chat_call.mp3'));
    } catch (e) {
      debugPrint('Error playing call audio: $e');
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });
        
        if (_remainingSeconds <= 0) {
          _endCall();
        }
      }
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _isCallActive = false;
    });
    
    // 延迟1秒后返回上一页
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _hangUp() {
    _endCall();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Image - Full Screen
          Positioned.fill(
            child: Image.asset(
              widget.character['RavoShowPhoto'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1a1a1a),
                        Color(0xFF2d2d2d),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Content - Full Screen Layout
          Positioned.fill(
            child: Column(
              children: [
                // Top section with character info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60), // Space for status bar
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Character Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              widget.character['RavoUserIcon'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 60,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Character Name
                        Text(
                          widget.character['RavoNickName'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Call Status
                        Text(
                          _isCallActive ? 'Calling...' : 'Call Ended',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Timer
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatTime(_remainingSeconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom section with hang up button
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Center(
                    child: GestureDetector(
                      onTap: _hangUp,
                      child: Container(
                        width: 140,
                        height: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/hang_on.webp',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFE91E63), Color(0xFFF06292)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
