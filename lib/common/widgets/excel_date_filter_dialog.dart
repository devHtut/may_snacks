import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateRangePreset {
  allTime,
  today,
  thisWeek,
  thisMonth,
  lastMonth,
  custom;

  String get displayName {
    switch (this) {
      case DateRangePreset.allTime:
        return 'All Time';
      case DateRangePreset.today:
        return 'Today';
      case DateRangePreset.thisWeek:
        return 'This Week';
      case DateRangePreset.thisMonth:
        return 'This Month';
      case DateRangePreset.lastMonth:
        return 'Last Month';
      case DateRangePreset.custom:
        return 'Custom Range';
    }
  }
}

class ExcelDateFilterDialog extends StatefulWidget {
  final String title;
  final String reportSubtitle;
  final Future<void> Function(DateTimeRange? dateRange, String durationLabel) onExport;

  const ExcelDateFilterDialog({
    super.key,
    required this.title,
    required this.reportSubtitle,
    required this.onExport,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String reportSubtitle,
    required Future<void> Function(DateTimeRange? dateRange, String durationLabel) onExport,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ExcelDateFilterDialog(
        title: title,
        reportSubtitle: reportSubtitle,
        onExport: onExport,
      ),
    );
  }

  @override
  State<ExcelDateFilterDialog> createState() => _ExcelDateFilterDialogState();
}

class _ExcelDateFilterDialogState extends State<ExcelDateFilterDialog> {
  DateRangePreset _selectedPreset = DateRangePreset.thisMonth;
  DateTimeRange? _customRange;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _computeRangeForPreset(_selectedPreset);
  }

  DateTimeRange? _computeRangeForPreset(DateRangePreset preset) {
    final now = DateTime.now();
    switch (preset) {
      case DateRangePreset.allTime:
        return null;
      case DateRangePreset.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case DateRangePreset.thisWeek:
        final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case DateRangePreset.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case DateRangePreset.lastMonth:
        final lastMonthDate = DateTime(now.year, now.month - 1, 1);
        final start = DateTime(lastMonthDate.year, lastMonthDate.month, 1);
        final lastDay = DateTime(now.year, now.month, 0).day;
        final end = DateTime(lastMonthDate.year, lastMonthDate.month, lastDay, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case DateRangePreset.custom:
        return _customRange ?? DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
    }
  }

  String _getDurationLabel(DateRangePreset preset, DateTimeRange? range) {
    if (range == null || preset == DateRangePreset.allTime) {
      return 'All Time';
    }
    final fmt = DateFormat('yyyy-MM-dd');
    return '${fmt.format(range.start)} to ${fmt.format(range.end)}';
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: _customRange ?? DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF0F766E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = DateRangePreset.custom;
        _customRange = DateTimeRange(
          start: DateTime(picked.start.year, picked.start.month, picked.start.day),
          end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeRange = _computeRangeForPreset(_selectedPreset);
    final durationLabel = _getDurationLabel(_selectedPreset, activeRange);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.table_chart_rounded, color: Color(0xFF0F766E), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  widget.reportSubtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Export Date Range:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DateRangePreset.values.map((preset) {
                final isSelected = _selectedPreset == preset;
                return ChoiceChip(
                  label: Text(preset.displayName),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0F766E).withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF0F766E) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      if (preset == DateRangePreset.custom) {
                        _pickCustomRange();
                      } else {
                        setState(() {
                          _selectedPreset = preset;
                        });
                      }
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 20, color: Color(0xFF0F766E)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Exporting Data Period:',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          durationLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedPreset == DateRangePreset.custom)
                    IconButton(
                      icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                      tooltip: 'Change Custom Dates',
                      onPressed: _pickCustomRange,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
          ),
          icon: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.file_download_rounded, size: 18),
          label: Text(_isExporting ? 'Generating...' : 'Download Excel'),
          onPressed: _isExporting
              ? null
              : () async {
                  setState(() {
                    _isExporting = true;
                  });
                  try {
                    await widget.onExport(activeRange, durationLabel);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isExporting = false;
                      });
                    }
                  }
                },
        ),
      ],
    );
  }
}
