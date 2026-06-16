import 'package:flutter/material.dart';
import '../services/ai_chat_service.dart';
import '../constants/colors.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiChatService _cs = AiChatService();
  final TextEditingController _tc = TextEditingController();
  final ScrollController _sc = ScrollController();
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _cs.addListener(() { if (mounted) setState(() {}); });
    _cs.loadHistory().then((_) { if (mounted) setState(() => _init = true); });
  }

  @override
  void dispose() { _tc.dispose(); _sc.dispose(); _cs.dispose(); super.dispose(); }

  bool _sending = false; // 闃查噸澶嶉攣

  void _send() async {
    if (_sending) return; // 姝ｅ湪鍙戦€佷腑锛屽拷鐣?
    final t = _tc.text.trim();
    if (t.isEmpty || _cs.isThinking) return;
    _sending = true;
    _tc.clear();
    await _cs.sendMessage(t);
    _sending = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sc.hasClients) _sc.animateTo(_sc.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;

    return Column(children: [
      if (_cs.messages.isEmpty)
        Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primaryDark]), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32)),
          const SizedBox(height: 16), const Text('鎴戞槸灏忛暅', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8), const Text('璇磋浠婂ぉ鐨勫績鎯咃紝鎴栬€呬换浣曚綘鎯宠鐨?, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary)),
        ]))))
      else
        Expanded(child: ListView.builder(controller: _sc, padding: const EdgeInsets.all(16), itemCount: _cs.messages.length, itemBuilder: (_, i) {
          final m = _cs.messages[i]; final u = m['role'] == 'user';
          return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: u ? MainAxisAlignment.end : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (!u) ...[Container(width: 28, height: 28, decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14)), const SizedBox(width: 6)],
            Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: u ? Color(0x80D4C5E2) : (d ? MirrorColors.darkSurface : Colors.white), borderRadius: BorderRadius.only(topLeft: const Radius.circular(14), topRight: const Radius.circular(14), bottomLeft: Radius.circular(u ? 14 : 4), bottomRight: Radius.circular(u ? 4 : 14))), child: Text(m['content'] ?? '', style: TextStyle(fontSize: 15, color: u ? MirrorColors.primaryDark : (d ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary))))),
            if (u) const SizedBox(width: 6),
          ]));
        })),

      if (_cs.isThinking) Padding(padding: const EdgeInsets.only(left: 16, bottom: 4), child: Row(children: [
        Container(width: 24, height: 24, decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary]), borderRadius: BorderRadius.circular(6)), child: const Center(child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))), const SizedBox(width: 6), const Text('灏忛暅姝ｅ湪杈撳叆...', style: TextStyle(fontSize: 12, color: MirrorColors.textHint)),
      ])),

      Container(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), decoration: BoxDecoration(color: d ? MirrorColors.darkSurface : Colors.white, boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: const Offset(0, -2))]),
        child: SafeArea(top: false, child: Row(children: [
          Expanded(child: TextField(controller: _tc, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), decoration: InputDecoration(hintText: '鏈変粈涔堟兂璺熸垜璇寸殑鍚楋紵', filled: true, fillColor: d ? MirrorColors.darkCardBackground : MirrorColors.cardBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)), maxLines: 3, minLines: 1)),
          const SizedBox(width: 8),
          Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary]), shape: BoxShape.circle), child: IconButton(onPressed: _cs.isThinking ? null : _send, icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20))),
        ]))),
    ]);
  }
}

