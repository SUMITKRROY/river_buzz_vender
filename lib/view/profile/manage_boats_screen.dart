import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theam_data.dart';
import '../../constants/app_constants.dart';
import '../../data/app_data.dart';
import '../../models/vendor_boat.dart';

/// Status colors: Green → Available, Blue → Booked, Orange → Pending
Color _statusColor(BoatAvailabilityStatus status) {
  switch (status) {
    case BoatAvailabilityStatus.available:
      return AppTheme.successGreen;
    case BoatAvailabilityStatus.booked:
      return AppTheme.primaryBlue;
    case BoatAvailabilityStatus.pending:
      return AppTheme.accentOrange;
  }
}

String _statusLabel(BoatAvailabilityStatus status) {
  switch (status) {
    case BoatAvailabilityStatus.available:
      return 'Available';
    case BoatAvailabilityStatus.booked:
      return 'Booked';
    case BoatAvailabilityStatus.pending:
      return 'Pending';
  }
}

/// Screen to add, edit, and remove multiple boats (Boat Service)
class ManageBoatsScreen extends StatefulWidget {
  const ManageBoatsScreen({super.key});

  @override
  State<ManageBoatsScreen> createState() => _ManageBoatsScreenState();
}

class _ManageBoatsScreenState extends State<ManageBoatsScreen> {
  List<VendorBoat> get _boats {
    final company = AppData.currentCompanyInfo ?? AppData.getSampleCompanyInfo();
    return List<VendorBoat>.from(company.boats);
  }

  void _updateBoats(List<VendorBoat> boats) {
    final company = AppData.currentCompanyInfo ?? AppData.getSampleCompanyInfo();
    AppData.currentCompanyInfo = company.copyWith(boats: boats);
    setState(() {});
  }

  void _addBoat() {
    _showBoatSheet();
  }

  void _editBoat(VendorBoat boat) {
    _showBoatSheet(existing: boat);
  }

  void _showBoatSheet({VendorBoat? existing}) async {
    final result = await showModalBottomSheet<VendorBoat>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddEditBoatSheet(
        existing: existing,
        boatTypes: AppConstants.boatTypes,
        pricingModels: AppConstants.boatPricingModels,
      ),
    );
    if (result == null || !mounted) return;
    final list = _boats;
    if (existing != null) {
      final i = list.indexWhere((e) => e.id == existing.id);
      if (i >= 0) list[i] = result;
    } else {
      list.add(result);
    }
    _updateBoats(list);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(existing != null ? 'Boat updated' : 'Boat added')),
    );
  }

  void _removeBoat(VendorBoat boat) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove boat?'),
        content: Text('Remove "${boat.name}" from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final list = _boats;
              list.removeWhere((e) => e.id == boat.id);
              _updateBoats(list);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Boat removed')),
              );
            },
            child: const Text('Remove', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  void _markOfflineBooking(VendorBoat boat) {
    final list = _boats;
    final i = list.indexWhere((e) => e.id == boat.id);
    if (i < 0) return;
    list[i] = boat.copyWith(availabilityStatus: BoatAvailabilityStatus.booked);
    _updateBoats(list);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${boat.name} marked as Booked (offline)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boats = _boats;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('My Boats'),
        centerTitle: true,
      ),
      body: boats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_boat_outlined, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'No boats added yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    'Tap + to add your first boat',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingM),
              itemCount: boats.length,
              itemBuilder: (context, index) {
                final boat = boats[index];
                final statusColor = _statusColor(boat.availabilityStatus);
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(width: 5, color: statusColor)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          leading: _boatLeading(boat),
                          title: Text(boat.name),
                          subtitle: Text(
                            '${boat.boatType} • ${boat.capacity} persons'
                            '${boat.boatNumber.isNotEmpty ? ' • #${boat.boatNumber}' : ''}\n'
                            '${boat.jacketCount} jackets • ${boat.pricingModel}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 22),
                                onPressed: () => _editBoat(boat),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 22, color: AppTheme.errorRed),
                                onPressed: () => _removeBoat(boat),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppTheme.spacingM, 0, AppTheme.spacingM, AppTheme.spacingM),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS, vertical: AppTheme.spacingXS),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusPill),
                                ),
                                child: Text(
                                  _statusLabel(boat.availabilityStatus),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              TextButton.icon(
                                onPressed: () => _markOfflineBooking(boat),
                                icon: const Icon(Icons.event_busy_rounded, size: 18),
                                label: const Text('Mark Offline Booking'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBoat,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _boatLeading(VendorBoat boat) {
    if (boat.photoUrls.isNotEmpty) {
      final path = boat.photoUrls.first;
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: path.startsWith('http') || path.startsWith('/')
            ? Image.network(path, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _defaultBoatAvatar())
            : (path.isNotEmpty && File(path).existsSync()
                ? Image.file(File(path), width: 56, height: 56, fit: BoxFit.cover)
                : _defaultBoatAvatar()),
      );
    }
    return _defaultBoatAvatar();
  }

  Widget _defaultBoatAvatar() {
    return CircleAvatar(
      backgroundColor: AppTheme.lightBlue,
      child: Icon(Icons.directions_boat_rounded, color: AppTheme.primaryBlue),
    );
  }
}

class _AddEditBoatSheet extends StatefulWidget {
  final VendorBoat? existing;
  final List<String> boatTypes;
  final List<String> pricingModels;

  const _AddEditBoatSheet({
    this.existing,
    required this.boatTypes,
    required this.pricingModels,
  });

  @override
  State<_AddEditBoatSheet> createState() => _AddEditBoatSheetState();
}

class _AddEditBoatSheetState extends State<_AddEditBoatSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _capacityController;
  late final TextEditingController _jacketController;
  late final TextEditingController _boatNumberController;
  late String _selectedType;
  late String _selectedPricing;
  List<String> _photoPaths = [];
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _capacityController = TextEditingController(text: e?.capacity.toString() ?? '6');
    _jacketController = TextEditingController(text: e?.jacketCount.toString() ?? '0');
    _boatNumberController = TextEditingController(text: e?.boatNumber ?? '');
    _selectedType = e?.boatType ?? widget.boatTypes.first;
    _selectedPricing = e?.pricingModel ?? widget.pricingModels.first;
    _photoPaths = List.from(e?.photoUrls ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _jacketController.dispose();
    _boatNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() => _photoPaths.add(file.path));
    }
  }

  void _removePhoto(int index) {
    setState(() => _photoPaths.removeAt(index));
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter boat name')));
      return;
    }
    final capacity = int.tryParse(_capacityController.text.trim());
    if (capacity == null || capacity < 1 || capacity > AppConstants.maxCapacityLimit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid capacity (1–1000)')));
      return;
    }
    final jackets = int.tryParse(_jacketController.text.trim()) ?? 0;
    final boat = VendorBoat(
      id: widget.existing?.id ?? 'b_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      boatType: _selectedType,
      capacity: capacity,
      jacketCount: jackets < 0 ? 0 : jackets,
      boatNumber: _boatNumberController.text.trim(),
      photoUrls: _photoPaths,
      pricingModel: _selectedPricing,
      availabilityStatus: widget.existing?.availabilityStatus ?? BoatAvailabilityStatus.available,
    );
    Navigator.pop(context, boat);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.spacingM,
        right: AppTheme.spacingM,
        top: AppTheme.spacingM,
        bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacingM,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadiusLarge)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                widget.existing != null ? 'Edit boat' : 'Add boat',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.spacingL),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Boat name',
                  hintText: 'e.g. Sunrise Cruiser',
                ),
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: AppTheme.spacingM),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Boat type'),
                items: widget.boatTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v ?? widget.boatTypes.first),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Capacity (persons)',
                  hintText: '6',
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > AppConstants.maxCapacityLimit) return 'Enter 1–${AppConstants.maxCapacityLimit}';
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _jacketController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Jacket count',
                  hintText: '0',
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                controller: _boatNumberController,
                decoration: const InputDecoration(
                  labelText: 'Boat number',
                  hintText: 'e.g. RB-001',
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              DropdownButtonFormField<String>(
                value: _selectedPricing,
                decoration: const InputDecoration(labelText: 'Pricing model'),
                items: widget.pricingModels.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _selectedPricing = v ?? widget.pricingModels.first),
              ),
              const SizedBox(height: AppTheme.spacingM),
              const Text('Photos', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: AppTheme.spacingXS),
              Wrap(
                spacing: AppTheme.spacingS,
                runSpacing: AppTheme.spacingS,
                children: [
                  ..._photoPaths.asMap().entries.map((e) {
                    final path = e.value;
                    final isFile = path.isNotEmpty && !path.startsWith('http');
                    return Stack(
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            child: isFile && File(path).existsSync()
                                ? Image.file(File(path), fit: BoxFit.cover)
                                : Container(
                                    color: AppTheme.greyBackground,
                                    child: Icon(Icons.image, color: AppTheme.textSecondary),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _removePhoto(e.key),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppTheme.errorRed,
                              child: Icon(Icons.close, size: 16, color: AppTheme.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: Icon(Icons.add_photo_alternate_outlined, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXL),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.existing != null ? 'Update boat' : 'Add boat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
