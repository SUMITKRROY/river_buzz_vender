import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theam_data.dart';
import '../constants/app_constants.dart';
import '../data/app_data.dart';
import 'booking/new_booking_request_sheet.dart';

/// Home / Dashboard tab for River Buzz Partner App
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isReadyForBookings = true;
  Timer? _countdownTimer;
  DateTime? _nextRideTarget;
  Duration _nextRideCountdown = Duration.zero;
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _nextRideTarget = AppData.nextRideDateTime;
    _updateNextRideCountdown();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateNextRideCountdown());
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _flashAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );
    // Auto popup: "Please wear life jackets" (once per session when has upcoming ride)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppData.shouldShowLifeJacketReminder) {
        AppData.markLifeJacketReminderShown();
        _showLifeJacketReminder();
      }
    });
  }

  void _showLifeJacketReminder() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        icon: Icon(Icons.health_and_safety_rounded, color: AppTheme.primaryBlue, size: 48),
        title: const Text('Safety Reminder'),
        content: const Text(
          'Please wear life jackets. Ensure all passengers have access to life jackets before starting any ride.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _updateNextRideCountdown() {
    final target = _nextRideTarget;
    if (target == null) return;
    final diff = target.difference(DateTime.now());
    if (diff.isNegative && mounted) {
      setState(() => _nextRideCountdown = Duration.zero);
      return;
    }
    if (mounted && _nextRideCountdown != diff) {
      setState(() => _nextRideCountdown = diff);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  void _onSosPressed() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        title: Row(
          children: [
            Icon(Icons.emergency_rounded, color: AppTheme.errorRed, size: 28),
            const SizedBox(width: AppTheme.spacingS),
            const Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'Your location will be shared with emergency services. '
          'Tap "Call Emergency" to dial the emergency number.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              AppData.triggerEmergencySos();
              final uri = Uri.parse('tel:${AppData.emergencyNumber}');
              if (await canLaunchUrl(uri)) {
                launchUrl(uri);
              }
            },
            icon: const Icon(Icons.phone_rounded, size: 20),
            label: const Text('Call Emergency'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          child: CircleAvatar(
            backgroundColor: AppTheme.lightBlue,
            child: Icon(
              Icons.person_outline_rounded,
              color: AppTheme.primaryBlue,
              size: 28,
            ),
          ),
        ),
        title: const Text('River Buzz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            onPressed: _onSosPressed,
            icon: const Icon(Icons.emergency_rounded),
            tooltip: 'SOS',
            style: IconButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingM),

              // 1. New Booking Request — Flashing card on top
              if (AppData.newBookingRequest != null) ...[
                _NewBookingRequestFlashingCard(
                  data: AppData.newBookingRequest!,
                  flashAnimation: _flashAnimation,
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => const NewBookingRequestSheet(),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
              ],

              // 2. Booking Expiry Alert — Flashing
              if (AppData.bookingExpiryAlerts.isNotEmpty) ...[
                _BookingExpiryFlashingBanner(
                  alerts: AppData.bookingExpiryAlerts,
                  flashAnimation: _flashAnimation,
                ),
                const SizedBox(height: AppTheme.spacingM),
              ],

              // 3. Weather Alert Banner (Weather Auto Alert System)
              if (AppData.weatherAlert != null && AppData.weatherAlert!.isNotEmpty) ...[
                _WeatherAlertBanner(message: AppData.weatherAlert!),
                const SizedBox(height: AppTheme.spacingM),
              ],

              // 3b. Police river restriction — Force cancel banner
              if (AppData.policeRiverRestriction) ...[
                _PoliceRestrictionBanner(
                  onForceCancel: () {
                    setState(() {});
                    // In production: cancel all active/upcoming rides for this vendor
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
              ],

              // 4. Next Ride Countdown Timer
              if (_nextRideTarget != null && _nextRideCountdown.inSeconds > 0) ...[
                _NextRideCountdownCard(duration: _nextRideCountdown),
                const SizedBox(height: AppTheme.spacingM),
              ],

              // 5 & 6 & 7. Today Total Rides, Pending Payout, Today Net Earnings
              Row(
                children: [
                  Expanded(
                    child: _DashboardStatCard(
                      icon: Icons.directions_boat_rounded,
                      label: 'Today Total Rides',
                      value: '${AppData.todayTotalRides}',
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _DashboardStatCard(
                      icon: Icons.pending_actions_rounded,
                      label: 'Pending Payout',
                      value: '\$${AppData.pendingPayoutAmount.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              _DashboardStatCard(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Today Net Earnings (after ${AppData.commissionRatePercent.toInt()}% commission)',
                value: '\$${AppData.todayNetEarnings.toStringAsFixed(2)}',
                highlight: true,
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Operational Status Card
              _OperationalStatusCard(
                isOn: _isReadyForBookings,
                onChanged: (v) => setState(() => _isReadyForBookings = v),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Vendor Toolkit
              Text(
                'Vendor Toolkit',
                style: AppTheme.sectionTitleStyle,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Row(
                children: [
                  Expanded(
                    child: _ToolkitButton(
                      icon: Icons.calendar_month_rounded,
                      label: 'Schedule',
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppConstants.liveBookingSheetRoute);
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _ToolkitButton(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Wallet',
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppConstants.vendorWalletRoute);
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _ToolkitButton(
                      icon: Icons.bar_chart_rounded,
                      label: 'Reports',
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppConstants.businessReportsRoute);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _ToolkitButton(
                      icon: Icons.directions_boat_rounded,
                      label: 'Services',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _ToolkitButton(
                      icon: Icons.headset_mic_rounded,
                      label: 'Support',
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppConstants.helpSupportRoute);
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  const Expanded(child: SizedBox()),
                ],
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: AppTheme.sectionTitleStyle,
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: AppTheme.spacingXS,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              ...AppData.recentActivityItems.map((item) => _ActivityTile(
                    title: item['title'] as String,
                    detail: item['detail'] as String,
                    timeAgo: item['timeAgo'] as String,
                    iconColorKey: item['iconColor'] as String,
                    iconData: _iconForActivityType(item['type'] as String),
                  )),

              const SizedBox(height: AppTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForActivityType(String type) {
    switch (type) {
      case 'booking':
        return Icons.check_circle_rounded;
      case 'message':
        return Icons.chat_bubble_outline_rounded;
      case 'payment':
        return Icons.payments_rounded;
      default:
        return Icons.circle_rounded;
    }
  }
}

/// Flashing card for new booking request — shown on top when present.
class _NewBookingRequestFlashingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Animation<double> flashAnimation;
  final VoidCallback onTap;

  const _NewBookingRequestFlashingCard({
    required this.data,
    required this.flashAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flashAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: flashAnimation.value,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.12),
                  AppTheme.lightBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Booking Request',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${data['customerName']} • ${data['serviceName']}',
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${data['time']} • ${data['guests']} guests • ${data['receivedAt']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.primaryBlue, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Flashing banner for booking expiry (e.g. accept/decline expiring soon).
class _BookingExpiryFlashingBanner extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final Animation<double> flashAnimation;

  const _BookingExpiryFlashingBanner({
    required this.alerts,
    required this.flashAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flashAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: flashAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
        decoration: BoxDecoration(
          color: AppTheme.accentOrange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
              color: AppTheme.accentOrange.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded,
                color: AppTheme.accentOrange, size: 22),
            const SizedBox(width: AppTheme.spacingS),
            Expanded(
              child: Text(
                alerts.first['message'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Weather alert banner (non-flashing).
class _WeatherAlertBanner extends StatelessWidget {
  final String message;

  const _WeatherAlertBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_rounded, color: AppTheme.primaryBlue, size: 22),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Police / authority river restriction — force cancel rides.
class _PoliceRestrictionBanner extends StatelessWidget {
  final VoidCallback onForceCancel;

  const _PoliceRestrictionBanner({required this.onForceCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_rounded, color: AppTheme.errorRed, size: 22),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  'River restricted by authorities. All rides must be cancelled.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onForceCancel,
              icon: const Icon(Icons.cancel_rounded, size: 20),
              label: const Text('Force cancel all rides'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorRed,
                side: const BorderSide(color: AppTheme.errorRed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Next ride countdown (HH:MM:SS or MM:SS).
class _NextRideCountdownCard extends StatelessWidget {
  final Duration duration;

  const _NextRideCountdownCard({required this.duration});

  String get _formatted {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.darkBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.darkBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_rounded, color: AppTheme.darkBlue, size: 28),
          const SizedBox(width: AppTheme.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next ride in',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatted,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: [const FontFeature.tabularFigures()],
                      color: AppTheme.darkBlue,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dashboard stat card (rides, payout, net earnings).
class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _DashboardStatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.successGreen.withValues(alpha: 0.08)
            : AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: highlight
              ? AppTheme.successGreen.withValues(alpha: 0.5)
              : AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: highlight ? AppTheme.successGreen : AppTheme.primaryBlue,
            size: 24,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppTheme.successGreen : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _OperationalStatusCard extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const _OperationalStatusCard({
    required this.isOn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            'Ready for new bookings',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          SizedBox(
            height: 32,
            child: Switch.adaptive(
              value: isOn,
              onChanged: onChanged,
              activeTrackColor: AppTheme.primaryBlue,
              activeThumbColor: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolkitButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolkitButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingL,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor, width: 1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 28),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String detail;
  final String timeAgo;
  final String iconColorKey;
  final IconData iconData;

  const _ActivityTile({
    required this.title,
    required this.detail,
    required this.timeAgo,
    required this.iconColorKey,
    required this.iconData,
  });

  Color _iconBgColor() {
    switch (iconColorKey) {
      case 'green':
        return AppTheme.successGreen.withValues(alpha: 0.15);
      case 'blue':
        return AppTheme.primaryBlue.withValues(alpha: 0.15);
      case 'orange':
        return AppTheme.accentOrange.withValues(alpha: 0.15);
      default:
        return AppTheme.lightBlue;
    }
  }

  Color _iconColor() {
    switch (iconColorKey) {
      case 'green':
        return AppTheme.successGreen;
      case 'blue':
        return AppTheme.primaryBlue;
      case 'orange':
        return AppTheme.accentOrange;
      default:
        return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: _iconBgColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 22, color: _iconColor()),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: iconColorKey == 'message'
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
