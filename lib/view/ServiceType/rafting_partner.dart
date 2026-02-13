import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theam_data.dart';
import '../../constants/app_constants.dart';
import 'vendor_form_components.dart';

/// Rafting Partner registration form — all rafting service fields
class RaftingPartnerForm extends StatefulWidget {
  const RaftingPartnerForm({super.key});

  @override
  State<RaftingPartnerForm> createState() => RaftingPartnerFormState();
}

class RaftingPartnerFormState extends State<RaftingPartnerForm> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _basePriceController = TextEditingController(text: '150');
  final _gstController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final Set<String> _selectedRaftTypes = {};
  String? _selectedRaftCategory;
  int _pricingModelIndex = 0;
  final List<String> _raftPhotoPaths = [];
  final Set<String> _selectedRivers = {};
  final Set<String> _selectedDurations = {};
  TimeOfDay _raftStartTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _raftEndTime = const TimeOfDay(hour: 17, minute: 0);
  String? _raftInsuranceFilePath;
  final TextEditingController _raftMaxCapacityController = TextEditingController(text: '6');
  final TextEditingController _raftLifeJacketController = TextEditingController();
  final TextEditingController _raftHelmetController = TextEditingController();

  @override
  void dispose() {
    _licenseController.dispose();
    _basePriceController.dispose();
    _gstController.dispose();
    _raftMaxCapacityController.dispose();
    _raftLifeJacketController.dispose();
    _raftHelmetController.dispose();
    super.dispose();
  }

  /// Returns true if form is valid. Shows SnackBar on failure.
  bool validate(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    if (_selectedRaftTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one Raft Type')),
      );
      return false;
    }
    if (_selectedRivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one Operating River')),
      );
      return false;
    }
    if (_raftPhotoPaths.length < AppConstants.minRaftPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least ${AppConstants.minRaftPhotos} raft photos')),
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
              const Text('Add raft photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
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
      final images = await _imagePicker.pickMultiImage(imageQuality: 85, limit: 10 - _raftPhotoPaths.length);
      if (!mounted) return;
      final paths = images.map((x) => x.path).where((p) => p.isNotEmpty).toList();
      setState(() => _raftPhotoPaths.addAll(paths));
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
      setState(() => _raftPhotoPaths.addAll(paths));
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
          const Text('Rafting — Fill your rafting service details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          _label('Raft Type'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.raftTypes.map((type) {
              final sel = _selectedRaftTypes.contains(type);
              return FilterChip(label: Text(type), selected: sel, onSelected: (v) => setState(() { if (v == true) { _selectedRaftTypes.add(type); } else { _selectedRaftTypes.remove(type); } }), selectedColor: AppTheme.lightBlue, checkmarkColor: AppTheme.darkBlue);
            }).toList(),
          ),
          const SizedBox(height: 16),
          _label('Raft Category'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedRaftCategory,
            decoration: const InputDecoration(hintText: 'Select category', hintStyle: TextStyle(color: AppTheme.textSecondary)),
            items: AppConstants.raftCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedRaftCategory = v),
            validator: (v) => (v == null || v.isEmpty) ? 'Please select raft category' : null,
          ),
          const SizedBox(height: 16),
          _label('Operating Rivers'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.raftRiversList.map((river) {
              final sel = _selectedRivers.contains(river);
              return FilterChip(label: Text(river), selected: sel, onSelected: (v) => setState(() { if (v == true) { _selectedRivers.add(river); } else { _selectedRivers.remove(river); } }), selectedColor: AppTheme.lightBlue, checkmarkColor: AppTheme.darkBlue);
            }).toList(),
          ),
          const SizedBox(height: 16),
          _label('Duration Options'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.raftDurationOptions.map((d) {
              final sel = _selectedDurations.contains(d);
              return FilterChip(label: Text(d), selected: sel, onSelected: (v) => setState(() { if (v == true) { _selectedDurations.add(d); } else { _selectedDurations.remove(d); } }), selectedColor: AppTheme.lightBlue, checkmarkColor: AppTheme.darkBlue);
            }).toList(),
          ),
          const SizedBox(height: 16),
          _label('GST Number (Optional)'),
          const SizedBox(height: 6),
          TextFormField(controller: _gstController, decoration: const InputDecoration(hintText: 'e.g. 22AAAAA0000A1Z5', hintStyle: TextStyle(color: AppTheme.textSecondary))),
          const SizedBox(height: 16),
          _label('Insurance Upload (Optional)'),
          const SizedBox(height: 6),
          UploadPlaceholder(
            label: _raftInsuranceFilePath != null ? 'Insurance document selected' : 'Upload insurance document',
            icon: Icons.security_outlined,
            filePath: _raftInsuranceFilePath,
            onTap: () => _showSingleImageSheet((path) => setState(() => _raftInsuranceFilePath = path)),
          ),
          const SizedBox(height: 16),
          _label('Max Capacity (per raft)'),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _raftMaxCapacityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(hintText: '6'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = int.tryParse(v);
                    if (n == null || n <= 0 || n > 20) return 'Enter 1–20';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: AppTheme.greyBackground, borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), border: Border.all(color: AppTheme.borderColor)), alignment: Alignment.center, child: Text('PERSONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary))),
            ],
          ),
          const SizedBox(height: 16),
          _label('Life Jacket Count'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _raftLifeJacketController,
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
          _label('Helmet Count'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _raftHelmetController,
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
          _label('Raft Photos (Minimum ${AppConstants.minRaftPhotos} images)'),
          const SizedBox(height: 6),
          BoatPhotosSection(photoPaths: _raftPhotoPaths, onAdd: _showPhotosSourceSheet, onRemove: (i) => setState(() => _raftPhotoPaths.removeAt(i)), minRequired: AppConstants.minRaftPhotos),
          const SizedBox(height: 16),
          _label('Service Available Time Range'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () async { final p = await showTimePicker(context: context, initialTime: _raftStartTime); if (p != null) setState(() => _raftStartTime = p); }, icon: const Icon(Icons.access_time, size: 18), label: Text(_formatTime(_raftStartTime), style: const TextStyle(fontSize: 14)), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textPrimary, side: const BorderSide(color: AppTheme.borderColor)))),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('to', style: TextStyle(color: AppTheme.textSecondary))),
              Expanded(child: OutlinedButton.icon(onPressed: () async { final p = await showTimePicker(context: context, initialTime: _raftEndTime); if (p != null) setState(() => _raftEndTime = p); }, icon: const Icon(Icons.access_time, size: 18), label: Text(_formatTime(_raftEndTime), style: const TextStyle(fontSize: 14)), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textPrimary, side: const BorderSide(color: AppTheme.borderColor)))),
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
                Expanded(child: ServiceTab(label: AppConstants.raftPricingModels[0], isSelected: _pricingModelIndex == 0, onTap: () => setState(() => _pricingModelIndex = 0))),
                Expanded(child: ServiceTab(label: AppConstants.raftPricingModels[1], isSelected: _pricingModelIndex == 1, onTap: () => setState(() => _pricingModelIndex = 1))),
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
              Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: AppTheme.greyBackground, borderRadius: BorderRadius.horizontal(right: Radius.circular(AppTheme.borderRadiusMedium)), border: Border.all(color: AppTheme.borderColor)), alignment: Alignment.center, child: Text(_pricingModelIndex == 0 ? '/TRIP' : '/PERSON', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textSecondary))),
            ],
          ),
        ],
      ),
    );
  }
}
