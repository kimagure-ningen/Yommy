import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../data/models/reminder_settings.dart';
import '../../services/notification_service.dart';

/// Settings screen for reminder configuration
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(reminderSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          // Reminder Section
          _buildSectionHeader(context, 'リマインダー'),

          // Enable toggle
          SwitchListTile(
            title: const Text('リマインダーを有効にする'),
            subtitle: Text(
              settings.enabled ? '毎日お知らせします' : '通知はオフです',
            ),
            value: settings.enabled,
            onChanged: (_) {
              ref.read(reminderSettingsProvider.notifier).toggleEnabled();
            },
          ),

          // Time picker
          ListTile(
            title: const Text('通知時刻'),
            subtitle: Text(settings.formattedTime),
            trailing: const Icon(Icons.chevron_right),
            enabled: settings.enabled,
            onTap: () => _pickTime(context, ref, settings),
          ),

          // Reminder mode
          ListTile(
            title: const Text('記事の選び方'),
            subtitle: Text(settings.modeDescription),
            trailing: const Icon(Icons.chevron_right),
            enabled: settings.enabled,
            onTap: () => _selectMode(context, ref, settings),
          ),

          // Active days
          ListTile(
            title: const Text('通知する曜日'),
            subtitle: Text(_formatActiveDays(settings.activeDays)),
            trailing: const Icon(Icons.chevron_right),
            enabled: settings.enabled,
            onTap: () => _selectDays(context, ref, settings),
          ),

          const Divider(),

          // Test notification
          _buildSectionHeader(context, 'テスト'),

          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('テスト通知を送る'),
            subtitle: const Text('通知が正しく届くか確認します'),
            onTap: () => _sendTestNotification(context),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(context, 'アプリについて'),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Yommy'),
            subtitle: const Text('バージョン 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    ReminderSettings settings,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
    );

    if (time != null) {
      ref.read(reminderSettingsProvider.notifier).setTime(
            time.hour,
            time.minute,
          );
    }
  }

  Future<void> _selectMode(
    BuildContext context,
    WidgetRef ref,
    ReminderSettings settings,
  ) async {
    final mode = await showDialog<ReminderMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('記事の選び方'),
        children: [
          RadioListTile<ReminderMode>(
            title: const Text('ランダム'),
            subtitle: const Text('未読からランダムに選びます'),
            value: ReminderMode.random,
            groupValue: settings.mode,
            onChanged: (value) => Navigator.pop(context, value),
          ),
          RadioListTile<ReminderMode>(
            title: const Text('古い順'),
            subtitle: const Text('追加した順に古いものから'),
            value: ReminderMode.oldest,
            groupValue: settings.mode,
            onChanged: (value) => Navigator.pop(context, value),
          ),
          RadioListTile<ReminderMode>(
            title: const Text('新しい順'),
            subtitle: const Text('最近追加したものから'),
            value: ReminderMode.newest,
            groupValue: settings.mode,
            onChanged: (value) => Navigator.pop(context, value),
          ),
        ],
      ),
    );

    if (mode != null) {
      ref.read(reminderSettingsProvider.notifier).setMode(mode);
    }
  }

  Future<void> _selectDays(
    BuildContext context,
    WidgetRef ref,
    ReminderSettings settings,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => _DaySelectionDialog(
        activeDays: settings.activeDays,
        onDayToggled: (day) {
          ref.read(reminderSettingsProvider.notifier).toggleDay(day);
        },
      ),
    );
  }

  Future<void> _sendTestNotification(BuildContext context) async {
    await NotificationService.instance.showTestNotification();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('テスト通知を送りました！')),
      );
    }
  }

  String _formatActiveDays(List<int> days) {
    if (days.length == 7) return '毎日';
    if (days.isEmpty) return '通知なし';

    const dayNames = ['月', '火', '水', '木', '金', '土', '日'];
    return days.map((d) => dayNames[d]).join('・');
  }
}

/// Dialog for selecting active days
class _DaySelectionDialog extends StatefulWidget {
  final List<int> activeDays;
  final void Function(int) onDayToggled;

  const _DaySelectionDialog({
    required this.activeDays,
    required this.onDayToggled,
  });

  @override
  State<_DaySelectionDialog> createState() => _DaySelectionDialogState();
}

class _DaySelectionDialogState extends State<_DaySelectionDialog> {
  late List<int> _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = List.from(widget.activeDays);
  }

  @override
  Widget build(BuildContext context) {
    const dayNames = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];

    return AlertDialog(
      title: const Text('通知する曜日'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(7, (index) {
          return CheckboxListTile(
            title: Text(dayNames[index]),
            value: _selectedDays.contains(index),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedDays.add(index);
                } else {
                  _selectedDays.remove(index);
                }
                _selectedDays.sort();
              });
              widget.onDayToggled(index);
            },
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('完了'),
        ),
      ],
    );
  }
}
