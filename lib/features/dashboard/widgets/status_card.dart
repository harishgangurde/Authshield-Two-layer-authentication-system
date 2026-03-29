// lib/features/dashboard/widgets/status_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class StatusCard extends StatelessWidget {
  final bool isOnline;
  final int activeAlerts;

  const StatusCard({
    super.key,
    required this.isOnline,
    required this.activeAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final isSafe = isOnline && activeAlerts == 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSafe
              ? [const Color(0xFF0D2A1F), const Color(0xFF0A1F17)]
              : [const Color(0xFF2A0D0D), const Color(0xFF1F0A0A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSafe
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.danger.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SECURITY PROTOCOL ALPHA',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: isSafe ? AppColors.primary : AppColors.danger,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'System Status:\n${isSafe ? 'SAFE' : 'ALERT'}',
            style: GoogleFonts.spaceMono(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSafe
                ? 'All encryption layers active. Perimeter secure.'
                : 'Intrusion detected. Immediate response required.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isSafe ? AppColors.primary : AppColors.danger)
                      .withOpacity(0.15),
                  border: Border.all(
                    color: (isSafe ? AppColors.primary : AppColors.danger)
                        .withOpacity(0.4),
                  ),
                ),
                child: Icon(
                  isSafe ? Icons.shield : Icons.warning_rounded,
                  color: isSafe ? AppColors.primary : AppColors.danger,
                  size: 28,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 2000.ms,
                color: isSafe ? AppColors.primary : AppColors.danger,
              ),
        ],
      ),
    );
  }
}
