import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_chat_service.dart';
import '../services/purchase_service.dart';
import '../providers/settings_provider.dart';
import '../constants/colors.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _tc = TextEditingController();
  final ScrollController _sc = ScrollController();
  late AiChatService _cs;
  // bool _init = false;  // unused, removed

  @override
  void initState() { super.initState(); _cs = AiChatService(); _setup(); }
  Future<void> _setup() async {
    _cs.addListener(() { if (mounted) setState(() {}); });
    final s = context.read<SettingsProvider>();
    _cs.syncConfig(baseUrl: s.baseUrl, apiKey: s.apiKey, model: s.model, isPro: PurchaseService().isPro);
    await _cs.loadHistory(); 
  }
  @override
  void dispose() { _tc.dispose(); _sc.dispose(); _cs.dispose(); super.dispose(); }
  void _scrollBtm() { WidgetsBinding.instance.addPostFrameCallback((_) { if (_sc.hasClients) _sc.animateTo(_sc.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut); }); }
  Future<void> _send() async { final t = _tc.text.trim(); if (t.isEmpty || _cs.isThinking) return; _tc.clear(); _cs.addListener(_scrollBtm); await _cs.sendMessage(t); _cs.removeListener(_scrollBtm); _scrollBtm(); }
  Future<void> _clear() async { final c = await showDialog<bool>(context: context, builder: (c) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text('清除对话'), content: const Text('删除所有聊天记录？'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')), ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: MirrorColors.error), child: const Text('确认', style: TextStyle(color: Colors.white)))])); if (c == true) await _cs.clearHistory(); }

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;
    final s = context.watch<SettingsProvider>();
    _cs.syncConfig(baseUrl: s.baseUrl, apiKey: s.apiKey, model: s.model, isPro: PurchaseService().isPro);
    if (!_cs.isConfigured) return _paywall(d);
    return Scaffold(backgroundColor: d ? MirrorColors.darkBackground : MirrorColors.background, appBar: AppBar(title: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary]), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
      const SizedBox(width: 8), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('小镜', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), Text('AI 陪伴', style: TextStyle(fontSize: 11, color: MirrorColors.textSecondary))]),
    ]), actions: [IconButton(icon: const Icon(Icons.delete_outline, size: 20), tooltip: '清除对话', onPressed: _clear)]),
    body: Column(children: [
      Expanded(child: _cs.messages.isEmpty ? _empty(d) : ListView.builder(controller: _sc, padding: const EdgeInsets.all(16), itemCount: _cs.messages.length, itemBuilder: (_, i) { final m = _cs.messages[i]; return _bubble(m, m['role'] == 'user', d); })),
      if (_cs.lastError != null) Padding(padding: const EdgeInsets.all(8), child: Text(_cs.lastError!, style: const TextStyle(fontSize: 12, color: MirrorColors.error))),
      _input(d),
    ]));
  }

  Widget _paywall(bool d) => Scaffold(backgroundColor: d ? MirrorColors.darkBackground : MirrorColors.background, appBar: AppBar(title: const Text('与小镜对话')),
    body: Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(color: MirrorColors.primaryLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.lock_outline, color: MirrorColors.primary, size: 36)),
      const SizedBox(height: 20), const Text('需要配置 AI 服务', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12), const Text('配置 OpenAI Key 或升级 Pro 解锁云端 AI 对话', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary)),
      const SizedBox(height: 24), ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/pro', arguments: {'hint': '解锁 AI 对话'}), icon: const Icon(Icons.lock_open, size: 18), label: const Text('升级 Pro'), style: ElevatedButton.styleFrom(backgroundColor: MirrorColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14))),
    ]))));

  Widget _empty(bool d) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primaryDark]), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36)),
    const SizedBox(height: 20), Text('我是小镜', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: d ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary)),
    const SizedBox(height: 8), const Text('说说今天的心情，或者任何你想说的', style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary)),
    const SizedBox(height: 24), Wrap(spacing: 8, runSpacing: 8, children: [q('今天有点开心', d), q('最近有点焦虑', d), q('想分享一件事', d)]),
  ]));

  Widget q(String t, bool d) => ActionChip(label: Text(t, style: const TextStyle(fontSize: 13)), onPressed: () { _tc.text = t; _send(); }, backgroundColor: d ? MirrorColors.darkSurface : MirrorColors.cardBackground, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));

  Widget _bubble(Map<String, String> m, bool u, bool d) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: u ? MainAxisAlignment.end : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
    if (!u) ...[Container(width: 32, height: 32, decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary]), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)), const SizedBox(width: 8)],
    Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: u ? MirrorColors.primaryLight.withValues(alpha: 0.3) : (d ? MirrorColors.darkSurface : Colors.white), borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(u ? 16 : 4), bottomRight: Radius.circular(u ? 4 : 16))), child: Text(m['content'] ?? '', style: TextStyle(fontSize: 15, color: u ? MirrorColors.primaryDark : (d ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary))))),
    if (u) const SizedBox(width: 8),
  ]));

  Widget _input(bool d) => Container(padding: const EdgeInsets.fromLTRB(12, 8, 12, 16), decoration: BoxDecoration(color: d ? MirrorColors.darkSurface : Colors.white), child: SafeArea(top: false, child: Row(children: [
    Expanded(child: TextField(controller: _tc, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), decoration: InputDecoration(hintText: '有什么想跟我说的吗？', filled: true, fillColor: d ? MirrorColors.darkCardBackground : MirrorColors.cardBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)), maxLines: 3, minLines: 1)),
    const SizedBox(width: 8),
    Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary]), shape: BoxShape.circle), child: IconButton(onPressed: _cs.isThinking ? null : _send, icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20))),
  ])));
}
