// lib/features/alerts/widgets/alert_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onDismiss;
  final VoidCallback? onLockout;
  final VoidCallback? onViewLogs;

  const AlertCard({
    super.key,
    required this.alert,
    this.onDismiss,
    this.onLockout,
    this.onViewLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Camera image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: alert.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: alert.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _imagePlaceholder(),
                        errorWidget: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    alert.cameraId,
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      alert.typeLabel,
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        color: AppColors.danger,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  alert.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${alert.formattedTime}  •  Source: ${alert.deviceId}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action menu
                Row(
                  children: [
                    _menuButton(
                      icon: Icons.more_horiz,
                      onTap: () => _showActions(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.bgCardLight,
      child: const Center(
        child: Icon(Icons.videocam_off, color: AppColors.textMuted, size: 40),
      ),
    );
  }

  Widget _menuButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock, color: AppColors.danger),
              title: Text(
                'Initiate Lockout',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onLockout?.call();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.history,
                color: AppColors.textSecondary,
              ),
              title: Text(
                'View Logs',
                style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                onViewLogs?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: AppColors.textMuted),
              title: Text(
                'Dismiss',
                style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                onDismiss?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
