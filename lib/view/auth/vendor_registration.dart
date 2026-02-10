import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theam_data.dart';
import '../../constants/app_constants.dart';
import '../../utils/navigation_utils.dart';

/// Step 2 of 3: Business Details & Verification (Boat Service tab)
class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  static const int _currentStep = 2;
  static const int _totalSteps = 3;

  // Service type: 0 = Boat Service, 1 = Hotel/Stay (only Boat implemented for now)
  int _selectedServiceIndex = 0;

  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _maxCapacityController = TextEditingController(text: '12');
  final _basePriceController = TextEditingController(text: '150');
  final _accountHolderController = TextEditingController();
  final _ibanController = TextEditingController();
  String? _selectedBank;

  static const List<String> _bankOptions = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Other',
  ];

  @override
  void dispose() {
    _licenseController.dispose();
    _maxCapacityController.dispose();
    _basePriceController.dispose();
    _accountHolderController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  void _submitForVerification() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Call register API, get applicationId from response
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final submittedDate = '${months[now.month - 1]} ${now.day}';
    NavigationUtils.pushReplacementNamed(
      context,
      AppConstants.approvalStatusRoute,
      arguments: {
        'applicationId': _licenseController.text.trim().isNotEmpty
            ? _licenseController.text.trim().toUpperCase()
            : 'RB-99283',
        'submittedDate': submittedDate,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => NavigationUtils.pop(context),
        ),
        title: const Text(
          'Vendor Registration',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                // Step indicator
                Text(
                  'Step $_currentStep of $_totalSteps',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
                  child: LinearProgressIndicator(
                    value: _currentStep / _totalSteps,
                    minHeight: 6,
                    backgroundColor: AppTheme.greyBackground,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Business Details & Verification',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Join River Buzz',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Register your business to start reaching thousands of river travelers.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 24),
                // Service type tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.greyBackground,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ServiceTab(
                          label: AppConstants.boatService,
                          isSelected: _selectedServiceIndex == 0,
                          onTap: () =>
                              setState(() => _selectedServiceIndex = 0),
                        ),
                      ),
                      Expanded(
                        child: _ServiceTab(
                          label: AppConstants.hotelStay,
                          isSelected: _selectedServiceIndex == 1,
                          onTap: () =>
                              setState(() => _selectedServiceIndex = 1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Operational Details (Boat Service content)
                if (_selectedServiceIndex == 0) ...[
                  const Text(
                    'Operational Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Business License Number'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _licenseController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. RB-9928-XY',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 5) {
                        return 'Enter a valid license number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Max Capacity'),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _maxCapacityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            hintText: '12',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Required';
                            }
                            final n = int.tryParse(v);
                            if (n == null || n <= 0 || n > 1000) {
                              return 'Enter 1–1000';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        alignment: Alignment.center,
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.greyBackground,
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Text(
                          'PERSONS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Base Price'),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 52,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.greyBackground,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(AppTheme.borderRadiusMedium),
                          ),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
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
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            hintText: '150',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                color: AppTheme.borderColor,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                color: AppTheme.primaryBlue,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Required';
                            }
                            final n = double.tryParse(v);
                            if (n == null || n < 0) {
                              return 'Enter valid price';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.greyBackground,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(AppTheme.borderRadiusMedium),
                          ),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Text(
                          '/HR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
                // Bank Account Details
                const Text(
                  'Bank Account Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Required for payouts and identity verification.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('Account Holder Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _accountHolderController,
                  decoration: const InputDecoration(
                    hintText: 'Full legal name',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('IBAN / Account Number'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _ibanController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter bank account number',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Bank Name'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedBank,
                  decoration: const InputDecoration(
                    hintText: 'Select your bank',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  items: _bankOptions
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBank = v),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please select your bank';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  "By submitting, you agree to River Buzz's Vendor Terms and verify that the information provided is accurate.",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitForVerification,
                    icon: const Icon(Icons.check, size: 20, color: AppTheme.white),
                    label: const Text('Submit for Verification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _ServiceTab extends StatelessWidget {
  const _ServiceTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightBlue : AppTheme.greyBackground,
          borderRadius:
              BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.darkBlue : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
