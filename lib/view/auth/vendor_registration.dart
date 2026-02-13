import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theam_data.dart';
import '../../constants/app_constants.dart';
import '../../utils/navigation_utils.dart';
import '../serviceType/boat_partner.dart';
import '../serviceType/rafting_partner.dart';

/// Step 2 of 3: Business Details & Verification
/// Calls BoatPartnerForm and RaftingPartnerForm from serviceType folder
class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen>
    with SingleTickerProviderStateMixin {
  static const int _currentStep = 2;
  static const int _totalSteps = 3;

  int _selectedServiceIndex = 0;

  final _bankFormKeyBoat = GlobalKey<FormState>();
  final _bankFormKeyRaft = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _ibanController = TextEditingController();
  String? _selectedBank;

  final _boatPartnerKey = GlobalKey<BoatPartnerFormState>();
  final _raftPartnerKey = GlobalKey<RaftingPartnerFormState>();

  static const List<String> _bankOptions = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Other',
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() => _selectedServiceIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accountHolderController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  void _submitForVerification() {
    // Validate active service partner form
    if (_selectedServiceIndex == 0) {
      if (!(_boatPartnerKey.currentState?.validate(context) ?? false)) return;
    } else {
      if (!(_raftPartnerKey.currentState?.validate(context) ?? false)) return;
    }
    // Validate bank form (same form appears in both tabs, use active tab's key)
    final bankKey = _selectedServiceIndex == 0 ? _bankFormKeyBoat : _bankFormKeyRaft;
    if (!(bankKey.currentState?.validate() ?? false)) return;

    final licenseNumber = _selectedServiceIndex == 0
        ? _boatPartnerKey.currentState?.getLicenseNumber() ?? ''
        : _raftPartnerKey.currentState?.getLicenseNumber() ?? '';

    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final submittedDate = '${months[now.month - 1]} ${now.day}';
    NavigationUtils.pushReplacementNamed(
      context,
      AppConstants.approvalStatusRoute,
      arguments: {
        'applicationId': licenseNumber.isNotEmpty ? licenseNumber.toUpperCase() : 'RB-99283',
        'submittedDate': submittedDate,
      },
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFFFFFFFF),
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: SafeArea(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
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
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.greyBackground,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (i) => setState(() => _selectedServiceIndex = i),
                      padding: EdgeInsets.zero,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: EdgeInsets.zero,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      labelColor: AppTheme.darkBlue,
                      unselectedLabelColor: AppTheme.textSecondary,
                      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      tabs: [
                        Tab(text: AppConstants.boatService),
                        Tab(text: AppConstants.rafting),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BoatPartnerForm(key: _boatPartnerKey),
                        const SizedBox(height: 24),
                        _buildBankFormSection(_bankFormKeyBoat),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RaftingPartnerForm(key: _raftPartnerKey),
                        const SizedBox(height: 24),
                        _buildBankFormSection(_bankFormKeyRaft),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildBankFormSection(GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              if (v == null || v.trim().isEmpty) return 'Required';
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
              if (v == null || v.trim().isEmpty) return 'Required';
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
              if (v == null || v.isEmpty) return 'Please select your bank';
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
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
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
    );
  }
}
