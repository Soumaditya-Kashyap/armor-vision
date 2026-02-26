import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

/// Developer screen — info about the creator of ARMOR.
class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  static const String _email = 'officialsoumaditya@gmail.com';
  static const String _github = 'https://github.com/Soumaditya-Kashyap';
  static const String _linkedin =
      'https://www.linkedin.com/in/soumaditya-kashyap-27689b204';

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Developer',
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
            // Developer profile card
            Center(
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primaryContainer,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Iconsax.user,
                      size: 44,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Soumaditya Kashyap',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Guwahati, Assam, India',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Divider
            Divider(color: colorScheme.outline.withValues(alpha: 0.1)),

            const SizedBox(height: 20),

            // About the developer
            Text(
              'About',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'A passionate developer from Assam who builds practical solutions to real-world problems. '
              'Skilled in Flutter, full-stack development, and AI/ML — focused on creating apps that '
              'are clean, performant, and genuinely useful. ARMOR was built from scratch as a privacy-first '
              'alternative to cloud-dependent password managers. '
              'Every line of code is written with the user\'s security and experience in mind.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),

            // Divider
            Divider(color: colorScheme.outline.withValues(alpha: 0.1)),

            const SizedBox(height: 20),

            // Contact section
            Text(
              'Get in Touch',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'If you love the app, have suggestions, or found a bug — feel free to reach out!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Email
            _ContactTile(
              icon: Iconsax.sms,
              title: 'Email',
              subtitle: _email,
              trailing: Icons.copy_rounded,
              onTap: () => _copyToClipboard(context, _email, 'Email'),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 10),

            // LinkedIn
            _ContactTile(
              icon: Iconsax.link,
              title: 'LinkedIn',
              subtitle: 'Soumaditya Kashyap',
              trailing: Icons.copy_rounded,
              onTap: () => _copyToClipboard(context, _linkedin, 'LinkedIn URL'),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 10),

            // GitHub
            _ContactTile(
              icon: Iconsax.code,
              title: 'GitHub',
              subtitle: 'Soumaditya-Kashyap',
              trailing: Icons.copy_rounded,
              onTap: () => _copyToClipboard(context, _github, 'GitHub URL'),
              colorScheme: colorScheme,
            ),

            const SizedBox(height: 32),

            // Connect CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.4),
                    colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.heart5, size: 32, color: colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Enjoying ARMOR?',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If this app makes your life even a little easier, '
                    'consider connecting on LinkedIn or dropping a message. '
                    'Your feedback means everything and helps make ARMOR better for everyone.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'For any issues, please email me directly.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ─────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailing;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
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
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                trailing,
                size: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
