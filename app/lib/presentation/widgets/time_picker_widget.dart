import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ドラムロール風の時刻ピッカー
class DrumRollTimePicker extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final Function(int hour, int minute) onTimeChanged;

  const DrumRollTimePicker({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.onTimeChanged,
  });

  @override
  State<DrumRollTimePicker> createState() => _DrumRollTimePickerState();
}

class _DrumRollTimePickerState extends State<DrumRollTimePicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedPeriod; // 0 = AM, 1 = PM

  @override
  void initState() {
    super.initState();
    
    // 24時間表記を12時間表記に変換
    final isAM = widget.initialHour < 12;
    _selectedPeriod = isAM ? 0 : 1;
    
    if (widget.initialHour == 0) {
      _selectedHour = 12;
    } else if (widget.initialHour > 12) {
      _selectedHour = widget.initialHour - 12;
    } else {
      _selectedHour = widget.initialHour;
    }
    
    _selectedMinute = widget.initialMinute;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _periodController = FixedExtentScrollController(initialItem: _selectedPeriod);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _updateTime() {
    // 12時間表記を24時間表記に変換
    int hour24;
    if (_selectedPeriod == 0) {
      // AM
      hour24 = _selectedHour == 12 ? 0 : _selectedHour;
    } else {
      // PM
      hour24 = _selectedHour == 12 ? 12 : _selectedHour + 12;
    }
    
    widget.onTimeChanged(hour24, _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '時刻を設定',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ピッカー本体
          Expanded(
            child: Stack(
              children: [
                // 選択範囲の背景
                Center(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                ),

                // ピッカー
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 時間
                    SizedBox(
                      width: 70,
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourController,
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedHour = index + 1;
                          });
                          _updateTime();
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 12,
                          builder: (context, index) {
                            final hour = index + 1;
                            final isSelected = hour == _selectedHour;
                            return Center(
                              child: Text(
                                hour.toString().padLeft(2, '0'),
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: isSelected ? 28 : 20,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // コロン
                    Text(
                      ':',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),

                    // 分
                    SizedBox(
                      width: 70,
                      child: ListWheelScrollView.useDelegate(
                        controller: _minuteController,
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedMinute = index;
                          });
                          _updateTime();
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 60,
                          builder: (context, index) {
                            final isSelected = index == _selectedMinute;
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: isSelected ? 28 : 20,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // AM/PM
                    SizedBox(
                      width: 60,
                      child: ListWheelScrollView.useDelegate(
                        controller: _periodController,
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedPeriod = index;
                          });
                          _updateTime();
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 2,
                          builder: (context, index) {
                            final period = index == 0 ? 'AM' : 'PM';
                            final isSelected = index == _selectedPeriod;
                            return Center(
                              child: Text(
                                period,
                                style: GoogleFonts.instrumentSans(
                                  fontSize: isSelected ? 20 : 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 完了ボタン
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '完了',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ドラムロール風時刻ピッカーを表示するヘルパー関数
Future<void> showDrumRollTimePicker({
  required BuildContext context,
  required int initialHour,
  required int initialMinute,
  required Function(int hour, int minute) onTimeChanged,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16),
      child: DrumRollTimePicker(
        initialHour: initialHour,
        initialMinute: initialMinute,
        onTimeChanged: onTimeChanged,
      ),
    ),
  );
}