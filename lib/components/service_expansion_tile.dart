import 'package:flutter/material.dart';
import '../config/theam_data.dart';

/// Custom service expansion tile component
class ServiceExpansionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;
  final VoidCallback? onExpansionChanged;

  const ServiceExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.children,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : null,
          iconColor: AppTheme.primaryBlue,
          collapsedIconColor: AppTheme.textSecondary,
          childrenPadding: const EdgeInsets.only(
            left: AppTheme.spacingL,
            right: AppTheme.spacingL,
            bottom: AppTheme.spacingM,
          ),
          children: children,
          onExpansionChanged: (expanded) {
            onExpansionChanged?.call();
          },
        ),
      ),
    );
  }
}
