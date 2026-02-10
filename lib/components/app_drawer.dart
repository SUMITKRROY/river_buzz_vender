import 'package:flutter/material.dart';
import '../config/theam_data.dart';
import '../data/app_data.dart';
import '../utils/navigation_utils.dart';

/// Custom app drawer component
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.lightBlue,
                  AppTheme.white,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                  child: const Icon(
                    Icons.directions_boat,
                    color: AppTheme.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'River Buzz',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: AppTheme.pillLabelDecoration,
                  child: Text(
                    'PARTNER APP',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          ...AppData.navigationItems.map((item) {
            return ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: AppTheme.textPrimary,
              ),
              title: Text(
                item['title'] as String,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                NavigationUtils.navigateTo(
                  context,
                  item['route'] as String,
                );
                Navigator.pop(context);
              },
            );
          }),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: AppTheme.errorRed,
            ),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.errorRed,
                  ),
            ),
            onTap: () {
              // Handle logout
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
