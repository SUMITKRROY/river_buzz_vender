import 'package:flutter/material.dart';
import '../config/theam_data.dart';
import '../constants/app_constants.dart';
import '../data/app_data.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final company = AppData.currentCompanyInfo ?? AppData.getSampleCompanyInfo();
    final vendorName = 'Captain John Smith';
    final companyName = 'Blue River Tours';
    final isVerified = company.status == AppConstants.statusActive;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        children: [
          const SizedBox(height: AppTheme.spacingM),
          // Profile avatar and name
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.lightBlue,
                      child: Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.spacingS),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppTheme.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  vendorName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      companyName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: AppTheme.spacingXS),
                      Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: AppTheme.primaryBlue,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusPill),
                    ),
                    child: Text(
                      'Verified Vendor',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),

          // BUSINESS DETAILS
          _SectionHeader(title: 'BUSINESS DETAILS'),
          _ProfileTile(
            icon: Icons.directions_boat_rounded,
            iconColor: AppTheme.primaryBlue,
            title: 'Service Type',
            value: company.serviceType == 'Boat Service' ? 'Boat' : company.serviceType,
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.groups_rounded,
            iconColor: AppTheme.primaryBlue,
            title: 'Capacity',
            value: '${company.maxCapacity} Persons',
            onTap: () {},
          ),
          const SizedBox(height: AppTheme.spacingL),

          // ACCOUNT SETTINGS
          _SectionHeader(title: 'ACCOUNT SETTINGS'),
          _ProfileTile(
            icon: Icons.settings_rounded,
            title: 'General Settings',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.translate_rounded,
            title: 'Language Preferences',
            value: 'English',
            onTap: () {},
          ),
          const SizedBox(height: AppTheme.spacingL),

          // HELP & SUPPORT
          _SectionHeader(title: 'HELP & SUPPORT'),
          _ProfileTile(
            icon: Icons.help_outline_rounded,
            title: 'Support Center',
            onTap: () => Navigator.pushNamed(context, AppConstants.helpSupportRoute),
          ),
          _ProfileTile(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            titleColor: AppTheme.errorRed,
            iconColor: AppTheme.errorRed,
            onTap: () {},
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Wallet & Reports (existing functionality)
          _SectionHeader(title: 'EARNINGS & REPORTS'),
          _ProfileTile(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppTheme.primaryBlue,
            title: 'Vendor Wallet',
            subtitle: 'Earnings, balance & withdraw',
            onTap: () =>
                Navigator.pushNamed(context, AppConstants.vendorWalletRoute),
          ),
          _ProfileTile(
            icon: Icons.bar_chart_rounded,
            iconColor: AppTheme.primaryBlue,
            title: 'Business Reports',
            subtitle: 'Revenue trends & KPIs',
            onTap: () =>
                Navigator.pushNamed(context, AppConstants.businessReportsRoute),
          ),
          const SizedBox(height: AppTheme.spacingXL),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingXS,
        bottom: AppTheme.spacingS,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.value,
    this.subtitle,
    this.titleColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppTheme.textPrimary;
    final effectiveTitleColor = titleColor ?? AppTheme.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingS,
            horizontal: AppTheme.spacingXS,
          ),
          child: Row(
            children: [
              Icon(icon, color: effectiveIconColor, size: 24),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: effectiveTitleColor,
                              ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              const SizedBox(width: AppTheme.spacingS),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
