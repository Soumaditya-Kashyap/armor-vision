import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../services/database_service.dart';
import '../splash_screen.dart';

// ─── Data Model ─────────────────────────────────────────────────────────────

class _OnboardingPage {
  final String headline;
  final String description;
  final IconData icon;
  final Color bgColor;
  final List<_FeatureChip> chips;

  const _OnboardingPage({
    required this.headline,
    required this.description,
    required this.icon,
    required this.bgColor,
    this.chips = const [],
  });
}

class _FeatureChip {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});
}

// ─── Page Content ───────────────────────────────────────────────────────────
// Vibrant backgrounds so the concentric circle (= next page bg) is colorful.

const _kPages = <_OnboardingPage>[
  // Screen 1 — Royal Blue
  _OnboardingPage(
    headline: 'Your Passwords.\nYour Device.\nNo Cloud.',
    description:
        'Most password managers upload your data to their servers — putting it at risk every single day. '
        'ARMOR is different. Everything is stored encrypted on your device alone. '
        'No syncing. No servers. No exposure. Your secrets stay yours, forever.',
    icon: Iconsax.shield_tick5,
    bgColor: Color(0xFF1E3A8A),
    chips: [
      _FeatureChip(icon: Iconsax.cloud_cross, label: 'Zero Cloud'),
      _FeatureChip(icon: Iconsax.lock_15, label: 'AES-256 Encrypted'),
      _FeatureChip(icon: Iconsax.mobile, label: 'Fully On-Device'),
      _FeatureChip(icon: Iconsax.eye_slash, label: 'No Telemetry'),
    ],
  ),

  // Screen 2 — Emerald Green
  _OnboardingPage(
    headline: 'Unlocks With\nYour Identity,\nNot a Password.',
    description:
        'You already carry the most secure key in the world — your fingerprint or face. '
        'ARMOR wraps around your device\'s built-in biometric system so you never '
        'need to remember a master password. One glance or touch, and you\'re in. '
        'Failed attempts lock the vault automatically.',
    icon: Iconsax.finger_scan,
    bgColor: Color(0xFF065F46),
    chips: [
      _FeatureChip(icon: Iconsax.finger_cricle, label: 'Fingerprint / Face'),
      _FeatureChip(icon: Iconsax.timer_15, label: 'Auto-Lock'),
      _FeatureChip(icon: Iconsax.security_safe, label: 'Fallback PIN'),
      _FeatureChip(icon: Iconsax.close_circle, label: 'Brute-Force Lock'),
    ],
  ),

  // Screen 3 — Vivid Purple
  _OnboardingPage(
    headline: 'Every Secret.\nOne Secure\nPlace.',
    description:
        'Passwords are just the beginning. Store credit cards, bank PINs, Wi-Fi '
        'credentials, private notes, and any custom field you need — all behind the '
        'same vault. Organize with color-coded categories so finding anything takes '
        'seconds, not minutes.',
    icon: Iconsax.folder_open5,
    bgColor: Color(0xFF5B21B6),
    chips: [
      _FeatureChip(icon: Iconsax.key, label: 'Passwords'),
      _FeatureChip(icon: Iconsax.card, label: 'Cards & PINs'),
      _FeatureChip(icon: Iconsax.note_215, label: 'Secure Notes'),
      _FeatureChip(icon: Iconsax.category, label: 'Custom Categories'),
    ],
  ),

  // Screen 4 — Crimson Red
  _OnboardingPage(
    headline: 'Export.\nBackup.\nRestore. Easy.',
    description:
        'Switching phones shouldn\'t mean losing everything. ARMOR exports your '
        'entire vault into a single encrypted .armor file — locked with your master key. '
        'Copy it anywhere and restore in seconds. No cloud needed, no account required, '
        'full control is always in your hands.',
    icon: Iconsax.document_upload5,
    bgColor: Color(0xFFBE123C),
    chips: [
      _FeatureChip(icon: Iconsax.document_code, label: '.armor File Format'),
      _FeatureChip(icon: Iconsax.refresh, label: 'One-Tap Restore'),
      _FeatureChip(icon: Iconsax.security_user, label: 'Master Key Locked'),
      _FeatureChip(icon: Iconsax.export, label: 'PDF Export'),
    ],
  ),

  // Screen 5 — Deep Midnight
  _OnboardingPage(
    headline: 'You Are Ready.\nThe Vault\nAwaits.',
    description:
        'Set your master key, enable biometrics, and step inside. '
        'Everything you store from this moment forward is private, encrypted, and yours alone. '
        'No subscriptions. No ads. No compromise.',
    icon: Iconsax.shield_tick5,
    bgColor: Color(0xFF0F172A),
    chips: [
      _FeatureChip(icon: Iconsax.verify, label: 'Private by Design'),
      _FeatureChip(icon: Iconsax.unlimited, label: 'Unlimited Entries'),
      _FeatureChip(icon: Iconsax.heart, label: 'No Subscription'),
    ],
  ),
];

// ─── Screen Widget ──────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final db = DatabaseService();
    final settings = await db.getAppSettings();
    final updated = settings.copyWith(
      hasCompletedOnboarding: true,
      isFirstLaunch: false,
      updatedAt: DateTime.now(),
    );
    await db.saveAppSettings(updated);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const SplashScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLastPage = _currentPage == _kPages.length - 1;
    final double btnRadius = screenWidth * 0.145;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          ConcentricPageView(
            colors: _kPages.map((p) => p.bgColor).toList(),
            itemCount: _kPages.length,
            verticalPosition: 0.84,
            scaleFactor: 0.2,
            opacityFactor: 2.0,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOutCubic,
            onChange: (i) => setState(() => _currentPage = i),
            onFinish: _completeOnboarding,
            nextButtonBuilder: (context) {
              return Icon(
                Icons.arrow_forward_rounded,
                size: screenWidth * 0.07,
                color: Colors.white,
              );
            },
            radius: btnRadius,
            itemBuilder: (index) {
              final p = _kPages[index % _kPages.length];
              return _OnboardingPageWidget(
                page: p,
                isLastPage: index == _kPages.length - 1,
                pageIndex: index,
                totalPages: _kPages.length,
              );
            },
          ),

          // Skip button
          if (!isLastPage)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: GestureDetector(
                onTap: _completeOnboarding,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Page Widget ────────────────────────────────────────────────────────────

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingPage page;
  final bool isLastPage;
  final int pageIndex;
  final int totalPages;

  const _OnboardingPageWidget({
    required this.page,
    required this.isLastPage,
    required this.pageIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.16;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.07),

            // Indicator dots
            _PageIndicator(total: totalPages, current: pageIndex),

            SizedBox(height: size.height * 0.06),

            // Clean icon in a white-tinted circle
            Container(
              width: iconSize * 1.7,
              height: iconSize * 1.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Icon(page.icon, size: iconSize, color: Colors.white),
              ),
            ),

            SizedBox(height: size.height * 0.05),

            // Headline — bold white
            Text(
              page.headline,
              textAlign: TextAlign.center,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.6,
                letterSpacing: 0.1,
              ),
            ),

            const SizedBox(height: 28),

            // Feature chips
            if (page.chips.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: page.chips
                    .map((chip) => _ChipWidget(chip: chip))
                    .toList(),
              ),

            // Last page — "ENTER ARMOR" hint above the button
            if (isLastPage) ...[
              const Spacer(),
              Text(
                'ENTER  ARMOR',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: 5.0,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.keyboard_double_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.25),
                size: 18,
              ),
              SizedBox(height: size.height * 0.12),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Page Indicator ─────────────────────────────────────────────────────────

class _PageIndicator extends StatelessWidget {
  final int total;
  final int current;

  const _PageIndicator({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 4,
          width: isActive ? 28 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.25),
          ),
        );
      }),
    );
  }
}

// ─── Feature Chip ───────────────────────────────────────────────────────────

class _ChipWidget extends StatelessWidget {
  final _FeatureChip chip;

  const _ChipWidget({required this.chip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chip.icon, size: 14, color: Colors.white),
          const SizedBox(width: 7),
          Text(
            chip.label,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
