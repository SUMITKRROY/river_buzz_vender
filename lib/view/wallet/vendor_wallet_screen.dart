import 'package:flutter/material.dart';
import '../../config/theam_data.dart';
import '../../constants/app_constants.dart';
import '../../data/app_data.dart';

/// Vendor Wallet: lifetime earnings, withdrawable balance, recent transactions.
class VendorWalletScreen extends StatelessWidget {
  const VendorWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Vendor Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
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
            _TotalEarningsCard(),
            const SizedBox(height: AppTheme.spacingM),
            _WithdrawableBalanceCard(),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Recent Transactions',
              style: AppTheme.sectionTitleStyle,
            ),
            const SizedBox(height: AppTheme.spacingS),
            ...AppData.walletTransactions.map((t) => _TransactionTile(
                  title: t['title'] as String,
                  detail: t['detail'] as String,
                  amount: t['amount'] as double,
                  isCredit: t['isCredit'] as bool,
                  status: t['status'] as String,
                  iconKey: t['iconKey'] as String,
                )),
            const SizedBox(height: AppTheme.spacingS),
            TextButton(
              onPressed: () {},
              child: const Text('View Transaction History'),
            ),
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.withdrawFundsRoute);
            },
            icon: const Icon(Icons.account_balance_wallet_rounded, size: 22),
            label: const Text('Withdraw Funds'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ),
      ),
    );
  }
}

class _TotalEarningsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.darkBlue,
            AppTheme.primaryBlue.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL LIFETIME EARNINGS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.9),
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '\$${AppData.totalLifetimeEarnings.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingS,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
            ),
            child: Text(
              'Updated ${AppData.walletLastUpdated}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawableBalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WITHDRAWABLE BALANCE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: [
              Text(
                '\$${AppData.withdrawableBalance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingXS),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 20,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            'Ready for immediate payout',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Details'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String detail;
  final double amount;
  final bool isCredit;
  final String status;
  final String iconKey;

  const _TransactionTile({
    required this.title,
    required this.detail,
    required this.amount,
    required this.isCredit,
    required this.status,
    required this.iconKey,
  });

  @override
  Widget build(BuildContext context) {
    final IconData iconData =
        iconKey == 'payout' ? Icons.call_made_rounded : Icons.check_circle_rounded;
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
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Icon(iconData, size: 24, color: AppTheme.primaryBlue),
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
                  detail,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCredit ? AppTheme.successGreen : AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
