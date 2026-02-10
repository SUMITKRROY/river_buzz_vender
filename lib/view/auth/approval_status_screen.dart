import 'package:flutter/material.dart';
import '../../config/theam_data.dart';
import '../../constants/app_constants.dart';
import '../../utils/navigation_utils.dart';

/// Screen shown after vendor registration while admin verification is pending.
class ApprovalStatusScreen extends StatelessWidget {
  const ApprovalStatusScreen({
    super.key,
    this.applicationId = 'RB-99283',
    this.submittedDate = 'Oct 24',
  });

  final String applicationId;
  final String submittedDate;

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
          'Approval Status',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              NavigationUtils.pushNamedAndRemoveUntil(
                context,
                AppConstants.homeRoute,
              );
            },
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Icon in light blue circle
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppTheme.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.find_in_page_outlined,
                  size: 56,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Pending Admin Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We are reviewing your details. This usually takes 24-48 hours. You will be notified via email once your account is active.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.normal,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Status stepper: SUBMITTED -> REVIEWING -> ACTIVE
              _StatusStepper(
                steps: const [
                  _StepInfo(label: 'SUBMITTED', state: _StepState.completed),
                  _StepInfo(label: 'REVIEWING', state: _StepState.active),
                  _StepInfo(label: 'ACTIVE', state: _StepState.pending),
                ],
              ),
              const Spacer(),
              // Contact Support button
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Open contact support (email, chat, etc.)
                  },
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
                  child: const Text('Contact Support'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Application ID: $applicationId • Submitted $submittedDate',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum _StepState { completed, active, pending }

class _StepInfo {
  const _StepInfo({required this.label, required this.state});
  final String label;
  final _StepState state;
}

class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.steps});

  final List<_StepInfo> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _StepIndicator(
            label: steps[i].label,
            state: steps[i].state,
          ),
          if (i < steps.length - 1)
            Expanded(
              child: _DashedConnector(
                isActive: steps[i].state == _StepState.completed,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.label, required this.state});

  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == _StepState.completed;
    final isActive = state == _StepState.active;
    final isPending = state == _StepState.pending;

    final circleColor = isCompleted
        ? AppTheme.primaryBlue
        : isActive
            ? AppTheme.lightBlue
            : AppTheme.greyBackground;
    final borderColor = isActive ? AppTheme.primaryBlue : AppTheme.borderColor;
    final labelColor = isPending ? AppTheme.textSecondary : AppTheme.darkBlue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: borderColor, width: 2)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _DashedConnector extends StatelessWidget {
  const _DashedConnector({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primaryBlue : AppTheme.borderColor;
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 8.0;
        const gap = 6.0;
        final n = ((constraints.maxWidth + gap) / (dashWidth + gap)).floor();
        return SizedBox(
          height: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(n.clamp(2, 30), (i) {
              return Padding(
                padding: EdgeInsets.only(right: i < n - 1 ? gap : 0),
                child: Container(
                  width: dashWidth,
                  height: 2,
                  color: color,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
