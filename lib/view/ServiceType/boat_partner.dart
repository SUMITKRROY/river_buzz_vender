import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theam_data.dart';
import '../../constants/app_constants.dart';
import 'vendor_form_components.dart';

/// Boat Partner registration form — all boat service fields
class BoatPartnerForm extends StatefulWidget {
  const BoatPartnerForm({super.key});

  @override
  State<BoatPartnerForm> createState() => BoatPartnerFormState();
}

class BoatPartnerFormState extends State<BoatPartnerForm> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _maxCapacityController = TextEditingController(text: '12');
  final _basePriceController = TextEditingController(text: '150');
  final _gstController = TextEditingController();
  final _lifeJacketCountController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final Set<String> _selectedBoatTypes = {};
  String? _selectedBoatCategory;
  int _pricingModelIndex = 0;
  final List<String> _boatPhotoPaths = [];
  final Set<String> _selectedGhats = {};
  TimeOfDay _serviceStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _serviceEndTime = const TimeOfDay(hour: 18, minute: 0);
  String? _insuranceFilePath;
  String? _boatRegistrationFilePath;

  @override
  void dispose() {
    _licenseController.dispose();
    _maxCapacityController.dispose();
    _basePriceController.dispose();
    _gstController.dispose();
    _lifeJacketCountController.dispose();
    super.dispose();
  }

  /// Returns true if form is valid. Shows SnackBar on failure.
  bool validate(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    if (_selectedBoatTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one Boat Type')),
      );
      return false;
    }
    if (_selectedGhats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one Operating Ghat')),
      );
      return false;
    }
    if (_boatPhotoPaths.length < AppConstants.minBoatPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least ${AppConstants.minBoatPhotos} boat photos')),
      );
      return false;
    }
    return true;
  }

  String getLicenseNumber() => _licenseController.text.trim();

  String _formatTime(TimeOfDay t) {
    final h = t.hour;
    final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final m = t.minute.toString().padLeft(2, '0');
    final am = h < 12 ? 'AM' : 'PM';
    return '$displayHour:$m $am';
  }

  Future<void> _showPhotosSourceSheet() async {
    if (!mounted) return;
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add boat photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              ListTile(leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryBlue), title: const Text('Gallery'), subtitle: const Text('Pick from photo library'), onTap: () => Navigator.pop(ctx, 'gallery')),
              ListTile(leading: const Icon(Icons.folder_outlined, color: AppTheme.primaryBlue), title: const Text('Files'), subtitle: const Text('Pick image files from device'), onTap: () => Navigator.pop(ctx, 'files')),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    if (source == 'gallery') {
      await _pickFromGallery();
    } else {
      await _pickFromFiles();
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final images = await _imagePicker.pickMultiImage(imageQuality: 85, limit: 10 - _boatPhotoPaths.length);
      if (!mounted) return;
      final paths = images.map((x) => x.path).where((p) => p.isNotEmpty).toList();
      setState(() => _boatPhotoPaths.addAll(paths));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open gallery: $e')));
    }
  }

  Future<void> _pickFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
      if (!mounted) return;
      final paths = result?.paths.whereType<String>().where((p) => p.isNotEmpty).toList() ?? [];
      setState(() => _boatPhotoPaths.addAll(paths));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not pick files: $e')));
    }
  }

  Future<void> _showSingleImageSheet(void Function(String? path) onPicked) async {
    if (!mounted) return;
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          decoration: const BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Choose image from', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              ListTile(leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryBlue), title: const Text('Gallery'), onTap: () => Navigator.pop(ctx, 'gallery')),
              ListTile(leading: const Icon(Icons.folder_outlined, color: AppTheme.primaryBlue), title: const Text('Files'), onTap: () => Navigator.pop(ctx, 'files')),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    if (source == 'gallery') {
      final x = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (mounted) onPicked(x?.path);
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
      if (mounted) onPicked(result?.files.singleOrNull?.path);
    }
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary));

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Boat Service — Operational Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          _label('Boat Type'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.boatTypes.map((type) {
              final sel = _selectedBoatTypes.contains(type);
              return FilterChip(label: Text(type), selected: sel, onSelected: (v) => setState(() { if (v == true) { _selectedBoatTypes.add(type); } else { _selectedBoatTypes.remove(type); } }), selectedColor: AppTheme.lightBlue, checkmarkColor: AppTheme.darkBlue);
            }).toList(),
          ),
          const SizedBox(height: 16),
          _label('Boat Category'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedBoatCategory,
            decoration: const InputDecoration(hintText: 'Select category', hintStyle: TextStyle(color: AppTheme.textSecondary)),
            items: AppConstants.boatCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedBoatCategory = v),
            validator: (v) => (v == null || v.isEmpty) ? 'Please select boat category' : null,
          ),
          const SizedBox(height: 16),
          _label('GST Number (Optional)'),
          const SizedBox(height: 6),
          TextFormField(controller: _gstController, decoration: const InputDecoration(hintText: 'e.g. 22AAAAA0000A1Z5', hintStyle: TextStyle(color: AppTheme.textSecondary))),
          const SizedBox(height: 16),
          _label('Boat Registration Certificate'),
          const SizedBox(height: 6),
          UploadPlaceholder(
            label: _boatRegistrationFilePath != null ? 'Certificate selected' : 'Upload certificate',
            icon: Icons.description_outlined,
            filePath: _boatRegistrationFilePath,
            onTap: () => _showSingleImageSheet((path) => setState(() => _boatRegistrationFilePath = path)),
          ),
          const SizedBox(height: 16),
          _label('Insurance Upload (Optional)'),
          const SizedBox(height: 6),
          UploadPlaceholder(
            label: _insuranceFilePath != null ? 'Insurance document selected' : 'Upload insurance document',
            icon: Icons.security_outlined,
            filePath: _insuranceFilePath,
            onTap: () => _showSingleImageSheet((path) => setState(() => _insuranceFilePath = path)),
          ),
          const SizedBox(height: 16),
          _label('Life Jacket Count'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _lifeJacketCountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'e.g. 10', hintStyle: TextStyle(color: AppTheme.textSecondary)),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final n = int.tryParse(v);
              if (n == null || n < 0) return 'Enter a valid count';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _label('Boat Photos (Minimum ${AppConstants.minBoatPhotos} images)'),
          const SizedBox(height: 6),
          BoatPhotosSection(photoPaths: _boatPhotoPaths, onAdd: _showPhotosSourceSheet, onRemove: (i) => setState(() => _boatPhotoPaths.removeAt(i)), minRequired: AppConstants.minBoatPhotos),
          const SizedBox(height: 16),
          _label('Select Operating Ghats'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.operatingGhatsList.map((ghat) {
              final sel = _selectedGhats.contains(ghat);
              return FilterChip(label: Text(ghat), selected: sel, onSelected: (v) => setState(() { if (v == true) { _selectedGhats.add(ghat); } else { _selectedGhats.remove(ghat); } }), selectedColor: AppTheme.lightBlue, checkmarkColor: AppTheme.darkBlue);
            }).toList(),
          ),
          const SizedBox(height: 16),
          _label('Service Available Time Range'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () async { final p = await showTimePicker(context: context, initialTime: _serviceStartTime); if (p != null) setState(() => _serviceStartTime = p); }, icon: const Icon(Icons.access_time, size: 18), label: Text(_formatTime(_serviceStartTime), style: const TextStyle(fontSize: 14)), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textPrimary, side: const BorderSide(color: AppTheme.borderColor)))),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('to', style: TextStyle(color: AppTheme.textSecondary))),
              Expanded(child: OutlinedButton.icon(onPressed: () async { final p = await showTimePicker(context: context, initialTime: _serviceEndTime); if (p != null) setState(() => _serviceEndTime = p); }, icon: const Icon(Icons.access_time, size: 18), label: Text(_formatTime(_serviceEndTime), style: const TextStyle(fontSize: 14)), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textPrimary, side: const BorderSide(color: AppTheme.borderColor)))),
            ],
          ),
          const SizedBox(height: 16),
          _label('Pricing Model'),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppTheme.greyBackground, borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
            child: Row(
              children: [
                Expanded(child: ServiceTab(label: AppConstants.pricingModels[0], isSelected: _pricingModelIndex == 0, onTap: () => setState(() => _pricingModelIndex = 0))),
                Expanded(child: ServiceTab(label: AppConstants.pricingModels[1], isSelected: _pricingModelIndex == 1, onTap: () => setState(() => _pricingModelIndex = 1))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _label('Business License Number'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _licenseController,
            decoration: const InputDecoration(hintText: 'e.g. RB-9928-XY', hintStyle: TextStyle(color: AppTheme.textSecondary)),
            validator: (v) => (v == null || v.trim().length < 5) ? 'Enter a valid license number' : null,
          ),
          const SizedBox(height: 16),
          _label('Max Capacity'),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _maxCapacityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(hintText: '12'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = int.tryParse(v);
                    if (n == null || n <= 0 || n > 1000) return 'Enter 1–1000';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: AppTheme.greyBackground, borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), border: Border.all(color: AppTheme.borderColor)), alignment: Alignment.center, child: Text('PERSONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary))),
            ],
          ),
          const SizedBox(height: 16),
          _label('Base Price'),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 52, width: 48, decoration: BoxDecoration(color: AppTheme.greyBackground, borderRadius: BorderRadius.horizontal(left: Radius.circular(AppTheme.borderRadiusMedium)), border: Border.all(color: AppTheme.borderColor)), alignment: Alignment.center, child: const Text('\$', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
              Expanded(
                child: TextFormField(
                  controller: _basePriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: '150', contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.zero), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppTheme.borderColor, width: 1)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2))),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n < 0) return 'Enter valid price';
                    return null;
                  },
                ),
              ),
              Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: AppTheme.greyBackground, borderRadius: BorderRadius.horizontal(right: Radius.circular(AppTheme.borderRadiusMedium)), border: Border.all(color: AppTheme.borderColor)), alignment: Alignment.center, child: Text(_pricingModelIndex == 0 ? '/HR' : '/PERSON', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary))),
            ],
          ),
        ],
      ),
    );
  }
}
