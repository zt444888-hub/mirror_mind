import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});
  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int _selectedMinutes = 30;
  bool _isRunning = false;
  bool _isSoundOn = false;
  int _currentSound = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  late AudioPlayer _player;

  final _sounds = [
    {'name': '雨声', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'},
    {'name': '海浪', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'},
    {'name': '森林', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'},
    {'name': '白噪音', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'},
  ];

  final _quotes = [
    '放下一天的疲惫，让心慢慢沉静',
    '每一次呼吸，都是一次放松',
    '你不需要做任何事，只需安住在此刻',
    '让思绪像云一样飘过，不留痕迹',
    '身体的每一寸都在慢慢放松',
    '世界安静下来，只剩你的呼吸',
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.loop);
    _player.onPlayerComplete.listen((_) {
      _player.seek(const Duration(seconds: 0));
      _player.resume();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _startTimer() async {
    await _player.setSource(UrlSource(_sounds[_currentSound]['url']!));
    await _player.resume();
    setState(() { _isSoundOn = true; _isRunning = true; _remainingSeconds = _selectedMinutes * 60; });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 1) {
        t.cancel(); _stopTimer();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🌙 晚安，祝你好梦')));
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _stopTimer() async {
    _timer?.cancel();
    await _player.stop();
    setState(() { _isRunning = false; _isSoundOn = false; _remainingSeconds = 0; });
  }

  void _toggleSound() async {
    if (_isSoundOn) { await _player.pause(); }
    else { await _player.resume(); }
    setState(() => _isSoundOn = !_isSoundOn);
  }

  void _changeSound(int index) async {
    _currentSound = index;
    if (_isRunning) {
      await _player.stop();
      await _player.setSource(UrlSource(_sounds[index]['url']!));
      await _player.resume();
      setState(() { _isSoundOn = true; });
    }
  }

  String get _timeDisplay {
    if (!_isRunning) return '$_selectedMinutes:00';
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress => _isRunning ? _remainingSeconds / (_selectedMinutes * 60) : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D2B), Color(0xFF1A1A4E), Color(0xFF2D1B69)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部返回栏
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('助眠', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (_isRunning)
                      IconButton(
                        icon: const Icon(Icons.stop_rounded, color: Colors.white70),
                        onPressed: _stopTimer,
                      ),
                  ],
                ),
              ),
              // 月亮图标
              const Spacer(flex: 2),
              Icon(_isRunning ? Icons.brightness_2 : Icons.nights_stay_rounded, size: 80, color: Colors.amber.shade100),
              const SizedBox(height: 24),
              // 计时
              Text(_timeDisplay, style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w200, color: Colors.white)),
              if (_isRunning) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress, minHeight: 4,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // 放松引导
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: Text(
                    _isRunning ? _quotes[_remainingSeconds ~/ 30 % _quotes.length] : '选择一个时间，开始放松',
                    key: ValueKey(_remainingSeconds ~/ 30),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, color: Colors.white.withValues(alpha: 0.8), height: 1.6),
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // 音频选择
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _sounds.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _changeSound(i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _currentSound == i ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: _currentSound == i ? Border.all(color: Colors.amber.shade300, width: 1) : null,
                      ),
                      child: Row(
                        children: [
                          Text(
                            ['🌧️', '🌊', '🌲', '☁️'][i],
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Text(_sounds[i]['name']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 控制区域
              if (!_isRunning) ...[
                // 时间选择
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [15, 30, 60].map((m) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMinutes = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedMinutes == m ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$m 分钟', style: const TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                // 开始按钮
                ElevatedButton(
                  onPressed: _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade400,
                    foregroundColor: const Color(0xFF0D0D2B),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('开始放松'),
                ),
              ] else ...[
                if (_isSoundOn) ...[
                  IconButton(
                    iconSize: 48,
                    onPressed: _toggleSound,
                    icon: Icon(_isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded, color: Colors.white70),
                  ),
                ],
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
