import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/reminder_settings.dart';
import '../../services/notification_service.dart';
import '../widgets/time_picker_widget.dart';

/// 新しいデザインの設定画面
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isTestNotificationSuccess = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(reminderSettingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Reminder Settings Section
                    _buildReminderSection(context, settings),

                    // Appearance & View Section
                    _buildAppearanceSection(context),

                    // App Information Section
                    _buildAppInfoSection(context),

                    const SizedBox(height: 32),

                    // Footer
                    Text(
                      'すべての読者のために ❤️ を込めて',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0).withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/solar-arrow-left-linear.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0F172A),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '設定',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSection(BuildContext context, ReminderSettings settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // Section Header
          Text(
            'リマインダー設定',
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),

          // Card Container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Daily Reminders Toggle
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/solar-bell-bing-bold.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF3730A3),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '毎日のリマインダー',
                              style: GoogleFonts.instrumentSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '読書を続けるための通知',
                              style: GoogleFonts.instrumentSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(reminderSettingsProvider.notifier).toggleEnabled();
                        },
                        child: _buildToggleSwitch(settings.enabled),
                      ),
                    ],
                  ),
                ),

                // Settings Details (shown when enabled)
                if (settings.enabled) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFE2E8F0).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Notification Time
                        _buildTimePicker(context, settings),

                        const SizedBox(height: 24),

                        // Article to Recommend
                        _buildArticleSelection(context, settings),

                        const SizedBox(height: 24),

                        // Repeat on (Days)
                        _buildDaysSelection(context, settings),
                      ],
                    ),
                  ),

                  // Test Notification Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _sendTestNotification,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/solar-notification-lines-bold.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF334155),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'テスト通知',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Success Message
                        if (_isTestNotificationSuccess) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/solar-check-circle-bold.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF16A34A),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '通知が正常に送信されました！',
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(bool isOn) {
    return Container(
      width: 48,
      height: 24,
      decoration: BoxDecoration(
        color: isOn ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(2),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, ReminderSettings settings) {
    final isAM = settings.hour < 12;
    final displayHour = settings.hour == 0 ? 12 : (settings.hour > 12 ? settings.hour - 12 : settings.hour);
    final displayTime = '${displayHour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '通知時刻',
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickTime(context, settings),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayTime,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildAMPMButton('AM', isAM),
                      _buildAMPMButton('PM', !isAM),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAMPMButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.instrumentSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildArticleSelection(BuildContext context, ReminderSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'おすすめする記事',
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildArticleOption(
              context,
              'ランダムな記事',
              'solar-shuffle-bold.svg',
              ReminderMode.random,
              settings.mode == ReminderMode.random,
              () {
                ref.read(reminderSettingsProvider.notifier).setMode(ReminderMode.random);
              },
            ),
            const SizedBox(height: 8),
            _buildArticleOption(
              context,
              '古い順',
              'solar-history-bold.svg',
              ReminderMode.oldest,
              settings.mode == ReminderMode.oldest,
              () {
                ref.read(reminderSettingsProvider.notifier).setMode(ReminderMode.oldest);
              },
            ),
            const SizedBox(height: 8),
            _buildArticleOption(
              context,
              '新しい順',
              'solar-star-fall-bold.svg',
              ReminderMode.newest,
              settings.mode == ReminderMode.newest,
              () {
                ref.read(reminderSettingsProvider.notifier).setMode(ReminderMode.newest);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArticleOption(
    BuildContext context,
    String label,
    String iconPath,
    ReminderMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0E7FF).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$iconPath',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSelection(BuildContext context, ReminderSettings settings) {
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '通知する曜日',
          style: GoogleFonts.instrumentSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isSelected = settings.activeDays.contains(index);
            return GestureDetector(
              onTap: () {
                ref.read(reminderSettingsProvider.notifier).toggleDay(index);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1E293B).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: GoogleFonts.instrumentSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          Text(
            '外観設定',
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsItem(
                  'テーマ設定',
                  'solar-palette-bold.svg',
                  'システム設定',
                  () {
                    // TODO: Theme設定画面へ遷移
                  },
                ),
                Container(
                  height: 1,
                  color: const Color(0xFFE2E8F0).withOpacity(0.4),
                ),
                _buildSettingsItem(
                  'デフォルト表示フィルター',
                  'solar-filter-bold.svg',
                  '未読を優先',
                  () {
                    // TODO: Filter設定画面へ遷移
                  },
                ),
                Container(
                  height: 1,
                  color: const Color(0xFFE2E8F0).withOpacity(0.4),
                ),
                _buildSettingsItem(
                  'アカウント管理',
                  'solar-user-block-bold.svg',
                  null,
                  () {
                    // TODO: アカウント管理画面へ遷移
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    String iconPath,
    String? subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$iconPath',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isDestructive ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.instrumentSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
            ],
            SvgPicture.asset(
              'assets/icons/solar-alt-arrow-right-linear.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Color(0xFF64748B),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          Text(
            'アプリ情報',
            style: GoogleFonts.instrumentSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '📚',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Yommy',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'バージョン 2.4.1 (ビルド 108)',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Yommyは、読書リストを管理し、賢いリマインダーで興味深い記事を読み逃さないようにサポートします。',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoButton(
                        'プライバシーポリシー',
                        'solar-shield-check-bold.svg',
                        () {
                          // TODO: プライバシーポリシーを開く
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoButton(
                        'サポート',
                        'solar-chat-round-line-bold.svg',
                        () {
                          // TODO: サポートページを開く
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton(String label, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/icons/$iconPath',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF1E293B),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, ReminderSettings settings) async {
    await showDrumRollTimePicker(
      context: context,
      initialHour: settings.hour,
      initialMinute: settings.minute,
      onTimeChanged: (hour, minute) {
        ref.read(reminderSettingsProvider.notifier).setTime(hour, minute);
      },
    );
  }

  Future<void> _sendTestNotification() async {
    try {
      await NotificationService.instance.showTestNotification();
      
      setState(() {
        _isTestNotificationSuccess = true;
      });

      // 3秒後に成功メッセージを非表示
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isTestNotificationSuccess = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('通知の送信に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}