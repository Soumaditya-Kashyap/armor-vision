import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Dialog showing export progress with steps
class ExportProgressDialog extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String statusText;

  const ExportProgressDialog({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = currentStep / totalSteps;

    return PopScope(
      canPop: false, // Prevent dismissal during export
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.document_download,
                  color: theme.colorScheme.primary,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Exporting Passwords',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Step counter
              Text(
                'Step $currentStep of $totalSteps',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 24),

              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                color: theme.colorScheme.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),

              const SizedBox(height: 16),

              // Status text
              Text(
                statusText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
