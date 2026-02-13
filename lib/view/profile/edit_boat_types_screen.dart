import 'package:flutter/material.dart';
import '../../config/theam_data.dart';
import '../../constants/app_constants.dart';
import '../../data/app_data.dart';

/// Screen to edit boat types offered (Boat Service only)
class EditBoatTypesScreen extends StatefulWidget {
  const EditBoatTypesScreen({super.key});

  @override
  State<EditBoatTypesScreen> createState() => _EditBoatTypesScreenState();
}

class _EditBoatTypesScreenState extends State<EditBoatTypesScreen> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    final company = AppData.currentCompanyInfo ?? AppData.getSampleCompanyInfo();
    _selected = Set<String>.from(company.boatTypes);
  }

  void _save() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one boat type')),
      );
      return;
    }
    final company = AppData.currentCompanyInfo ?? AppData.getSampleCompanyInfo();
    AppData.currentCompanyInfo = company.copyWith(boatTypes: _selected.toList());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Boat types updated')),
    );
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Edit Boat Types'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        children: [
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Select the boat types you offer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingS,
            children: AppConstants.boatTypes.map((type) {
              final selected = _selected.contains(type);
              return FilterChip(
                label: Text(type),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v == true) {
                      _selected.add(type);
                    } else {
                      _selected.remove(type);
                    }
                  });
                },
                selectedColor: AppTheme.lightBlue,
                checkmarkColor: AppTheme.darkBlue,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
