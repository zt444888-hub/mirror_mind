import 'package:flutter/material.dart';
import '../services/purchase_service.dart';
import '../constants/colors.dart';

/// 付费墙页面：解锁心镜 Pro
class ProScreen extends StatefulWidget {
  /// 可选提示文字（如"解锁高级冥想"），显示在顶部
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
        // 购买请求已发出，结果通过 purchase stream 异步返回
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          _checkProStatus();
        }
      } else {
        // 购买发起失败
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
          content: Text('购买尚未完成，请稍后重试或恢复购买'),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [MirrorColors.primaryLight, MirrorColors.primary],
                  ),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                '恭喜！已解锁心镜 Pro',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: MirrorColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                '全部高级功能已永久激活\n愿你与心镜一路同行',
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
                child: const Text('开始体验'),
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
        appBar: AppBar(title: const Text('心镜 Pro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, size: 64, color: MirrorColors.secondary),
              const SizedBox(height: 16),
              const Text('心镜 Pro · 已解锁', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('感谢你的支持', style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('解锁心镜 Pro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 顶部标语
            if (widget.hint != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: MirrorColors.accentLight.withValues(alpha: 0.3),
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

            // 标题区
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
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '心镜 Pro',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '一次购买，终身使用',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 功能对比
            _buildSectionTitle('免费版 vs Pro'),
            const SizedBox(height: 12),
            _buildComparisonCard(isDark),
            const SizedBox(height: 28),

            // 价格卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? MirrorColors.darkCardBackground : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: MirrorColors.primaryLight, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: MirrorColors.primaryLight.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '一次性购买',
                    style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '¥68',
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: MirrorColors.primaryDark, height: 1),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '永久解锁全部高级功能',
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
                          : const Text('立即购买'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 恢复购买
            TextButton(
              onPressed: _isRestoring ? null : _handleRestore,
              child: _isRestoring
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('恢复购买', style: TextStyle(color: MirrorColors.textSecondary)),
            ),

            // 继续使用免费版
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('继续使用免费版', style: TextStyle(color: MirrorColors.textHint)),
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
            _buildComparisonRow('冥想引导', '3 种模式', '6 种模式\n+ 自定义时长'),
            _buildComparisonRow('认知卡片', '20 张基础', '4 个进阶主题包\n48 张进阶卡片'),
            _buildComparisonRow('情绪词库', '44 词', '72 词\n+ 深度词解'),
            _buildComparisonRow('心情卡片', '3 种模板', '共 7 种精美模板\n+ 自定义配色'),
            _buildComparisonRow('情绪趋势', '7 天简单记录', '30 天趋势曲线\n+ Tag 情绪筛选'),
            _buildComparisonRow('PDF 报告', '周报', '周报 + 月报\n+ 年度报告'),
            _buildComparisonRow('提醒设置', '2 种提醒', '3 种提醒\n全部可用'),
          ],
        ),
      ),
    );
  }

  TableRow _buildComparisonHeader() {
    return const TableRow(
      children: [
        Text('功能', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MirrorColors.textPrimary)),
        Text('免费版', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
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
