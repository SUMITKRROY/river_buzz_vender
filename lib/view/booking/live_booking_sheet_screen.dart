import 'package:flutter/material.dart';
import '../../config/theam_data.dart';
import '../../data/app_data.dart';
import 'new_booking_request_sheet.dart';

/// Live Booking Sheet: date selector + timeline of slots (available / booked)
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

  @override
  void initState() {
    super.initState();
    final base = DateTime.now();
    _selectedDate = base.add(const Duration(days: 2)); // e.g. Wed
    _dates = List.generate(_daysCount, (i) => base.add(Duration(days: i)));
  }

  int get _bookingCountForSelectedDay {
    final slots = AppData.getBookingSheetSlots(_selectedDate);
    return slots.where((s) => s['isAvailable'] == false).length;
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

  void _onBookSlot() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NewBookingRequestSheet(),
    ).then((_) {
      // Optional: after closing, could navigate to confirmation if accepted
    });
  }

  @override
  Widget build(BuildContext context) {
    final slots = AppData.getBookingSheetSlots(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Live Booking Sheet',
          style: TextStyle(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: AppTheme.spacingM),
          // Slot list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              itemCount: slots.length,
              itemBuilder: (context, i) {
                final slot = slots[i];
                return _SlotRow(
                  slot: slot,
                  onBook: _onBookSlot,
                );
              },
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

class _SlotRow extends StatelessWidget {
  final Map<String, dynamic> slot;
  final VoidCallback onBook;

  const _SlotRow({required this.slot, required this.onBook});

  IconData _serviceIcon(String key) {
    switch (key) {
      case 'kayak':
        return Icons.kayaking_rounded;
      case 'boat':
        return Icons.directions_boat_rounded;
      case 'rafting':
        return Icons.waves_rounded;
      default:
        return Icons.directions_boat_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = slot['time'] as String;
    final isAvailable = slot['isAvailable'] as bool;
    final isNow = slot['isNow'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: isAvailable
                ? _AvailableSlotCard(isNow: isNow, onBook: onBook)
                : _BookedSlotCard(slot: slot, serviceIcon: _serviceIcon),
          ),
        ],
      ),
    );
  }
}

class _AvailableSlotCard extends StatelessWidget {
  final bool isNow;
  final VoidCallback onBook;

  const _AvailableSlotCard({required this.isNow, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (isNow)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NOW',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.only(top: isNow ? 20 : 0),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppTheme.greyBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(color: AppTheme.borderColor, width: 1, strokeAlign: BorderSide.strokeAlignInside),
          ),
          child: Row(
            children: [
              Icon(Icons.add_rounded, size: 22, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Available',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onBook,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('BOOK'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookedSlotCard extends StatelessWidget {
  final Map<String, dynamic> slot;
  final IconData Function(String) serviceIcon;

  const _BookedSlotCard({required this.slot, required this.serviceIcon});

  @override
  Widget build(BuildContext context) {
    final statusTag = slot['statusTag'] as String? ?? 'CONFIRMED';
    final isWaiting = statusTag == 'WAITING';
    final tagBg = isWaiting ? AppTheme.textSecondary : AppTheme.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  slot['customerName'] as String? ?? '',
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagBg.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusTag,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Booking ID: #${slot['bookingId']} • ${slot['persons']} Persons',
            style: TextStyle(
              color: AppTheme.white.withValues(alpha: 0.95),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(serviceIcon(slot['serviceIconKey'] as String? ?? 'kayak'), size: 18, color: AppTheme.white),
              const SizedBox(width: 6),
              Text(
                slot['serviceName'] as String? ?? '',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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
