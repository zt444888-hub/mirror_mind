import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/breathing_ball.dart';

enum Phase { idle, inhale, hold, exhale }

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isMuted = false;
  late AnimationController _controller;
  Timer? _phaseTimer;

  Phase _currentPhase = Phase.idle;
  int _secondsLeft = 0;
  int _roundCount = 0;
  bool _isPlaying = false;

  static const int _inhaleSeconds = 4;
  static const int _holdSeconds = 7;
  static const int _exhaleSeconds = 8;

  double _ballScale = 0.7;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setSource(AssetSource("audio/breath_guide.m4a"));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isPlaying = true;
      _roundCount = 0;
    });
    _startInhale();
  }

  void _startInhale() {
    setState(() {
      _currentPhase = Phase.inhale;
      _secondsLeft = _inhaleSeconds;
      _ballScale = 0.7;
    });
    _controller.duration = const Duration(seconds: 4);
    _controller.forward(from: 0);
    _runCountdown(_inhaleSeconds, () => _startHold());
  }

  void _startHold() {
    setState(() {
      _currentPhase = Phase.hold;
      _secondsLeft = _holdSeconds;
      _ballScale = 1.0;
    });
    _controller.stop();
    _runCountdown(_holdSeconds, () => _startExhale());
  }

  void _startExhale() {
    setState(() {
      _currentPhase = Phase.exhale;
      _secondsLeft = _exhaleSeconds;
      _ballScale = 1.0;
    });
    _controller.duration = const Duration(seconds: 8);
    _controller.reverse(from: 1.0);
    _runCountdown(_exhaleSeconds, () {
      setState(() => _roundCount++);
      if (_isPlaying) {
        _startInhale();
      }
    });
  }

  void _runCountdown(int seconds, VoidCallback onDone) {
    _phaseTimer?.cancel();
    int remaining = seconds;
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (mounted) {
        setState(() => _secondsLeft = remaining);
      }
      if (remaining <= 0) {
        timer.cancel();
        onDone();
      }
    });
  }

  void _pause() {
    _audioPlayer.pause();
    _phaseTimer?.cancel();
    _controller.stop();
    setState(() => _isPlaying = false);
  }

  void _reset() {
    _audioPlayer.stop();
    setState(() => _isMuted = true);
    _phaseTimer?.cancel();
    _controller.reset();
    setState(() {
      _isPlaying = false;
      _currentPhase = Phase.idle;
      _secondsLeft = 0;
      _roundCount = 0;
      _ballScale = 0.7;
    });
  }

  String get _phaseText {
    switch (_currentPhase) {
      case Phase.inhale:
        return '吸气';
      case Phase.hold:
        return '屏息';
      case Phase.exhale:
        return '呼气';
      case Phase.idle:
        return '准备';
    }
  }

  String get _instructionText {
    switch (_currentPhase) {
      case Phase.inhale:
        return '用鼻子缓慢吸气，感受腹部鼓起';
      case Phase.hold:
        return '轻柔地屏住呼吸';
      case Phase.exhale:
        return '用嘴巴缓慢呼气，释放所有紧张';
      case Phase.idle:
        return '点击开始，进行 呼吸练习';
    }
  }

  Color get _phaseColor {
    switch (_currentPhase) {
      case Phase.inhale:
        return MirrorColors.secondary;
      case Phase.hold:
        return MirrorColors.primary;
      case Phase.exhale:
        return MirrorColors.accent;
      case Phase.idle:
        return MirrorColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('呼吸练习')),
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _instructionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_currentPhase != Phase.idle)
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: _secondsLeft / (_currentPhase == Phase.inhale
                            ? _inhaleSeconds
                            : _currentPhase == Phase.hold
                                ? _holdSeconds
                                : _exhaleSeconds),
                        strokeWidth: 4,
                        backgroundColor: _phaseColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(_phaseColor),
                      ),
                    ),
                  BreathingAnimator(
                    listenable: _controller,
                    builder: (context, child) {
                      return BreathingBall(
                        scale: _controller.isAnimating
                            ? _controller.value * 0.3 + 0.7
                            : _ballScale,
                        color: _phaseColor,
                      );
                    },
                  ),
                  if (_currentPhase != Phase.idle)
                    Positioned(
                      bottom: 40,
                      child: Text(
                        '$_phaseText $_secondsLeft 秒',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _phaseColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_roundCount > 0) ...[
              const SizedBox(height: 12),
              Text(
                '已完成 $_roundCount 轮',
                style: const TextStyle(
                  fontSize: 13,
                  color: MirrorColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _reset,
                  icon: const Icon(Icons.replay),
                  iconSize: 28,
                  color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                ),
                const SizedBox(width: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MirrorColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: MirrorColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _isPlaying ? _pause : _startBreathing,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
            IconButton(
              onPressed: () {
                if (_isMuted) { _audioPlayer.resume(); } else { _audioPlayer.pause(); }
                setState(() => _isMuted = !_isMuted);
              },
              icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
              iconSize: 28,
              color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
            ),
                const SizedBox(width: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BreathingAnimator extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const BreathingAnimator({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}