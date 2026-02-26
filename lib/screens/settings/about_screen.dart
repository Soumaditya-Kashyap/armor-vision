import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

/// About screen — explains how ARMOR works and its features.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'About ARMOR',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App branding
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Iconsax.shield_tick5,
                      size: 40,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'ARMOR',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Password Manager',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'v1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // What is ARMOR
            _SectionTitle(title: 'What is ARMOR?', colorScheme: colorScheme),
            const SizedBox(height: 10),
            _DescriptionText(
              text:
                  'ARMOR is an open-source, privacy-first, fully offline password manager built with Flutter. '
                  'It stores all your sensitive data — passwords, cards, notes, and more — '
                  'encrypted on your device. No cloud. No servers. No tracking. '
                  'The entire source code is publicly available for anyone to audit, contribute to, or learn from.',
              colorScheme: colorScheme,
            ),

            const SizedBox(height: 28),

            // How it works
            _SectionTitle(title: 'How It Works', colorScheme: colorScheme),
            const SizedBox(height: 14),

            _FeaturePoint(
              icon: Iconsax.finger_scan,
              title: 'Device-Level Authentication',
              description:
                  'ARMOR uses your phone\'s built-in lock — fingerprint, Face ID, or PIN. '
                  'No separate master password to remember. Your biometric IS the key.',
              colorScheme: colorScheme,
            ),
            _FeaturePoint(
              icon: Iconsax.lock_15,
              title: 'AES-256 Encryption',
              description:
                  'Every entry is encrypted with military-grade AES-256 before being stored. '
                  'Even if someone accesses your device storage, the data is unreadable.',
              colorScheme: colorScheme,
            ),
            _FeaturePoint(
              icon: Iconsax.category,
              title: 'Organize by Categories',
              description:
                  'Create custom categories like Banking, Social Media, Work, etc. '
                  'Color-code and assign icons to keep your vault organized. '
                  'Preset categories are provided out of the box.',
              colorScheme: colorScheme,
            ),
            _FeaturePoint(
              icon: Iconsax.add_circle,
              title: 'Custom Fields',
              description:
                  'Each entry supports dynamic fields — email, password, URL, notes, '
                  'or any custom label you need. Hide sensitive fields with a tap.',
              colorScheme: colorScheme,
            ),
            _FeaturePoint(
              icon: Iconsax.star,
              title: 'Favorites & Search',
              description:
                  'Star your most-used entries for quick access. '
                  'Full-text search across all entries, categories, and fields.',
              colorScheme: colorScheme,
            ),
            _FeaturePoint(
              icon: Iconsax.document_upload5,
              title: 'Encrypted .armor Backups',
              description:
                  'Export your entire vault into a single encrypted .armor file locked '
                  'with your master key. Transfer to a new phone and restore in seconds. '
                  'No cloud needed.',
              colorScheme: colorScheme,
            ),
            _FeaturePoint(
              icon: Iconsax.document_text,
              title: 'PDF Export',
              description:
                  'Generate a printable PDF of your passwords for safe offline storage. '
                  'Password-protected for extra security.',
              colorScheme: colorScheme,
            ),
            _FeaturePoint(
              icon: Iconsax.timer_1,
              title: 'Auto-Lock & Session Timeout',
              description:
                  'ARMOR automatically locks after 5 minutes of inactivity. '
                  'Failed authentication attempts trigger a progressive lockout.',
              colorScheme: colorScheme,
            ),
            _FeaturePoint(
              icon: Iconsax.brush_1,
              title: 'Multiple Themes',
              description:
                  'Choose between Light, Dark, Armor (aurora-themed), or System default. '
                  'All built with Material Design 3.',
              colorScheme: colorScheme,
            ),

            const SizedBox(height: 28),

            // Privacy note
            _SectionTitle(title: 'Privacy Promise', colorScheme: colorScheme),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.shield_tick5,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ARMOR collects zero data. No analytics, no telemetry, no crash reports. '
                      'Your vault never touches the internet. Everything stays on your device, period.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Tech stack
            _SectionTitle(title: 'Built With', colorScheme: colorScheme),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _TechChip(label: 'Flutter'),
                _TechChip(label: 'Dart'),
                _TechChip(label: 'Hive DB (NoSQL)'),
                _TechChip(label: 'AES-256 Encryption'),
                _TechChip(label: 'Material Design 3'),
                _TechChip(label: 'Biometric Auth'),
                _TechChip(label: 'Google Fonts'),
                _TechChip(label: 'Iconsax Icons'),
                _TechChip(label: 'PDF Generation'),
                _TechChip(label: 'Provider'),
                _TechChip(label: 'Secure Storage'),
                _TechChip(label: 'Lottie Animations'),
                _TechChip(label: 'more+'),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final ColorScheme colorScheme;

  const _SectionTitle({required this.title, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.bricolageGrotesque(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _DescriptionText extends StatelessWidget {
  final String text;
  final ColorScheme colorScheme;

  const _DescriptionText({required this.text, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.6,
      ),
    );
  }
}

class _FeaturePoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final ColorScheme colorScheme;

  const _FeaturePoint({
    required this.icon,
    required this.title,
    required this.description,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;

  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
