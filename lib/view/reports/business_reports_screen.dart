import 'package:flutter/material.dart';
import '../../config/theam_data.dart';
import '../../data/app_data.dart';

/// Business Reports: period toggle, revenue trends chart, KPIs, recent activity.
class BusinessReportsScreen extends StatefulWidget {
  const BusinessReportsScreen({super.key});

  @override
  State<BusinessReportsScreen> createState() => _BusinessReportsScreenState();
}

class _BusinessReportsScreenState extends State<BusinessReportsScreen> {
  bool _isWeekly = true;

  List<double> get _revenueData =>
      _isWeekly ? AppData.weeklyRevenueData : AppData.monthlyRevenueData;
  String get _dateRange =>
      _isWeekly ? AppData.weeklyDateRange : AppData.monthlyDateRange;
  double get _totalRevenue =>
      _isWeekly ? AppData.weeklyTotalRevenue : AppData.monthlyTotalRevenue;
  String get _revenueChange =>
      _isWeekly ? AppData.weeklyRevenueChange : AppData.monthlyRevenueChange;

  static const List<String> _weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const List<String> _monthLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Business Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingM),
            _PeriodToggle(
              isWeekly: _isWeekly,
              onChanged: (v) => setState(() => _isWeekly = v),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Revenue Trends',
              style: AppTheme.sectionTitleStyle,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              _dateRange,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacingS),
            _RevenueSummaryCard(
              total: _totalRevenue,
              change: _revenueChange,
            ),
            const SizedBox(height: AppTheme.spacingM),
            SizedBox(
              height: 180,
              child: _RevenueLineChart(
                data: _revenueData,
                labels: _isWeekly ? _weekDays : _monthLabels,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Key Performance Indicators',
              style: AppTheme.sectionTitleStyle,
            ),
            const SizedBox(height: AppTheme.spacingS),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppTheme.spacingS,
              crossAxisSpacing: AppTheme.spacingS,
              childAspectRatio: 1.35,
              children: [
                _KPICard(
                  icon: Icons.directions_boat_rounded,
                  iconColor: AppTheme.primaryBlue,
                  label: 'TOTAL RIDES',
                  value: '${AppData.reportTotalRides}',
                  change: AppData.reportRidesChange,
                ),
                _KPICard(
                  icon: Icons.star_rounded,
                  iconColor: AppTheme.accentOrange,
                  label: 'AVG. RATING',
                  value: '${AppData.reportAvgRating} /5.0',
                ),
                _KPICard(
                  icon: Icons.schedule_rounded,
                  iconColor: Colors.purple,
                  label: 'PEAK HOURS',
                  value: AppData.reportPeakHours,
                ),
                _KPICard(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppTheme.successGreen,
                  label: 'NET PAYOUT',
                  value: '\$${AppData.reportNetPayout.toStringAsFixed(0)}',
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
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
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            ...AppData.reportRecentActivity.map((a) => _ReportActivityTile(
                  title: a['title'] as String,
                  timeAgo: a['timeAgo'] as String,
                  type: a['type'] as String,
                  amount: a['amount'] as double?,
                  isStar: a['isStar'] as bool? ?? false,
                )),
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final bool isWeekly;
  final ValueChanged<bool> onChanged;

  const _PeriodToggle({required this.isWeekly, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXS),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(true),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: isWeekly ? AppTheme.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    boxShadow: isWeekly
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'Weekly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isWeekly ? AppTheme.textPrimary : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(false),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: !isWeekly ? AppTheme.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    boxShadow: !isWeekly
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'Monthly',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: !isWeekly ? AppTheme.textPrimary : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueSummaryCard extends StatelessWidget {
  final double total;
  final String change;

  const _RevenueSummaryCard({required this.total, required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Revenue',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Row(
            children: [
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up_rounded, size: 18, color: AppTheme.successGreen),
                  const SizedBox(width: 2),
                  Text(
                    change,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueLineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const _RevenueLineChart({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LineChartPainter(
            data: data,
            lineColor: AppTheme.primaryBlue,
            fillColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.spacingS),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: labels
                      .map((l) => SizedBox(
                            width: (constraints.maxWidth - 32) / labels.length,
                            child: Text(
                              l,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxY = data.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    final minY = data.reduce((a, b) => a < b ? a : b);
    final range = maxY - minY;
    final stepX = size.width / (data.length + 1);
    const paddingBottom = 28.0;
    final chartHeight = size.height - paddingBottom;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = stepX * (i + 1);
      final y = range > 0
          ? paddingBottom + chartHeight - ((data[i] - minY) / range * chartHeight)
          : size.height * 0.5;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(stepX * data.length, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Dot on peak (e.g. index 3 for THU in weekly)
    final peakIdx = data.length >= 4 ? 3 : data.length ~/ 2;
    final px = stepX * (peakIdx + 1);
    final py = range > 0
        ? paddingBottom +
            chartHeight -
            ((data[peakIdx] - minY) / range * chartHeight)
        : size.height * 0.5;
    canvas.drawCircle(Offset(px, py), 5, Paint()..color = lineColor);
    canvas.drawCircle(Offset(px, py), 2.5, Paint()..color = AppTheme.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _KPICard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? change;

  const _KPICard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: 4),
                Text(
                  change!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportActivityTile extends StatelessWidget {
  final String title;
  final String timeAgo;
  final String type;
  final double? amount;
  final bool isStar;

  const _ReportActivityTile({
    required this.title,
    required this.timeAgo,
    required this.type,
    this.amount,
    this.isStar = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = type == 'payment'
        ? Icons.payments_outlined
        : Icons.rate_review_outlined;
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
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.greyBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 22, color: AppTheme.textSecondary),
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
                Text(
                  timeAgo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (amount != null)
            Text(
              '+ \$${amount!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.successGreen,
                fontSize: 14,
              ),
            )
          else if (isStar)
            Icon(Icons.star_rounded, size: 22, color: AppTheme.accentOrange),
        ],
      ),
    );
  }
}
