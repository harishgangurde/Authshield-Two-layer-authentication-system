// lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
    if (!mounted) return;
    if (done) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      await prefs.setBool(AppConstants.keyOnboardingDone, true);
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF0D2040), AppColors.bgDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo cluster ──────────────────────────────────────────
              _buildLogoCluster(),

              const SizedBox(height: 48),

              // ── Title ─────────────────────────────────────────────────
              Text(
                'Smart 2FA',
                style: GoogleFonts.spaceMono(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 40,
                    child: Divider(color: AppColors.primary, thickness: 1),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SECURE ACCESS',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      color: AppColors.primary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 40,
                    child: Divider(color: AppColors.primary, thickness: 1),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Multi-Owner Support for Advanced Security.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms),

              const Spacer(flex: 2),

              // ── Progress bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progressController.value,
                            backgroundColor: AppColors.bgCardLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 3,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SYSTEM INTEGRITY: OPTIMAL',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDots(),
                  ],
                ),
              ).animate().fadeIn(delay: 1200.ms),

              const SizedBox(height: 48),

              // ── Footer ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SECURED BY AuthShield ${AppConstants.appVersion}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 1400.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCluster() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow background
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) => Container(
              width: 120 + (_pulseController.value * 20),
              height: 120 + (_pulseController.value * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(
                  0.05 + _pulseController.value * 0.05,
                ),
              ),
            ),
          ),

          // Main shield card
          Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.shield,
                  color: AppColors.primary,
                  size: 56,
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms)
              .scale(begin: const Offset(0.5, 0.5)),

          // Key badge (top right)
          Positioned(
            top: 20,
            right: 10,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.bgCardLight),
              ),
              child: const Icon(
                Icons.key,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.5),
          ),

          // Fingerprint badge (bottom left)
          Positioned(
            bottom: 20,
            left: 10,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgCard.withOpacity(0.7),
                border: Border.all(color: AppColors.bgCardLight),
              ),
              child: const Icon(
                Icons.fingerprint,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final active = (_progressController.value * 3).floor() >= i;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.primary : AppColors.textMuted,
              ),
            );
          }),
        );
      },
    );
  }
}
