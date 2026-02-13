import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theam_data.dart';
import '../../constants/app_constants.dart';
import '../../data/app_data.dart';
import '../ServiceType/vendor_form_components.dart';

/// Screen to edit vendor pricing (base price and pricing model)
class EditPricingScreen extends StatefulWidget {
  const EditPricingScreen({super.key});

  @override
  State<EditPricingScreen> createState() => _EditPricingScreenState();
}

class _EditPricingScreenState extends State<EditPricingScreen> {
  late final TextEditingController _basePriceController;
  late int _pricingModelIndex;
  late List<String> _pricingModels;
  late String _unitSuffix;

  @override
  void initState() {
    super.initState();
    final company = AppData.currentCompanyInfo ?? AppData.getSampleCompanyInfo();
    final isBoat = company.serviceType == AppConstants.boatService;
    _pricingModels = isBoat ? AppConstants.pricingModels : AppConstants.raftPricingModels;
    _unitSuffix = isBoat ? '/HR' : '/TRIP';
    final currentModel = company.pricingModel ?? _pricingModels[0];
    _pricingModelIndex = _pricingModels.indexOf(currentModel);
    if (_pricingModelIndex < 0) _pricingModelIndex = 0;
    if (!isBoat && _pricingModelIndex == 1) _unitSuffix = '/PERSON';
    if (isBoat && _pricingModelIndex == 1) _unitSuffix = '/PERSON';
    _basePriceController = TextEditingController(text: company.basePrice.toStringAsFixed(0));
  }

  void _updateUnitSuffix() {
    final isBoat = (AppData.currentCompanyInfo ?? AppData.getSampleCompanyInfo()).serviceType == AppConstants.boatService;
    setState(() {
      if (isBoat) {
        _unitSuffix = _pricingModelIndex == 0 ? '/HR' : '/PERSON';
      } else {
        _unitSuffix = _pricingModelIndex == 0 ? '/TRIP' : '/PERSON';
      }
    });
  }

  @override
  void dispose() {
    _basePriceController.dispose();
    super.dispose();
  }

  void _save() {
    final price = double.tryParse(_basePriceController.text.trim());
    if (price == null || price < AppConstants.minBasePrice || price > AppConstants.maxBasePrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid base price')),
      );
      return;
    }
    final company = AppData.currentCompanyInfo ?? AppData.getSampleCompanyInfo();
    final updated = company.copyWith(
      basePrice: price,
      pricingModel: _pricingModels[_pricingModelIndex],
    );
    AppData.currentCompanyInfo = updated;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pricing updated')),
    );
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final company = AppData.currentCompanyInfo ?? AppData.getSampleCompanyInfo();
    final isBoat = company.serviceType == AppConstants.boatService;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Edit Pricing'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Pricing model',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.greyBackground,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Row(
                children: [
                  for (int i = 0; i < _pricingModels.length; i++)
                    Expanded(
                      child: ServiceTab(
                        label: _pricingModels[i],
                        isSelected: _pricingModelIndex == i,
                        onTap: () {
                          setState(() {
                            _pricingModelIndex = i;
                            _updateUnitSuffix();
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              'Base price',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.greyBackground,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppTheme.borderRadiusMedium),
                    ),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _basePriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      hintText: '150',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.greyBackground,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(AppTheme.borderRadiusMedium),
                    ),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _unitSuffix,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (!isBoat) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Rafting: Per Trip = fixed price per trip; Per Person = price per head.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
