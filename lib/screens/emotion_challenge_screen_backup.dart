import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../services/notification_service.dart';
import '../constants/colors.dart';

class EmotionChallengeScreen extends StatefulWidget {
  const EmotionChallengeScreen({super.key});
  @override State<EmotionChallengeScreen> createState() => _EmotionChallengeScreenState();
}

class _ChallengeInfo {
  final String title, description, icon, goldenQuote, badge, badgeName, growth;
  final Color color;
  final List<String> dailyHints;
  const _ChallengeInfo({required this.title, required this.description, required this.icon, required this.color, required this.dailyHints, required this.goldenQuote, required this.badge, required this.badgeName, required this.growth});
}

class _Progress {
  int day = 0;
  List<bool> checkins = List.filled(7, false);
  DateTime? startDate;
  String? lastCheckinDate;
  bool completed = false;
  Map<String, dynamic> toJson() => {'day': day, 'checkins': checkins.map((e) => e ? 1 : 0).join(','), 'startDate': startDate?.toIso8601String(), 'lastCheckinDate': lastCheckinDate, 'completed': completed};
  static _Progress fromJson(Map<String, dynamic> j) {
    final p = _Progress(); p.day = j['day'] as int? ?? 0;
    p.checkins = (j['checkins'] as String? ?? '').split(',').map((e) => e == '1').toList();
    if (p.checkins.length != 7) p.checkins = List.filled(7, false);
    p.startDate = j['startDate'] != null ? DateTime.tryParse(j['startDate'] as String) : null;
    p.lastCheckinDate = j['lastCheckinDate'] as String?; p.completed = j['completed'] as bool? ?? false;
    return p;
  }
}

class _EmotionChallengeScreenState extends State<EmotionChallengeScreen> {
  static const List<_ChallengeInfo> _challenges = [
    _ChallengeInfo(title:'积极发现',description:'每天找一个让自己开心的小事',icon:'🔍',color:MirrorColors.accent,dailyHints:['今天有让你微笑的事吗？','找一找今天的小确幸','有什么让你感恩的？','谁让你感到温暖？','哪一刻让你觉得美好？','回顾三个开心瞬间','这7天你最大的收获是什么？'],goldenQuote:'幸福不是拥有最好的一切，而是把一切过成最好的样子。',badge:'🏆',badgeName:'积极发现者',growth:'你学会了在平凡中发现美好，这种能力会让你的人生更加丰盈。'),
    _ChallengeInfo(title:'情绪觉察',description:'早中晚三次记录情绪',icon:'🧘',color:MirrorColors.primary,dailyHints:['早晨醒来第一感受？','上午工作时的情绪变化','午后的心情如何？','和他人互动时的感受','傍晚的心情','睡前回顾一天','这7天对情绪有什么新发现？'],goldenQuote:'觉察是改变的第一步。',badge:'🧠',badgeName:'情绪观察家',growth:'你开始真正看见自己的情绪，这就是改变的开始。'),
    _ChallengeInfo(title:'自我关怀',description:'每天做一件照顾自己的事',icon:'💝',color:MirrorColors.warm,dailyHints:['给自己做一顿健康美食','放下手机一小时做喜欢的事','对自己说一句温柔的话','给自己充足的休息','允许自己不完美','做一件让你舒服的小事','这7天你对自己的态度有变化吗？'],goldenQuote:'爱自己，是终生浪漫的开始。',badge:'🌸',badgeName:'自我关怀达人',growth:'你学会了对自己温柔，这是最重要的生命技能。'),
    _ChallengeInfo(title:'情绪管理',description:'每天练习一个情绪调节技巧',icon:'🎯',color:Color(0xFF7B9CB5),dailyHints:['深呼吸3次感受变化','写下今天最强烈的情绪','尝试换个角度看问题','做一件让你放松的事','和信任的人聊聊感受','回顾本周学到的方法','哪种技巧最适合你？'],goldenQuote:'情绪不是敌人，而是信使。',badge:'🎖️',badgeName:'情绪管理师',growth:'你掌握了多种情绪调节工具，内在力量正在成长。'),
    _ChallengeInfo(title:'正念修行',description:'每天5分钟正念练习',icon:'🧘',color:Color(0xFF8B9E8B),dailyHints:['关注一次完整的呼吸','感受双脚踩在地面的感觉','正念喝水感受温度与味道','正念走路慢下来感受每一步','扫描身体的紧张部位','正念倾听周围的声音','这7天正念带给你什么变化？'],goldenQuote:'正念不是让心安静，而是看见心的活动。',badge:'🕉️',badgeName:'正念修行者',growth:'正念让你的内心拥有了一片可以随时回归的宁静之地。'),
  ];

  List<_Progress> _p = [];
  static const String _key = 'challenge_v4';

  @override void initState() { super.initState(); _p = List.generate(_challenges.length, (_) => _Progress()); _load(); }
  
  Future<void> _load() async {
    final r = (await SharedPreferences.getInstance()).getString(_key);
    if (r != null && r.isNotEmpty) try { final d = jsonDecode(r) as List; for (int i = 0; i < d.length && i < _p.length; i++) _p[i] = _Progress.fromJson(d[i] as Map); } catch (_) {}
    if (mounted) setState(() {});
  }
  Future<void> _save() async => (await SharedPreferences.getInstance()).setString(_key, jsonEncode(_p.map((p) => p.toJson()).toList()));

  void _start(int idx) { setState(() { _p[idx].day = 1; _p[idx].startDate = DateTime.now(); }); _save(); NotificationService().scheduleChallengeReminder(hour: 20, minute: 0); }

  Future<void> _checkin(int idx) async {
    final cp = _p[idx]; final today = DateTime.now().toIso8601String().split('T')[0];
    if (cp.lastCheckinDate == today) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('今日已打卡，明天再来吧！'), backgroundColor: MirrorColors.warm)); return; }
    final ch = _challenges[idx];
    final r = await showDialog<String>(context: context, builder: (ctx) => _CheckinDialog(day: cp.day, hint: ch.dailyHints[cp.day - 1], title: ch.title));
    if (r != null && r.trim().isNotEmpty && mounted) {
      await context.read<EmotionProvider>().saveRecord(EmotionRecord(date: DateTime.now(), emotion: '一般', inputText: '挑战：${ch.title}
Day ${cp.day}: ${ch.dailyHints[cp.day - 1]}
记录：$r', score: 8, tag: '7天挑战'));
      if (!mounted) return; setState(() { cp.checkins[cp.day - 1] = true; cp.day++; cp.lastCheckinDate = today; if (cp.day > 7) { cp.completed = true; _showDone(idx); } }); _save();
    }
  }

  void _showDone(int idx) {
    final ch = _challenges[idx];
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(children: [Text(ch.badge, style: const TextStyle(fontSize: 48)), const SizedBox(height: 12), const Text('挑战完成！', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('获得「${ch.badgeName}」徽章', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 12), Text(ch.goldenQuote, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.5, color: MirrorColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: MirrorColors.primaryLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)), child: Text(ch.growth, style: const TextStyle(fontSize: 12, height: 1.5, color: MirrorColors.primaryDark), textAlign: TextAlign.center)),
      ]), actions: [ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('继续'))],
    ));
  }

  @override Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(backgroundColor: d ? MirrorColors.darkBackground : MirrorColors.background, appBar: AppBar(title: const Text('7天挑战')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _buildBadges(d), const SizedBox(height: 16),
        ...List.generate(_challenges.length, (i) => _buildCard(i, d)),
        _buildGrowth(d), const SizedBox(height: 40),
      ]));
  }

  Widget _buildBadges(bool d) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: d ? MirrorColors.darkCardBackground : MirrorColors.cardBackground, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🏅 徽章墙', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...List.generate(_challenges.length, (i) {
          final ch = _challenges[i]; final cp = _p[i]; final earned = cp.completed;
          return GestureDetector(
            onTap: () => _showBadge(i),
            child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: earned ? ch.color.withValues(alpha: 0.1) : (d ? MirrorColors.darkSurface : Colors.grey.shade50), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: earned ? ch.color.withValues(alpha: 0.3) : (d ? Colors.grey.shade800 : Colors.grey.shade200))),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: earned ? ch.color.withValues(alpha: 0.2) : Colors.grey.shade200, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(earned ? ch.badge : '🔒', style: const TextStyle(fontSize: 20)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(earned ? ch.badgeName : '???', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: earned ? ch.color : Colors.grey)),
                  Text(earned ? ch.growth : '未解锁', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ])),
                if (earned) const Icon(Icons.check_circle, color: MirrorColors.secondary, size: 20),
              ])),
          );
        }),
        if (_p.every((p) => p.completed)) Container(
          padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12)),
          child: const Text('🎉 恭喜集齐全部5枚徽章！', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), textAlign: TextAlign.center)),
      ]),
    );
  }

  void _showBadge(int idx) {
    final ch = _challenges[idx]; final cp = _p[idx];
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(children: [Text(ch.badge, style: const TextStyle(fontSize: 32)), const SizedBox(width: 12), Text(cp.completed ? ch.badgeName : '???', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: (cp.completed ? MirrorColors.secondary : Colors.grey).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
          child: Text(cp.completed ? '已获得' : '未解锁', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cp.completed ? MirrorColors.secondary : Colors.grey))),
        const SizedBox(height: 12), Text(ch.goldenQuote, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, height: 1.5, color: MirrorColors.primaryDark)),
        const SizedBox(height: 12), const Text('成长收获', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(ch.growth, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.grey.shade700)),
      ]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了'))],
    ));
  }

  Widget _buildCard(int idx, bool d) {
    final ch = _challenges[idx]; final cp = _p[idx]; final started = cp.day > 0;
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Card(
      child: InkWell(onTap: started ? null : () => _start(idx), borderRadius: BorderRadius.circular(16),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: ch.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(ch.icon, style: const TextStyle(fontSize: 24)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(ch.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), Text(ch.description, style: TextStyle(fontSize: 12, color: d ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary))])),
            if (cp.completed) const Icon(Icons.check_circle, color: MirrorColors.secondary, size: 28),
            if (!started) Icon(Icons.play_arrow, color: ch.color, size: 28),
          ]),
          if (started && !cp.completed) ...[
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (cp.day - 1) / 7, minHeight: 6, backgroundColor: ch.color.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation<Color>(ch.color))),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Day ${cp.day} / 7', style: TextStyle(fontSize: 12, color: d ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary)),
              SizedBox(height: 32, child: ElevatedButton.icon(
                onPressed: cp.day <= 7 ? () => _checkin(idx) : null, icon: const Icon(Icons.check_circle_outline, size: 16),
                label: Text(cp.lastCheckinDate == DateTime.now().toIso8601String().split('T')[0] ? '已打卡' : '打卡', style: const TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: ch.color, padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              )),
            ]),
            if (cp.day <= ch.dailyHints.length) Padding(padding: const EdgeInsets.only(top: 8), child: Text(ch.dailyHints[cp.day - 1], style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: d ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary))),
          ],
        ])),
      ),
    ));
  }

  Widget _buildGrowth(bool d) {
    final earned = _p.where((p) => p.completed).toList();
    if (earned.isEmpty) return const SizedBox.shrink();
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: d ? MirrorColors.darkCardBackground : MirrorColors.cardBackground, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🌱 成长之路', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...earned.map((p) {
          final idx = _p.indexOf(p); final ch = _challenges[idx];
          return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: ch.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(ch.badge, style: const TextStyle(fontSize: 20)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ch.badgeName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(ch.growth, style: TextStyle(fontSize: 12, height: 1.5, color: d ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary)),
              Text(ch.goldenQuote, style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: ch.color)),
            ])),
          ]));
        }).toList(),
      ]),
    );
  }
}

class _CheckinDialog extends StatefulWidget {
  final int day; final String hint; final String title;
  const _CheckinDialog({required this.day, required this.hint, required this.title});
  @override State<_CheckinDialog> createState() => _CheckinDialogState();
}

class _CheckinDialogState extends State<_CheckinDialog> {
  final TextEditingController _c = TextEditingController();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Day ${widget.day} · ${widget.title}'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.hint, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4)),
        const SizedBox(height: 16),
        TextField(controller: _c, maxLines: 3, autofocus: true, decoration: const InputDecoration(hintText: '写下你的感受和发现...', contentPadding: EdgeInsets.all(12))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('跳过')),
        ElevatedButton(onPressed: () => Navigator.pop(context, _c.text), child: const Text('完成打卡')),
      ],
    );
  }
}
