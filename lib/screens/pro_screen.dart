import 'package:flutter/material.dart';
import '../services/purchase_service.dart';
import '../constants/colors.dart';

/// 浠樿垂澧欓〉闈細瑙ｉ攣蹇冮暅 Pro
class ProScreen extends StatefulWidget {
  /// 鍙€夋彁绀烘枃瀛楋紙濡?瑙ｉ攣楂樼骇鍐ユ兂"锛夛紝鏄剧ず鍦ㄩ《閮?
  final String? hint;

  const ProScreen({super.key, this.hint});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  bool _isBuying = false;
  bool _isRestoring = false;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _isPro = PurchaseService().isPro;
  }

  Future<void> _handleBuy() async {
    setState(() => _isBuying = true);
    try {
      final errorMsg = await PurchaseService().buyPro();
      if (errorMsg == null) {
        // 璐拱璇锋眰宸插彂鍑猴紝缁撴灉閫氳繃 purchase stream 寮傛杩斿洖
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          _checkProStatus();
        }
      } else {
        // 璐拱鍙戣捣澶辫触
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: MirrorColors.warm,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isRestoring = true);
    try {
      await PurchaseService().restorePurchases();
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _checkProStatus();
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  void _checkProStatus() {
    final isPro = PurchaseService().isPro;
    if (isPro) {
      setState(() => _isPro = true);
      _showSuccessAndPop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('璐拱灏氭湭瀹屾垚锛岃绋嶅悗閲嶈瘯鎴栨仮澶嶈喘涔?),
          backgroundColor: MirrorColors.warm,
        ),
      );
    }
  }

  void _showSuccessAndPop() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [MirrorColors.primaryLight, MirrorColors.primary],
                  ),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                '鎭枩锛佸凡瑙ｉ攣蹇冮暅 Pro',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: MirrorColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                '鍏ㄩ儴楂樼骇鍔熻兘宸叉案涔呮縺娲籠n鎰夸綘涓庡績闀滀竴璺悓琛?,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('寮€濮嬩綋楠?),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isPro) {
      return Scaffold(
        backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
        appBar: AppBar(title: const Text('蹇冮暅 Pro')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, size: 64, color: MirrorColors.secondary),
              SizedBox(height: 16),
              Text('蹇冮暅 Pro 路 宸茶В閿?, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('鎰熻阿浣犵殑鏀寔', style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('瑙ｉ攣蹇冮暅 Pro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 椤堕儴鏍囪
            if (widget.hint != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0x80FBEAE3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open, size: 18, color: MirrorColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.hint!,
                        style: const TextStyle(fontSize: 13, color: MirrorColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 鏍囬鍖?
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MirrorColors.primaryLight, MirrorColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x40FFFFFF),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '蹇冮暅 Pro',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '涓€娆¤喘涔帮紝缁堣韩浣跨敤',
                    style: TextStyle(fontSize: 14, color: Color(0xD9FFFFFF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 鍔熻兘瀵规瘮
            _buildSectionTitle('鍏嶈垂鐗?vs Pro'),
            const SizedBox(height: 12),
            _buildComparisonCard(isDark),
            const SizedBox(height: 28),

            // 浠锋牸鍗＄墖
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? MirrorColors.darkCardBackground : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: MirrorColors.primaryLight, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33D4C5E2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '涓€娆℃€ц喘涔?,
                    style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '楼68',
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: MirrorColors.primaryDark, height: 1),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '姘镐箙瑙ｉ攣鍏ㄩ儴楂樼骇鍔熻兘',
                    style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isBuying ? null : _handleBuy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MirrorColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        elevation: 0,
                      ),
                      child: _isBuying
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('绔嬪嵆璐拱'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 鎭㈠璐拱
            TextButton(
              onPressed: _isRestoring ? null : _handleRestore,
              child: _isRestoring
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('鎭㈠璐拱', style: TextStyle(color: MirrorColors.textSecondary)),
            ),

            // 缁х画浣跨敤鍏嶈垂鐗?
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('缁х画浣跨敤鍏嶈垂鐗?, style: TextStyle(color: MirrorColors.textHint)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary),
      ),
    );
  }

  Widget _buildComparisonCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            _buildComparisonHeader(),
            const TableRow(children: [SizedBox(height: 12), SizedBox(), SizedBox()]),
            _buildComparisonRow('鍐ユ兂寮曞', '3 绉嶆ā寮?, '6 绉嶆ā寮廫n+ 鑷畾涔夋椂闀?),
            _buildComparisonRow('璁ょ煡鍗＄墖', '20 寮犲熀纭€', '4 涓繘闃朵富棰樺寘\n48 寮犺繘闃跺崱鐗?),
            _buildComparisonRow('鎯呯华璇嶅簱', '44 璇?, '72 璇峔n+ 娣卞害璇嶈В'),
            _buildComparisonRow('蹇冩儏鍗＄墖', '3 绉嶆ā鏉?, '鍏?7 绉嶇簿缇庢ā鏉縗n+ 鑷畾涔夐厤鑹?),
            _buildComparisonRow('鎯呯华瓒嬪娍', '7 澶╃畝鍗曡褰?, '30 澶╄秼鍔挎洸绾縗n+ Tag 鎯呯华绛涢€?),
            _buildComparisonRow('PDF 鎶ュ憡', '鍛ㄦ姤', '鍛ㄦ姤 + 鏈堟姤\n+ 骞村害鎶ュ憡'),
            _buildComparisonRow('鎻愰啋璁剧疆', '2 绉嶆彁閱?, '3 绉嶆彁閱抃n鍏ㄩ儴鍙敤'),
            _buildComparisonRow('AI 瀵硅瘽', '闇€鑷 API Key', '鐩存帴鍙敤\n浜戠灏忛暅闄綘鑱?),
          ],
        ),
      ),
    );
  }

  TableRow _buildComparisonHeader() {
    return const TableRow(
      children: [
        Text('鍔熻兘', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MirrorColors.textPrimary)),
        Text('鍏嶈垂鐗?, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
        Text('Pro', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark)),
      ],
    );
  }

  TableRow _buildComparisonRow(String feature, String free, String pro) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(feature, style: const TextStyle(fontSize: 14, color: MirrorColors.textPrimary)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(free, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: MirrorColors.textSecondary, height: 1.5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(pro, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: MirrorColors.primaryDark, fontWeight: FontWeight.w600, height: 1.5)),
        ),
      ],
    );
  }
}

