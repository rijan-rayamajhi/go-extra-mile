// filename: date_picker_utils.dart
// requires: intl: ^0.19.0 (for formatting)

import 'dart:io' show Platform;
import 'dart:ui' as ui show TextDirection;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Centralized date/time picking utilities.
/// Usage examples are at the bottom of this file.
class DatePickerUtils {
  DatePickerUtils._(); // no instances

  /// Common constraints you can reuse.
  static final DateTime kDefaultFirstDate = DateTime(1900, 1, 1);
  static final DateTime kDefaultLastDate = DateTime(2100, 12, 31);

  /// Format a DateTime with a locale-aware pattern.
  /// Example: formatDate(date, pattern: 'dd MMM yyyy')
  static String formatDate(
    DateTime? date, {
    String pattern = 'yyyy-MM-dd',
    String? locale,
    bool useLocalTime = true,
  }) {
    if (date == null) return '';
    final d = useLocalTime ? date.toLocal() : date.toUtc();
    return DateFormat(pattern, locale).format(d);
  }

  /// Format a DateTimeRange as "start – end" with a single formatter.
  static String formatRange(
    DateTimeRange? range, {
    String pattern = 'yyyy-MM-dd',
    String separator = ' – ',
    String? locale,
    bool useLocalTime = true,
  }) {
    if (range == null) return '';
    return [
      formatDate(range.start, pattern: pattern, locale: locale, useLocalTime: useLocalTime),
      formatDate(range.end, pattern: pattern, locale: locale, useLocalTime: useLocalTime),
    ].join(separator);
  }

  /// Pick a calendar date (Material on all platforms).
  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    Locale? locale,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    String? helpText,
    String? confirmText,
    String? cancelText,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
      ui.TextDirection? textDirection,
    Widget Function(BuildContext, Widget?)? builder,
  }) async {
    final now = DateTime.now();
    final init = initialDate ?? now;
    return showDatePicker(
      context: context,
      initialDate: init,
      firstDate: firstDate ?? kDefaultFirstDate,
      lastDate: lastDate ?? kDefaultLastDate,
      locale: locale,
      initialEntryMode: initialEntryMode,
      helpText: helpText,
      confirmText: confirmText,
      cancelText: cancelText,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      fieldHintText: fieldHintText,
      fieldLabelText: fieldLabelText,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: builder,
      textDirection: textDirection,
    );
  }

  /// Pick a date range (Material).
  static Future<DateTimeRange?> pickDateRange(
    BuildContext context, {
    DateTimeRange? initialRange,
    DateTime? firstDate,
    DateTime? lastDate,
    Locale? locale,
    String? helpText,
    String? confirmText,
    String? cancelText,
    String? saveText,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Widget Function(BuildContext, Widget?)? builder,
      ui.TextDirection? textDirection,
  }) async {
    final now = DateTime.now();
    final initRange = initialRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day).add(const Duration(days: 6)),
        );

    return showDateRangePicker(
      context: context,
      initialDateRange: initRange,
      firstDate: firstDate ?? kDefaultFirstDate,
      lastDate: lastDate ?? kDefaultLastDate,
      locale: locale,
      helpText: helpText,
      confirmText: confirmText,
      cancelText: cancelText,
      saveText: saveText,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: builder,
      textDirection: textDirection,
    );
  }

  /// Pick a time (Material).
  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    TimeOfDay? initialTime,
    String? helpText,
    String? confirmText,
    String? cancelText,
    Widget Function(BuildContext, Widget?)? builder,
    bool use24HourFormat = false,
  }) async {
    final now = TimeOfDay.now();
    final res = await showTimePicker(
      context: context,
      initialTime: initialTime ?? now,
      helpText: helpText,
      confirmText: confirmText,
      cancelText: cancelText,
      builder: (ctx, child) {
        // Force 24h if desired via MediaQuery override
        if (use24HourFormat) {
          final mq = MediaQuery.of(ctx);
          return MediaQuery(
            data: mq.copyWith(alwaysUse24HourFormat: true),
            child: builder?.call(ctx, child) ?? child!,
          );
        }
        return builder?.call(ctx, child) ?? child!;
      },
    );
    return res;
  }

  /// Combined Date + Time picker. Returns a DateTime in local timezone.
  static Future<DateTime?> pickDateTime(
    BuildContext context, {
    DateTime? initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
    bool use24HourFormat = false,
  }) async {
    final initial = initialDateTime ?? DateTime.now();

    final date = await pickDate(
      context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null) return null;

    final time = await pickTime(
      context,
      initialTime: TimeOfDay.fromDateTime(initial),
      use24HourFormat: use24HourFormat,
    );
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  /// Cupertino date picker (iOS-style), wrapped in a modal bottom sheet.
  /// On non-iOS platforms, it still works—useful for a consistent UX.
  static Future<DateTime?> pickCupertinoDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
    int? minuteInterval, // e.g., 1, 5, 10, 15
    String confirmText = 'Done',
    String cancelText = 'Cancel',
    double sheetHeight = 300,
    bool useSafeArea = true,
  }) async {
    DateTime temp = initialDate ?? DateTime.now();

    return showModalBottomSheet<DateTime>(
      context: context,
      useSafeArea: useSafeArea,
      isScrollControlled: true,
      builder: (ctx) {
        return SizedBox(
          height: sheetHeight,
          child: Column(
            children: [
              _CupertinoTopBar(
                confirmText: confirmText,
                cancelText: cancelText,
                onCancel: () => Navigator.of(ctx).pop(),
                onConfirm: () => Navigator.of(ctx).pop(temp),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: mode,
                  initialDateTime: temp,
                  minimumDate: minDate,
                  maximumDate: maxDate,
                  minuteInterval: minuteInterval ?? 1,
                  onDateTimeChanged: (v) => temp = v,
                  use24hFormat: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handy presets you might show in quick filters.
  static DateTime today([DateTime? now]) {
    final n = now ?? DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime tomorrow([DateTime? now]) => today(now).add(const Duration(days: 1));

  static DateTimeRange next7Days([DateTime? now]) {
    final start = today(now);
    return DateTimeRange(start: start, end: start.add(const Duration(days: 6)));
  }

  /// Clamp a DateTimeRange within boundaries (returns null if invalid).
  static DateTimeRange? clampRange(
    DateTimeRange range, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final first = firstDate ?? kDefaultFirstDate;
    final last = lastDate ?? kDefaultLastDate;
    if (range.end.isBefore(first) || range.start.isAfter(last)) return null;
    final start = range.start.isBefore(first) ? first : range.start;
    final end = range.end.isAfter(last) ? last : range.end;
    if (end.isBefore(start)) return null;
    return DateTimeRange(start: start, end: end);
  }

  /// Convert a TimeOfDay into a DateTime by combining with a base date.
  static DateTime combine(DateTime base, TimeOfDay time) =>
      DateTime(base.year, base.month, base.day, time.hour, time.minute);

  /// Get the time of day as a string (morning, afternoon, evening, night)
  /// based on the hour of the given DateTime.
  static String getTimeOfDay(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final hour = dateTime.hour;
    
    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  /// Get the time of day as a localized string with custom labels
  static String getTimeOfDayLocalized(
    DateTime? dateTime, {
    Map<String, String>? customLabels,
    String? locale,
  }) {
    if (dateTime == null) return '';
    
    final timeOfDay = getTimeOfDay(dateTime);
    
    // Default English labels
    final defaultLabels = {
      'morning': 'Morning',
      'afternoon': 'Afternoon', 
      'evening': 'Evening',
      'night': 'Night',
    };
    
    final labels = customLabels ?? defaultLabels;
    return labels[timeOfDay] ?? timeOfDay;
  }

  /// Quickly detect iOS to choose Cupertino by default if you want.
  static bool get isCupertinoPreferred => Platform.isIOS;
}

/// Simple top bar for Cupertino bottom sheet.
class _CupertinoTopBar extends StatelessWidget {
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _CupertinoTopBar({
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        border: const Border(bottom: BorderSide(color: CupertinoColors.separator)),
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onCancel,
            child: Text(cancelText),
          ),
          const Spacer(),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onConfirm,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

/* ===========================
USAGE EXAMPLES
=============================

1) Pick a single date (Material):
final picked = await DatePickerUtils.pickDate(context);
if (picked != null) {
  final pretty = DatePickerUtils.formatDate(picked, pattern: 'dd MMM, yyyy');
}

2) Pick a range (Material):
final range = await DatePickerUtils.pickDateRange(context);
if (range != null) {
}

3) Pick time:
final t = await DatePickerUtils.pickTime(context, use24HourFormat: true);

4) Pick DateTime (date + time sequential):
final dt = await DatePickerUtils.pickDateTime(context);

5) Cupertino (iOS-style bottom sheet):
final iosDate = await DatePickerUtils.pickCupertinoDate(
  context,
  mode: CupertinoDatePickerMode.dateAndTime,
  minuteInterval: 5,
);

6) Presets:
final today = DatePickerUtils.today();
final nextWeek = DatePickerUtils.next7Days();

7) Get time of day:
final now = DateTime.now();
final timeOfDay = DatePickerUtils.getTimeOfDay(now); // 'morning', 'afternoon', etc.
final localizedTime = DatePickerUtils.getTimeOfDayLocalized(now); // 'Morning', 'Afternoon', etc.

8) Custom time of day labels:
final customLabels = {
  'morning': 'Good Morning',
  'afternoon': 'Good Afternoon',
  'evening': 'Good Evening', 
  'night': 'Good Night',
};
final greeting = DatePickerUtils.getTimeOfDayLocalized(now, customLabels: customLabels);

*/
