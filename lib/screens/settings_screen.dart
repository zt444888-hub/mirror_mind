import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../providers/emotion_provider.dart';
import '../services/notification_service.dart';
import '../constants/colors.dart';
import '../services/purchase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  bool _obscureApiKey = true;
  bool _isExporting = false;

  // 提醒设置状态
  bool _dailyReminderEnabled = false;
  int _dailyHour = NotificationService.defaultDailyHour;
  int _dailyMinute = NotificationService.defaultDailyMinute;
  bool _breathingReminderEnabled = false;
  int _breathingHour = NotificationService.defaultBreathingHour;
  int _breathingMinute = NotificationService.defaultBreathingMinute;
  bool _challengeReminderEnabled = false;
  int _challengeHour = 20;
  int _challengeMinute = 0;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _baseUrlController = TextEditingController(text: settings.baseUrl);
    _apiKeyController = TextEditingController(text: settings.apiKey);
    _modelController = TextEditingController(text: settings.model);
    _loadReminderSettings();
    // 初始化 SettingsProvider 持久化
    settings.init();
  }

  /// 从 SharedPreferences 加载提醒设置
  Future<void> _loadReminderSettings() async {
    final dailyEnabled = await NotificationService.isDailyEnabled();
    final dailyTime = await NotificationService.getDailyTime();
    final breathingEnabled = await NotificationService.isBreathingEnabled();
    final breathingTime = await NotificationService.getBreathingTime();
    final challengeEnabled = await NotificationService.isChallengeEnabled();
    final challengeTime = await NotificationService.getChallengeTime();

    if (mounted) {
      setState(() {
        _dailyReminderEnabled = dailyEnabled;
        _dailyHour = dailyTime['hour']!;
        _dailyMinute = dailyTime['minute']!;
        _breathingReminderEnabled = breathingEnabled;
        _breathingHour = breathingTime['hour']!;
        _breathingMinute = breathingTime['minute']!;
        _challengeReminderEnabled = challengeEnabled;
        _challengeHour = challengeTime['hour']!;
        _challengeMinute = challengeTime['minute']!;
      });
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settings = context.read<SettingsProvider>();
    settings.setBaseUrl(_baseUrlController.text.trim());
    settings.setApiKey(_apiKeyController.text.trim());
    settings.setModel(_modelController.text.trim());

    // 同步到 EmotionProvider
    context.read<EmotionProvider>().updateAiConfig(
      baseUrl: settings.baseUrl,
      apiKey: settings.apiKey,
      model: settings.model,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置已保存'), backgroundColor: MirrorColors.secondary),
    );
  }

  Future<void> _exportData() async {
    // 导出前弹出确认警告
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('导出数据警告'),
        content: const Text('导出的 JSON 文件包含全部情绪记录原文，请妥善保管，避免隐私泄露。\n\n是否继续导出？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: MirrorColors.primary),
            child: const Text('确认导出', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isExporting = true);

    try {
      final provider = context.read<EmotionProvider>();
      final jsonStr = await provider.exportData();
      final fileName = 'mirror_mind_backup_${DateTime.now().toIso8601String().split('T')[0]}.json';

      // 保存到临时目录，然后通过系统分享菜单让用户选择保存位置
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '心镜数据备份',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e'), backgroundColor: MirrorColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _confirmDeleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('确认删除'),
        content: const Text('将删除所有情绪记录数据，此操作不可撤销。建议先导出备份。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: MirrorColors.error),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<EmotionProvider>().deleteAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有数据已清除'), backgroundColor: MirrorColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- API 配置 ---
          _buildSectionTitle('AI 配置'),
          const SizedBox(height: 8),
          // API Key 安全提示
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.amber.shade900.withValues(alpha: 0.15) : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade200, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, size: 20, color: Colors.amber.shade800),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '安全提示：建议使用临时 API Key，不要使用生产环境 Key。当前 Key 以明文存储在本地。',
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade800, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _baseUrlController,
                    label: 'API Base URL',
                    hint: 'https://api.openai.com/v1',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _apiKeyController,
                    label: 'API Key',
                    hint: 'sk-...',
                    obscure: _obscureApiKey,
                    suffix: IconButton(
                      icon: Icon(_obscureApiKey ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _modelController,
                    label: '模型名称',
                    hint: 'gpt-4o-mini',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text('保存设置'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- 显示 ---
          _buildSectionTitle('显示'),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('深色模式'),
              subtitle: const Text('切换深色/浅色主题'),
              value: settings.isDarkMode,
              onChanged: (val) => settings.toggleDarkMode(),
              activeColor: MirrorColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // --- 提醒设置 ---
          _buildSectionTitle('提醒设置'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                // 每日记录提醒
                SwitchListTile(
                  title: const Text('每日记录提醒'),
                  subtitle: Text(_dailyReminderEnabled
                      ? '每天 ${_formatReminderTime(_dailyHour, _dailyMinute)} 提醒记录情绪'
                      : '开启后每天定时提醒'),
                  value: _dailyReminderEnabled,
                  onChanged: _toggleDailyReminder,
                  activeColor: MirrorColors.primary,
                ),
                if (_dailyReminderEnabled)
                  ListTile(
                    title: const Text('提醒时间'),
                    trailing: TextButton(
                      onPressed: _pickDailyTime,
                      child: Text(
                        _formatReminderTime(_dailyHour, _dailyMinute),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: MirrorColors.primary),
                      ),
                    ),
                  ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // 7天挑战提醒
                SwitchListTile(
                  title: const Text('7天挑战提醒'),
                  subtitle: Text(_challengeReminderEnabled
                      ? '每天 ${_formatReminderTime(_challengeHour, _challengeMinute)} 提醒完成挑战任务'
                      : '开始挑战后每天定时提醒'),
                  value: _challengeReminderEnabled,
                  onChanged: _toggleChallengeReminder,
                  activeColor: MirrorColors.primary,
                ),
                if (_challengeReminderEnabled)
                  ListTile(
                    title: const Text('提醒时间'),
                    trailing: TextButton(
                      onPressed: _pickChallengeTime,
                      child: Text(
                        _formatReminderTime(_challengeHour, _challengeMinute),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: MirrorColors.primary),
                      ),
                    ),
                  ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // 呼吸练习提醒
                SwitchListTile(
                  title: const Text('呼吸练习提醒'),
                  subtitle: Text(_breathingReminderEnabled
                      ? '每天 ${_formatReminderTime(_breathingHour, _breathingMinute)} 提醒做呼吸练习'
                      : '开启后每天定时提醒'),
                  value: _breathingReminderEnabled,
                  onChanged: _toggleBreathingReminder,
                  activeColor: MirrorColors.primary,
                ),
                if (_breathingReminderEnabled)
                  ListTile(
                    title: const Text('提醒时间'),
                    trailing: TextButton(
                      onPressed: _pickBreathingTime,
                      child: Text(
                        _formatReminderTime(_breathingHour, _breathingMinute),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: MirrorColors.primary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- 数据管理 ---
          _buildSectionTitle('数据管理'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download, color: MirrorColors.primary),
                  title: const Text('导出数据'),
                  subtitle: const Text('将所有记录导出为 JSON 文件'),
                  trailing: _isExporting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right),
                  onTap: _isExporting ? null : _exportData,
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: MirrorColors.error),
                  title: const Text('清空所有数据'),
                  subtitle: const Text('删除所有情绪记录（建议先导出）'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _confirmDeleteAll,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- 关于 ---
          _buildSectionTitle('关于'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: MirrorColors.primary),
                  title: const Text('心镜 MirrorMind'),
                  subtitle: const Text('版本 1.0.0'),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: MirrorColors.primary),
                  title: const Text('隐私政策'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const Icon(Icons.copyright, color: MirrorColors.primary),
                  title: const Text('开发者'),
                  subtitle: const Text('MirrorMind Team'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 心镜 Pro 入口
          _buildProCard(isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==================== 提醒设置 ====================

  /// 格式化提醒时间
  String _formatReminderTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// 每日记录提醒开关
  Future<void> _toggleDailyReminder(bool val) async {
    setState(() => _dailyReminderEnabled = val);
    final notificationService = NotificationService.instance;
    if (val) {
      await notificationService.scheduleDailyReminder(
        hour: _dailyHour,
        minute: _dailyMinute,
      );
    } else {
      await notificationService.cancelDailyReminder();
    }
  }

  /// 选择每日记录提醒时间
  Future<void> _pickDailyTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _dailyHour, minute: _dailyMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: MirrorColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _dailyHour = time.hour;
        _dailyMinute = time.minute;
      });
      await NotificationService.instance.scheduleDailyReminder(
        hour: _dailyHour,
        minute: _dailyMinute,
      );
    }
  }

  /// 呼吸练习提醒开关
  Future<void> _toggleBreathingReminder(bool val) async {
    setState(() => _breathingReminderEnabled = val);
    final notificationService = NotificationService.instance;
    if (val) {
      await notificationService.scheduleBreathingReminder(
        hour: _breathingHour,
        minute: _breathingMinute,
      );
    } else {
      await notificationService.cancelBreathingReminder();
    }
  }

  /// 选择呼吸练习提醒时间
  Future<void> _pickBreathingTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _breathingHour, minute: _breathingMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: MirrorColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _breathingHour = time.hour;
        _breathingMinute = time.minute;
      });
      await NotificationService.instance.scheduleBreathingReminder(
        hour: _breathingHour,
        minute: _breathingMinute,
      );
    }
  }

  /// 挑战提醒开关
  Future<void> _toggleChallengeReminder(bool val) async {
    if (val && !PurchaseService().isPro) {
      setState(() => _challengeReminderEnabled = false);
      if (mounted) {
        final goPro = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Pro 功能'),
            content: const Text('挑战提醒为 Pro 功能，升级后解锁全部三种提醒。'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('暂不')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('去升级'),
              ),
            ],
          ),
        );
        if (goPro == true && mounted) {
          Navigator.pushNamed(context, '/pro');
        }
      }
      return;
    }
    setState(() => _challengeReminderEnabled = val);
    final notificationService = NotificationService.instance;
    if (val) {
      await notificationService.scheduleChallengeReminder(
        hour: _challengeHour,
        minute: _challengeMinute,
      );
    } else {
      await notificationService.cancelChallengeReminder();
    }
  }

  /// 选择挑战提醒时间
  Future<void> _pickChallengeTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _challengeHour, minute: _challengeMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: MirrorColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _challengeHour = time.hour;
        _challengeMinute = time.minute;
      });
      await NotificationService.instance.scheduleChallengeReminder(
        hour: _challengeHour,
        minute: _challengeMinute,
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MirrorColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? MirrorColors.darkSurface
                : MirrorColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// 心镜 Pro 入口卡片
  Widget _buildProCard(bool isDark) {
    final isPro = PurchaseService().isPro;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: Icon(
          isPro ? Icons.verified : Icons.workspace_premium,
          color: isPro ? MirrorColors.secondary : MirrorColors.primaryDark,
          size: 28,
        ),
        title: Text(
          isPro ? '心镜 Pro · 已解锁' : '升级到心镜 Pro',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isPro ? MirrorColors.secondary : (isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary),
          ),
        ),
        subtitle: Text(
          isPro ? '感谢你的支持，全部高级功能已永久激活' : '¥68 一次性买断，永久解锁',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
          ),
        ),
        trailing: isPro
            ? const Icon(Icons.check_circle, color: MirrorColors.secondary)
            : Icon(Icons.chevron_right, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
        onTap: () {
          if (isPro) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('心镜 Pro 已解锁，感谢你的支持'),
                backgroundColor: MirrorColors.secondary,
              ),
            );
          } else {
            Navigator.pushNamed(context, '/pro');
          }
        },
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('隐私政策'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('数据收集声明', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('心镜仅存储您主动输入的情绪记录文字。'),
              SizedBox(height: 16),
              Text('存储方式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('所有数据存储在设备本地 sqflite 数据库中，不上传至任何服务器。'),
              SizedBox(height: 16),
              Text('AI 分析', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('仅在您主动点击"AI分析"时，通过 HTTPS 加密将您输入的文本传输至您自行配置的 API 端点。'),
              SizedBox(height: 16),
              Text('我们不会收集您的任何个人信息（姓名、邮箱、位置、设备ID等），也不会与任何第三方共享数据。'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }
}
