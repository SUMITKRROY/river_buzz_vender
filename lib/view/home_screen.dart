import 'package:flutter/material.dart';
import '../config/theam_data.dart';
import '../constants/app_constants.dart';
import '../data/app_data.dart';

/// Home / Dashboard tab for River Buzz Partner App
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isReadyForBookings = true;

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

              // Operational Status Card
              _OperationalStatusCard(
                isOn: _isReadyForBookings,
                onChanged: (v) => setState(() => _isReadyForBookings = v),
              ),

              const SizedBox(height: AppTheme.spacingM),

              // Summary cards row
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.attach_money_rounded,
                      label: "Today's Earnings",
                      value: '\$${AppData.todayEarnings.toStringAsFixed(2)}',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 16,
                            color: AppTheme.successGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppData.earningsTrend,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.calendar_today_rounded,
                      label: 'Active Bookings',
                      value: '${AppData.activeBookings}',
                      trailing: Text(
                        'Next: ${AppData.nextEventTime}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
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
                        Navigator.pushNamed(context, AppConstants.liveBookingSheetRoute);
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _ToolkitButton(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Wallet',
                      onTap: () {
                        Navigator.pushNamed(context, AppConstants.vendorWalletRoute);
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _ToolkitButton(
                      icon: Icons.bar_chart_rounded,
                      label: 'Reports',
                      onTap: () {
                        Navigator.pushNamed(context, AppConstants.businessReportsRoute);
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
                        Navigator.pushNamed(context, AppConstants.helpSupportRoute);
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

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (trailing != null) ...[
            const SizedBox(height: AppTheme.spacingXS),
            trailing!,
          ],
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
