import 'package:flutter/material.dart';
import '../config/theam_data.dart';

/// Custom navigation tile component
class NavigationTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? trailing;

  const NavigationTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.isSelected = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
      ),
      trailing: trailing ??
          (isSelected
              ? const Icon(
                  Icons.chevron_right,
                  color: AppTheme.primaryBlue,
                )
              : null),
      selected: isSelected,
      selectedTileColor: AppTheme.lightBlue.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      onTap: onTap,
    );
  }
}
