// lib/features/history/widgets/log_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/log_model.dart';

class LogTile extends StatelessWidget {
  final LogModel log;

  const LogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _statusIcon(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      log.action,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.deviceId}  •  ${log.formattedTime}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            log.formattedDate,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon() {
    switch (log.status) {
      case LogStatus.success:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.statusSuccess.withOpacity(0.15),
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.statusSuccess,
            size: 22,
          ),
        );
      case LogStatus.failure:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.danger.withOpacity(0.15),
          ),
          child: const Icon(Icons.cancel, color: AppColors.danger, size: 22),
        );
      case LogStatus.manual:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.statusManual.withOpacity(0.15),
          ),
          child: const Icon(
            Icons.vpn_key,
            color: AppColors.statusManual,
            size: 22,
          ),
        );
    }
  }

  Widget _statusBadge() {
    Color color;
    String label;

    switch (log.status) {
      case LogStatus.success:
        color = AppColors.statusSuccess;
        label = 'SUCCESS';
        break;
      case LogStatus.failure:
        color = AppColors.danger;
        label = 'FAILURE';
        break;
      case LogStatus.manual:
        color = AppColors.statusManual;
        label = 'MANUAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceMono(
          fontSize: 9,
          color: color,
          letterSpacing: 1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
