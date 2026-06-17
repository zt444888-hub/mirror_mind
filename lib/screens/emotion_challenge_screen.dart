
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/emotion_provider.dart';

class _ChallengeInfo {
  final String title; final String description; final String icon; final Color color;
  final List<String> dailyHints; final String goldenQuote; final String badge;
  final String badgeName; final String growth;
  const _ChallengeInfo({required this.title, required this.description, required this.icon,
    required this.color, required this.dailyHints, required this.goldenQuote,
    required this.badge, required this.badgeName, required this.growth});
}

class _ChallengeProgress {
  int day; DateTime? startDate; DateTime? lastCheckinDate; bool completed;
  _ChallengeProgress({this.day = 0, this.startDate, this.lastCheckinDate, this.completed = false});
  Map<String, dynamic> toJson() => {
    'day': day, 'startDate': startDate?.toIso8601String(), 'lastCheckinDate': lastCheckinDate?.toIso8601String(), 'completed': completed
  };
  static _ChallengeProgress fromJson(Map<String, dynamic> j) {
    var p = _ChallengeProgress(); p.day = j['day'] as int? ?? 0;
    p.startDate = j['startDate'] != null ? DateTime.parse(j['startDate'] as String) : null;
    p.lastCheckinDate = j['lastCheckinDate'] != null ? DateTime.parse(j['lastCheckinDate'] as String) : null;
    p.completed = j['completed'] as bool? ?? false; return p;
  }
}

class EmotionChallengeScreen extends StatefulWidget {
  const EmotionChallengeScreen({super.key});
  @override State<EmotionChallengeScreen> createState() => _EmotionChallengeScreenState();
}

class _EmotionChallengeScreenState extends State<EmotionChallengeScreen> {
  static const String _keyData = 'emotion_challenge_progress';
  static final List<_ChallengeInfo> _challenges = [
    const _ChallengeInfo(title: '\u79ef\u6781\u53d1\u73b0', description: '\u6bcf\u5929\u627e\u4e00\u4e2a\u8ba9\u81ea\u5df1\u5f00\u5fc3\u7684\u5c0f\u4e8b', icon: '\ud83d\udd0d', color: Color(0xFF7BC4A0),
      dailyHints: ['\u4eca\u5929\u6709\u8ba9\u4f60\u5fae\u7b11\u7684\u4e8b\u5417\uff1f', '\u627e\u4e00\u627e\u4eca\u5929\u7684\u5c0f\u786e\u5e78', '\u6709\u4ec0\u4e48\u8ba9\u4f60\u611f\u6069\u7684\uff1f', '\u8c01\u8ba9\u4f60\u611f\u5230\u6e29\u6696\uff1f', '\u54ea\u4e00\u523b\u8ba9\u4f60\u89c9\u5f97\u7f8e\u597d\uff1f', '\u56de\u987e\u4e09\u4e2a\u5f00\u5fc3\u77ac\u95f4', '\u8fd97\u5929\u4f60\u6700\u5927\u7684\u6536\u83b7\u662f\u4ec0\u4e48\uff1f'],
      goldenQuote: '\u5e78\u798f\u4e0d\u662f\u62e5\u6709\u6700\u597d\u7684\u4e00\u5207\uff0c\u800c\u662f\u628a\u4e00\u5207\u8fc7\u6210\u6700\u597d\u7684\u6837\u5b50\u3002', badge: '\ud83c\udfc6', badgeName: '\u79ef\u6781\u53d1\u73b0\u8005',
      growth: '\u4f60\u5b66\u4f1a\u4e86\u5728\u5e73\u51e1\u4e2d\u53d1\u73b0\u7f8e\u597d\uff0c\u8fd9\u79cd\u80fd\u529b\u4f1a\u8ba9\u4f60\u7684\u4eba\u751f\u66f4\u52a0\u4e30\u76c8\u3002'),
    const _ChallengeInfo(title: '\u60c5\u7eea\u89c9\u5bdf', description: '\u65e9\u4e2d\u665a\u4e09\u6b21\u8bb0\u5f55\u60c5\u7eea', icon: '\ud83e\udde0', color: Color(0xFF7B9CB5),
      dailyHints: ['\u65e9\u6668\u9192\u6765\u7b2c\u4e00\u611f\u53d7\uff1f', '\u4e0a\u5348\u5de5\u4f5c\u65f6\u7684\u60c5\u7eea\u53d8\u5316', '\u5348\u540e\u7684\u5fc3\u60c5\u5982\u4f55\uff1f', '\u548c\u4ed6\u4eba\u4e92\u52a8\u65f6\u7684\u611f\u53d7', '\u508d\u665a\u7684\u5fc3\u60c5', '\u7761\u524d\u56de\u987e\u4e00\u5929', '\u8fd97\u5929\u5bf9\u60c5\u7eea\u6709\u4ec0\u4e48\u65b0\u53d1\u73b0\uff1f'],
      goldenQuote: '\u89c9\u5bdf\u662f\u6539\u53d8\u7684\u7b2c\u4e00\u6b65\u3002', badge: '\ud83e\udde0', badgeName: '\u60c5\u7eea\u89c2\u5bdf\u5bb6',
      growth: '\u4f60\u5f00\u59cb\u771f\u6b63\u770b\u89c1\u81ea\u5df1\u7684\u60c5\u7eea\uff0c\u8fd9\u5c31\u662f\u6539\u53d8\u7684\u5f00\u59cb\u3002'),
    const _ChallengeInfo(title: '\u81ea\u6211\u5173\u6000', description: '\u6bcf\u5929\u505a\u4e00\u4ef6\u7167\u987e\u81ea\u5df1\u7684\u4e8b', icon: '\ud83d\udc9d', color: Color(0xFFC49B8C),
      dailyHints: ['\u7ed9\u81ea\u5df1\u505a\u4e00\u987f\u5065\u5eb7\u7f8e\u98df', '\u653e\u4e0b\u624b\u673a\u4e00\u5c0f\u65f6\u505a\u559c\u6b22\u7684\u4e8b', '\u5bf9\u81ea\u5df1\u8bf4\u4e00\u53e5\u6e29\u67d4\u7684\u8bdd', '\u7ed9\u81ea\u5df1\u5145\u8db3\u7684\u4f11\u606f', '\u5141\u8bb8\u81ea\u5df1\u4e0d\u5b8c\u7f8e', '\u505a\u4e00\u4ef6\u8ba9\u4f60\u8212\u670d\u7684\u5c0f\u4e8b', '\u8fd97\u5929\u4f60\u5bf9\u81ea\u5df1\u7684\u6001\u5ea6\u6709\u53d8\u5316\u5417\uff1f'],
      goldenQuote: '\u7231\u81ea\u5df1\uff0c\u662f\u7ec8\u751f\u6d6a\u6f2b\u7684\u5f00\u59cb\u3002', badge: '\ud83c\udf38', badgeName: '\u81ea\u6211\u5173\u6000\u8fbe\u4eba',
      growth: '\u4f60\u5b66\u4f1a\u4e86\u5bf9\u81ea\u5df1\u6e29\u67d4\uff0c\u8fd9\u662f\u6700\u91cd\u8981\u7684\u751f\u547d\u6280\u80fd\u3002'),
    const _ChallengeInfo(title: '\u60c5\u7eea\u7ba1\u7406', description: '\u6bcf\u5929\u7ec3\u4e60\u4e00\u4e2a\u60c5\u7eea\u8c03\u8282\u6280\u5de7', icon: '\ud83c\udfaf', color: Color(0xFF8B9E8B),
      dailyHints: ['\u6df1\u547c\u54383\u6b21\uff0c\u611f\u53d7\u53d8\u5316', '\u5199\u4e0b\u4eca\u5929\u6700\u5f3a\u70c8\u7684\u60c5\u7eea', '\u5c1d\u8bd5\u6362\u4e2a\u89d2\u5ea6\u770b\u95ee\u9898', '\u505a\u4e00\u4ef6\u8ba9\u4f60\u653e\u677e\u7684\u4e8b', '\u548c\u4fe1\u4efb\u7684\u4eba\u804a\u804a\u611f\u53d7', '\u56de\u987e\u672c\u5468\u5b66\u5230\u7684\u65b9\u6cd5', '\u54ea\u79cd\u6280\u5de7\u6700\u9002\u5408\u4f60\uff1f'],
      goldenQuote: '\u60c5\u7eea\u4e0d\u662f\u654c\u4eba\uff0c\u800c\u662f\u4fe1\u4f7f\u3002', badge: '\ud83c\udf96\ufe0f', badgeName: '\u60c5\u7eea\u7ba1\u7406\u5e08',
      growth: '\u4f60\u638c\u63e1\u4e86\u591a\u79cd\u60c5\u7eea\u8c03\u8282\u5de5\u5177\uff0c\u5185\u5728\u529b\u91cf\u6b63\u5728\u6210\u957f\u3002'),
    const _ChallengeInfo(title: '\u6b63\u5ff5\u4fee\u884c', description: '\u6bcf\u59295\u5206\u949f\u6b63\u5ff5\u7ec3\u4e60', icon: '\ud83e\uddd9', color: Color(0xFFA0B5A0),
      dailyHints: ['\u5173\u6ce8\u4e00\u6b21\u5b8c\u6574\u7684\u547c\u5438', '\u611f\u53d7\u53cc\u811a\u8e29\u5728\u5730\u9762\u7684\u611f\u89c9', '\u6b63\u5ff5\u559d\u6c34\uff1a\u611f\u53d7\u6e29\u5ea6\u4e0e\u5473\u9053', '\u6b63\u5ff5\u8d70\u8def\uff1a\u6162\u4e0b\u6765\u611f\u53d7\u6bcf\u4e00\u6b65', '\u626b\u63cf\u8eab\u4f53\u7684\u7d27\u5f20\u90e8\u4f4d', '\u6b63\u5ff5\u503e\u542c\u5468\u56f4\u7684\u58f0\u97f3', '\u8fd97\u5929\u6b63\u5ff5\u5e26\u7ed9\u4f60\u4ec0\u4e48\u53d8\u5316\uff1f'],
      goldenQuote: '\u6b63\u5ff5\u4e0d\u662f\u8ba9\u5fc3\u5b89\u9759\uff0c\u800c\u662f\u770b\u89c1\u5fc3\u7684\u6d3b\u52a8\u3002', badge: '\ud83d\ude49\ufe0f', badgeName: '\u6b63\u5ff5\u4fee\u884c\u8005',
      growth: '\u6b63\u5ff5\u8ba9\u4f60\u7684\u5185\u5fc3\u62e5\u6709\u4e86\u4e00\u7247\u53ef\u4ee5\u968f\u65f6\u56de\u5f52\u7684\u5b81\u9759\u4e4b\u5730\u3002'),
  ];
  List<_ChallengeProgress> _progress = []; bool _isDark = false;

  @override void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    var prefs = await SharedPreferences.getInstance(); var raw = prefs.getString(_keyData);
    if (raw != null && raw.isNotEmpty) {
      try { var list = jsonDecode(raw) as List;
        _progress = List.generate(_challenges.length, (i) => i < list.length ? _ChallengeProgress.fromJson(list[i] as Map<String, dynamic>) : _ChallengeProgress());
      } catch (_) { _progress = List.generate(_challenges.length, (_) => _ChallengeProgress()); }
    } else { _progress = List.generate(_challenges.length, (_) => _ChallengeProgress()); }
    if (mounted) setState(() {});
  }

  Future<void> _saveData() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyData, jsonEncode(_progress.map((p) => p.toJson()).toList()));
  }

  void _startChallenge(int index) {
  void _showSnack(String msg) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))); }
    if (_progress[index].day > 0) return;
    setState(() { _progress[index].day = 1; _progress[index].startDate = DateTime.now(); _progress[index].lastCheckinDate = DateTime.now(); });
    _saveData();
  }

  Future<void> _checkinToday(int index) async {
    var cp = _progress[index]; var ch = _challenges[index];
    var today = DateTime.now(); var ts = '${today.year}-${today.month}-${today.day}';
    if (cp.lastCheckinDate != null) {
      var ls = '${cp.lastCheckinDate!.year}-${cp.lastCheckinDate!.month}-${cp.lastCheckinDate!.day}';
      if (ls == ts) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('\u4eca\u5929\u5df2\u7ecf\u6253\u5361\u5566\uff0c\u660e\u5929\u7ee7\u7eed\u5427\uff5e'))); return; }
    }
    var hi = (cp.day - 1).clamp(0, ch.dailyHints.length - 1);
    var r = await showDialog<String>(context: context, builder: (ctx) => _CheckinDialog(day: cp.day + 1, hint: ch.dailyHints[hi], challengeTitle: ch.title));
    if (r != null && mounted) { setState(() { cp.day++; cp.lastCheckinDate = DateTime.now(); if (cp.day > 7) cp.completed = true; }); _saveData(); if (cp.completed) _showCompletionDialog(index); }
  }

  void _showCompletionDialog(int index) {
    var ch = _challenges[index];
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), title: const Text('\ud83c\udf89 \u6311\u6218\u5b8c\u6210\uff01'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('${ch.badge} ${ch.badgeName}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(ch.goldenQuote, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: ch.color)),
        const SizedBox(height: 8),
        Text(ch.growth, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.5)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('\u592a\u68d2\u4e86\uff01'))],
    ));
  }

  @override Widget build(BuildContext context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;
    var bg = _isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F6F2);
    return Scaffold(backgroundColor: bg,
      appBar: AppBar(title: const Text('\u4e03\u5929\u6311\u6218'), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, foregroundColor: _isDark ? Colors.white : Colors.black87),
      body: _progress.isEmpty ? const Center(child: CircularProgressIndicator())
        : ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
            ...List.generate(_challenges.length, (i) => _buildChallengeCard(i)),
            const SizedBox(height: 20), _buildBadgeWall(), const SizedBox(height: 20), _buildGrowthSection(),
          ]),
    );
  }

    Widget _buildChallengeCard(int index) {
    var ch = _challenges[index]; var cp = _progress[index];
    var earned = cp.completed; var prog = (cp.day / 7.0).clamp(0.0, 1.0);
    var bgc = (_isDark ? Colors.white : Colors.black).withOpacity(earned ? 0.12 : 0.05);
    var bdr = earned ? Border.all(color: ch.color.withOpacity(0.4), width: 1.5) : null;
    Widget iw = Container(width: 48, height: 48, decoration: BoxDecoration(color: ch.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(ch.icon, style: const TextStyle(fontSize: 24))));
    Widget tw = Row(children: [Text(ch.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _isDark ? Colors.white : Colors.black87)), if (earned) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: ch.color, borderRadius: BorderRadius.circular(8)), child: Text(ch.badge + " 已完成", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)))]]);
    Widget pw = ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: prog, backgroundColor: (_isDark ? Colors.white : Colors.black).withOpacity(0.1), valueColor: AlwaysStoppedAnimation(ch.color), minHeight: 6));
    Widget dw = Text("Day " + cp.day.toString() + "/7", style: TextStyle(fontSize: 11, color: _isDark ? Colors.grey[400] : Colors.grey[500]));
    Widget dcw = Text(ch.description, style: TextStyle(fontSize: 12, color: _isDark ? Colors.grey[400] : Colors.grey[600]));
    Widget aw;
    if (earned) { aw = Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: ch.color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(ch.badge, style: const TextStyle(fontSize: 20))); }
    else if (cp.day == 0) { aw = _buildActionButton("开始", ch.color, () => _startChallenge(index)); }
    else { aw = _buildActionButton("打卡", ch.color, () => _checkinToday(index)); }
    return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: bgc, borderRadius: BorderRadius.circular(16), border: bdr), child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(16), child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => _showBadgeDetail(index), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [iw, const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [tw, const SizedBox(height: 2), dcw, const SizedBox(height: 8), pw, const SizedBox(height: 4), dw])), const SizedBox(width: 8), aw])))));
  }Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return SizedBox(height: 36, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0), child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))));
  }

  Widget _buildBadgeWall() {
    var earned = <int>[]; for (var i = 0; i < _challenges.length; i++) { if (_progress[i].completed) earned.add(i); }
    if (earned.isEmpty) {
      return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: 0.08))), child: Column(children: [
        Text('\ud83c\udfc5 \u5fbd\u7ae0\u5899', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _isDark ? Colors.white70 : Colors.black54)), const SizedBox(height: 12),
        Text('\u5b8c\u62107\u5929\u6311\u6218\u5373\u53ef\u83b7\u5f97\u5bf9\u5e94\u5fbd\u7ae0', style: TextStyle(fontSize: 13, color: _isDark ? Colors.grey[500] : Colors.grey[400])),
      ]));
    }
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [_isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF0EDE8), _isDark ? const Color(0xFF1E1E32) : const Color(0xFFF8F6F2)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Text('\ud83c\udfc5', style: TextStyle(fontSize: 18)), const SizedBox(width: 6), Text('\u5fbd\u7ae0\u5899', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _isDark ? Colors.white : Colors.black87)), const Spacer(), Text('\u5df2\u83b7\u5f97 ${earned.length}/${_challenges.length}', style: TextStyle(fontSize: 12, color: _isDark ? Colors.grey[400] : Colors.grey[600]))]),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: earned.map((i) {
          var ch = _challenges[i];
          return GestureDetector(onTap: () => _showBadgeDetail(i), child: Container(width: 72, height: 88, decoration: BoxDecoration(color: ch.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: ch.color.withValues(alpha: 0.3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(ch.badge, style: const TextStyle(fontSize: 28)), const SizedBox(height: 4), Text(ch.badgeName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ch.color)),
          ])));
        }).toList()),
      ]));
  }

  Widget _buildGrowthSection() {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: (_isDark ? Colors.white : Colors.black).withValues(alpha: 0.08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('\ud83c\udf31', style: TextStyle(fontSize: 16)), const SizedBox(width: 6), Text('\u5fbd\u7ae0\u5927\u5168 & \u6210\u957f\u4f53\u7cfb', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _isDark ? Colors.white : Colors.black87))]),
      const SizedBox(height: 16),
      ..._challenges.asMap().entries.map((e) {
        var i = e.key; var ch = e.value; var earned = _progress[i].completed;
        return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: earned ? ch.color.withValues(alpha: 0.1) : (_isDark ? Colors.white : Colors.black).withValues(alpha: 0.03), borderRadius: BorderRadius.circular(12), border: earned ? Border.all(color: ch.color.withValues(alpha: 0.3)) : null), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: earned ? ch.color.withValues(alpha: 0.2) : (_isDark ? Colors.grey[800] : Colors.grey[200]), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(earned ? ch.badge : '\u2753', style: TextStyle(fontSize: earned ? 22 : 18, color: earned ? null : Colors.grey)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(ch.badgeName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: earned ? ch.color : (_isDark ? Colors.grey[400] : Colors.grey[500]))), if (earned) ...[const SizedBox(width: 6), const Icon(Icons.check_circle, size: 14, color: Colors.green)]]),
            const SizedBox(height: 4), Text(ch.growth, style: TextStyle(fontSize: 12, height: 1.5, color: _isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 4),
            Text('\u201c' + ch.goldenQuote + '\u201d', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: ch.color.withValues(alpha: 0.7))),
          ])),
        ]));
      }),
    ]));
  }

  void _showBadgeDetail(int index) {
    var ch = _challenges[index]; var cp = _progress[index]; var earned = cp.completed; var prog = (cp.day / 7.0).clamp(0.0, 1.0);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 64, height: 64, decoration: BoxDecoration(color: ch.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(earned ? ch.badge : '\u2753', style: const TextStyle(fontSize: 32)))),
        const SizedBox(height: 12),
        Text(ch.badgeName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: earned ? ch.color : (_isDark ? Colors.grey[400] : Colors.grey[500]))),
        const SizedBox(height: 8),
        Text('\u300c' + ch.title + '\u300d', style: TextStyle(fontSize: 13, color: _isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 16),
        if (!earned) ...[
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: prog, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation(ch.color), minHeight: 8)),
          const SizedBox(height: 6), Text('Day ${cp.day}/7', style: TextStyle(fontSize: 12, color: _isDark ? Colors.grey[400] : Colors.grey[500])), const SizedBox(height: 16),
        ],
        Text(ch.goldenQuote, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: ch.color)),
        const SizedBox(height: 8),
        Text(ch.growth, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.5, color: _isDark ? Colors.grey[300] : Colors.grey[700])),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('\u77e5\u9053\u4e86'))],
    ));
  }
}

class _CheckinDialog extends StatefulWidget {
  final int day; final String hint; final String challengeTitle;
  const _CheckinDialog({required this.day, required this.hint, required this.challengeTitle});
  @override State<_CheckinDialog> createState() => _CheckinDialogState();
}

class _CheckinDialogState extends State<_CheckinDialog> {
  final TextEditingController _c = TextEditingController();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Day ' + widget.day.toString() + ' \u00b7 ' + widget.challengeTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF0EDE8), borderRadius: BorderRadius.circular(12)), child: Text(widget.hint, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.4, color: Color(0xFF4A4A4A)))),
        const SizedBox(height: 16),
        TextField(controller: _c, maxLines: 3, autofocus: true, decoration: const InputDecoration(hintText: '\u5199\u4e0b\u4f60\u7684\u611f\u53d7\u548c\u53d1\u73b0...', contentPadding: EdgeInsets.all(12), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))))),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('\u8df3\u8fc7')), ElevatedButton(onPressed: () => Navigator.pop(context, _c.text), child: const Text('\u5b8c\u6210\u6253\u5361'))],
    );
  }
}
