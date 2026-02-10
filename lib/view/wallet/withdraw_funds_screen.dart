import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theam_data.dart';
import '../../data/app_data.dart';

/// Withdraw Funds: amount input, bank selection, quick amounts, confirm transfer.
class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  final _amountController = TextEditingController(text: '0.00');
  static const List<double> _quickAmounts = [500, 1000, 5000];
  int _selectedQuickIndex = -1; // -1 = none, 3 = MAX

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _currentAmount {
    final v = double.tryParse(_amountController.text.trim());
    return v ?? 0;
  }

  void _selectQuick(int index) {
    setState(() {
      _selectedQuickIndex = index;
      if (index == 3) {
        _amountController.text = AppData.withdrawableBalance.toStringAsFixed(2);
      } else {
        _amountController.text = _quickAmounts[index].toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Withdraw Funds'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingM),
            _AvailableCard(),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Transfer To',
              style: AppTheme.sectionTitleStyle,
            ),
            const SizedBox(height: AppTheme.spacingS),
            _BankCard(),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Amount to Withdraw',
              style: AppTheme.sectionTitleStyle,
            ),
            const SizedBox(height: AppTheme.spacingS),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
              ),
              onChanged: (_) => setState(() => _selectedQuickIndex = -1),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                for (int i = 0; i < _quickAmounts.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingS),
                    child: _QuickAmountChip(
                      label: '\$${_quickAmounts[i].toStringAsFixed(0)}',
                      isSelected: _selectedQuickIndex == i,
                      onTap: () => _selectQuick(i),
                    ),
                  ),
                _QuickAmountChip(
                  label: 'MAX',
                  isSelected: _selectedQuickIndex == 3,
                  onTap: () => _selectQuick(3),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(
                  color: AppTheme.accentOrange.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 22,
                    color: AppTheme.accentOrange,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      AppData.withdrawTransferNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: ElevatedButton.icon(
                onPressed: _currentAmount > 0 && _currentAmount <= AppData.withdrawableBalance
                    ? () {
                        // Confirm transfer
                        Navigator.maybePop(context);
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text('Confirm Transfer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'River Buzz Secure Payment Gateway',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingS),
          ],
        ),
      ),
    );
  }
}

class _AvailableCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available for Withdrawal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            '\$${AppData.withdrawableBalance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            child: Icon(
              Icons.account_balance_rounded,
              size: 28,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppData.withdrawBankName} - ${AppData.withdrawAccountMask}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppData.withdrawAccountType,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.primaryBlue : AppTheme.greyBackground,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: isSelected
                ? null
                : Border.all(color: AppTheme.borderColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.white : AppTheme.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
