import 'dart:io';

import 'package:flutter/material.dart';
import '../../config/theam_data.dart';

/// Shared form components for vendor registration (boat & rafting)
class UploadPlaceholder extends StatelessWidget {
  const UploadPlaceholder({
    super.key,
    required this.label,
    required this.icon,
    this.filePath,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final String? filePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: filePath != null ? AppTheme.primaryBlue : AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: filePath != null ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
        if (filePath != null)
          const Icon(Icons.check_circle, size: 20, color: AppTheme.primaryBlue),
      ],
    );
    final container = Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.borderColor),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }
    return container;
  }
}

class BoatPhotosSection extends StatelessWidget {
  const BoatPhotosSection({
    super.key,
    required this.photoPaths,
    required this.onAdd,
    required this.onRemove,
    required this.minRequired,
  });

  final List<String> photoPaths;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final int minRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...photoPaths.asMap().entries.map((e) => PhotoChip(
                  index: e.key,
                  label: 'Photo ${e.key + 1}',
                  imagePath: e.value,
                  onRemove: () => onRemove(e.key),
                )),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.greyBackground,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
        if (photoPaths.length < minRequired)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Add at least $minRequired photos (${photoPaths.length}/$minRequired)',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class PhotoChip extends StatelessWidget {
  const PhotoChip({
    super.key,
    required this.index,
    required this.label,
    required this.onRemove,
    this.imagePath,
  });

  final int index;
  final String label;
  final String? imagePath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasValidFile = imagePath != null &&
        imagePath!.isNotEmpty &&
        (File(imagePath!).existsSync());

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.lightBlue,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            child: hasValidFile
                ? Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_outlined, size: 28, color: AppTheme.darkBlue),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(Icons.close, size: 14, color: AppTheme.white),
            ),
          ),
        ),
      ],
    );
  }
}

class ServiceTab extends StatelessWidget {
  const ServiceTab({
    super.key,
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
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
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
