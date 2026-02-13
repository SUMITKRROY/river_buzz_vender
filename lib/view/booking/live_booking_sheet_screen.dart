import 'package:flutter/material.dart';
import '../../config/theam_data.dart';
import '../../data/app_data.dart';
import 'new_booking_request_sheet.dart';

/// Live Booking Sheet: Gantt-style horizontal timeline
/// Color codes: Green → Available, Blue → Booked, Red → Expiring, Orange → Pending
class LiveBookingSheetScreen extends StatefulWidget {
  const LiveBookingSheetScreen({super.key});

  @override
  State<LiveBookingSheetScreen> createState() => _LiveBookingSheetScreenState();
}

class _LiveBookingSheetScreenState extends State<LiveBookingSheetScreen> {
  static const int _daysCount = 5;
  late DateTime _selectedDate;
  late List<DateTime> _dates;
  int _sheetNavIndex = 0;

  // Timeline config: 8 AM to 6 PM
  static const int _dayStartMinute = 8 * 60; // 480
  static const int _dayEndMinute = 18 * 60;   // 1080
  static const int _totalMinutes = _dayEndMinute - _dayStartMinute;

  @override
  void initState() {
    super.initState();
    final base = DateTime.now();
    _selectedDate = base.add(const Duration(days: 2));
    _dates = List.generate(_daysCount, (i) => base.add(Duration(days: i)));
  }

  int get _bookingCountForSelectedDay {
    final blocks = AppData.getTimelineBlocks(_selectedDate);
    return blocks.where((b) => b['status'] != 'available').length;
  }

  String _dayLabel(DateTime d) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[d.weekday - 1];
  }

  String _fullDateLabel(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String _minuteToTimeLabel(int minute) {
    final h = minute ~/ 60;
    final m = minute % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  void _onAddOfflineBooking() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddOfflineBookingSheet(),
    ).then((_) => setState(() {}));
  }

  void _onBookSlot(Map<String, dynamic> block) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NewBookingRequestSheet(),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final blocks = AppData.getTimelineBlocks(_selectedDate);
    final expiringAlerts = AppData.getTimelineExpiringAlerts(_selectedDate);
    final hasExpiring = expiringAlerts.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _sheetNavIndex == 0
              ? 'Live Booking Sheet'
              : _sheetNavIndex == 1
                  ? 'Customers'
                  : _sheetNavIndex == 2
                      ? 'Insights'
                      : 'Settings',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: _sheetNavIndex == 1
          ? _CustomersTab(
              selectedDate: _selectedDate,
              dates: _dates,
              fullDateLabel: _fullDateLabel(_selectedDate),
              dayLabel: _dayLabel,
              onDateSelected: (d) => setState(() => _selectedDate = d),
            )
          : _sheetNavIndex == 2
              ? _InsightsTab(
                  selectedDate: _selectedDate,
                  dates: _dates,
                  fullDateLabel: _fullDateLabel(_selectedDate),
                  dayLabel: _dayLabel,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                )
              : _sheetNavIndex == 3
                  ? const _SettingsTab()
                  : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking Expiry Alert Indicator
          if (hasExpiring) _ExpiryAlertBanner(alerts: expiringAlerts),

          // Date selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
            child: Row(
              children: _dates.map((d) {
                final isSelected = d.day == _selectedDate.day && d.month == _selectedDate.month;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selectedDate = d),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _dayLabel(d),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${d.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Day header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fullDateLabel(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '$_bookingCountForSelectedDay BOOKINGS',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          // Color legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
            child: Wrap(
              spacing: AppTheme.spacingM,
              runSpacing: AppTheme.spacingXS,
              children: [
                _LegendChip(color: AppTheme.successGreen, label: 'Available'),
                _LegendChip(color: AppTheme.primaryBlue, label: 'Booked'),
                _LegendChip(color: AppTheme.errorRed, label: 'Expiring'),
                _LegendChip(color: AppTheme.accentOrange, label: 'Pending'),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingS),

          // Gantt-style horizontal timeline
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: SizedBox(
                width: _totalMinutes * 1.2, // ~1.2px per minute
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time axis labels
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            child: Text(
                              'Time',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: List.generate(11, (i) {
                                final min = _dayStartMinute + (i * 60);
                                return Expanded(
                                  child: Text(
                                    _minuteToTimeLabel(min),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary,
                                      fontFeatures: [const FontFeature.tabularFigures()],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Timeline blocks row
                    _GanttTimelineRow(
                      blocks: blocks,
                      dayStartMinute: _dayStartMinute,
                      dayEndMinute: _dayEndMinute,
                      totalMinutes: _totalMinutes,
                      onBlockTap: _onBookSlot,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Manual Add Offline Booking button
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _onAddOfflineBooking,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                label: const Text('Add Offline Booking'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _SheetBottomNav(
        currentIndex: _sheetNavIndex,
        onTap: (i) => setState(() => _sheetNavIndex = i),
      ),
    );
  }
}

/// Customers tab: list of customers for selected day
class _CustomersTab extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> dates;
  final String fullDateLabel;
  final String Function(DateTime) dayLabel;
  final ValueChanged<DateTime> onDateSelected;

  const _CustomersTab({
    required this.selectedDate,
    required this.dates,
    required this.fullDateLabel,
    required this.dayLabel,
    required this.onDateSelected,
  });

  Color _statusColor(String? status) {
    switch (status) {
      case 'booked':
        return AppTheme.primaryBlue;
      case 'expiring':
        return AppTheme.errorRed;
      case 'pending':
        return AppTheme.accentOrange;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = AppData.getBookingSheetCustomers(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
          child: Row(
            children: dates.map((d) {
              final isSelected = d.day == selectedDate.day && d.month == selectedDate.month;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onDateSelected(d),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Column(
                          children: [
                            Text(
                              dayLabel(d),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              '${d.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          child: Text(
            fullDateLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: customers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 64, color: AppTheme.borderColor),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'No customers for this day',
                        style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                  itemCount: customers.length,
                  itemBuilder: (context, i) {
                    final c = customers[i];
                    final status = c['status'] as String? ?? 'booked';
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _statusColor(status).withValues(alpha: 0.2),
                            child: Text(
                              (c['name'] as String? ?? '?')[0].toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _statusColor(status),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c['name'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                if (c['serviceName'] != null)
                                  Text(
                                    c['serviceName'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                if (c['bookingId'] != null)
                                  Text(
                                    '#${c['bookingId']} • ${c['persons'] ?? 0} persons',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _statusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Insights tab: booking stats for selected day
class _InsightsTab extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> dates;
  final String fullDateLabel;
  final String Function(DateTime) dayLabel;
  final ValueChanged<DateTime> onDateSelected;

  const _InsightsTab({
    required this.selectedDate,
    required this.dates,
    required this.fullDateLabel,
    required this.dayLabel,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final insights = AppData.getBookingSheetInsights(selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date selector
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: Row(
              children: dates.map((d) {
                final isSelected = d.day == selectedDate.day && d.month == selectedDate.month;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onDateSelected(d),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dayLabel(d),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                '${d.day}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Text(
            fullDateLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  icon: Icons.event_available_rounded,
                  label: 'Total Bookings',
                  value: '${insights['totalBookings']}',
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _InsightCard(
                  icon: Icons.schedule_rounded,
                  label: 'Available Slots',
                  value: '${insights['availableSlots']}',
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  icon: Icons.pie_chart_rounded,
                  label: 'Utilization',
                  value: '${insights['utilizationPercent']}%',
                  color: AppTheme.accentOrange,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _InsightCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Est. Revenue',
                  value: '\$${(insights['revenueEstimate'] as double).toStringAsFixed(0)}',
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, color: AppTheme.primaryBlue, size: 28),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peak Hours',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        insights['peakHours'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings tab placeholder
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 48, color: AppTheme.borderColor),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Sheet Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner for expiring booking requests
class _ExpiryAlertBanner extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;

  const _ExpiryAlertBanner({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final first = alerts.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingXS),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 22),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              '${first['customerName']} — Accept/Decline expires in ${(first['expiresInSeconds'] as int? ?? 180) ~/ 60} min',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _GanttTimelineRow extends StatelessWidget {
  final List<Map<String, dynamic>> blocks;
  final int dayStartMinute;
  final int dayEndMinute;
  final int totalMinutes;
  final void Function(Map<String, dynamic>) onBlockTap;

  const _GanttTimelineRow({
    required this.blocks,
    required this.dayStartMinute,
    required this.dayEndMinute,
    required this.totalMinutes,
    required this.onBlockTap,
  });

  Color _colorForStatus(String status) {
    switch (status) {
      case 'available':
        return AppTheme.successGreen;
      case 'booked':
        return AppTheme.primaryBlue;
      case 'expiring':
        return AppTheme.errorRed;
      case 'pending':
        return AppTheme.accentOrange;
      default:
        return AppTheme.greyBackground;
    }
  }

  String _minuteToTime(int minute) {
    final h = minute ~/ 60;
    final m = minute % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row label
        SizedBox(
          width: 44,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Slots',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        // Blocks
        Expanded(
          child: SizedBox(
            height: 80,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final widthPerMinute = constraints.maxWidth / totalMinutes;
                return Stack(
                  children: blocks.map((block) {
                    final start = block['startMinute'] as int;
                    final end = block['endMinute'] as int;
                    final status = block['status'] as String;
                    final left = (start - dayStartMinute) * widthPerMinute;
                    final width = (end - start) * widthPerMinute;
                    final color = _colorForStatus(status);
                    final isAvailable = status == 'available';

                    return Positioned(
                      left: left,
                      top: 4,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isAvailable ? () => onBlockTap(block) : null,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          child: Container(
                            width: width.clamp(24.0, double.infinity) - 4,
                            margin: const EdgeInsets.only(right: 4),
                            padding: EdgeInsets.symmetric(
                              horizontal: width > 60 ? AppTheme.spacingS : 4,
                              vertical: AppTheme.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                              border: Border.all(
                                color: color.withValues(alpha: 0.8),
                                width: 1,
                              ),
                            ),
                            child: width > 70
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isAvailable)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add_rounded, size: 14, color: AppTheme.white),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Available',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Text(
                                          block['customerName'] as String? ?? '',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (!isAvailable && width > 90)
                                        Text(
                                          '${_minuteToTime(start)} - ${_minuteToTime(end)}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: AppTheme.white.withValues(alpha: 0.9),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet for adding offline (manual) booking
class _AddOfflineBookingSheet extends StatefulWidget {
  const _AddOfflineBookingSheet();

  @override
  State<_AddOfflineBookingSheet> createState() => _AddOfflineBookingSheetState();
}

class _AddOfflineBookingSheetState extends State<_AddOfflineBookingSheet> {
  final _nameController = TextEditingController();
  final _guestsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Offline booking added successfully'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text(
                'Add Offline Booking',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Record a booking made outside the app (walk-in, phone, etc.)',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'Enter customer name',
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: _guestsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Guests',
                  hintText: 'Enter number',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTheme.spacingL),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                  ),
                  child: const Text('Add Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SheetBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.description_outlined, label: 'Sheet'),
      (icon: Icons.people_outline_rounded, label: 'Customers'),
      (icon: Icons.bar_chart_rounded, label: 'Insights'),
      (icon: Icons.settings_outlined, label: 'Settings'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = currentIndex == i;
              final color = selected ? AppTheme.primaryBlue : AppTheme.textSecondary;
              return InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 24, color: color),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
