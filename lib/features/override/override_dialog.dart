// lib/features/override/override_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/services/supabase_service.dart';

class OverrideDialog extends StatefulWidget {
  const OverrideDialog({super.key});

  @override
  State<OverrideDialog> createState() => _OverrideDialogState();
}

class _OverrideDialogState extends State<OverrideDialog> {
  bool _loading = false;
  bool _success = false;

  String get _timestamp => DateFormat('HH:mm:ss').format(DateTime.now());

  Future<void> _confirmUnlock() async {
    setState(() => _loading = true);
    try {
      final unlocked = await ApiService().unlockDoor();
      await SupabaseService().logManualUnlock(AppConstants.defaultDeviceId);
      if (mounted) {
        setState(() {
          _loading = false;
          _success = unlocked;
        });
        if (unlocked) {
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border(
            top: BorderSide(
              color: AppColors.accentBlue.withOpacity(0.6),
              width: 2,
            ),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2235), AppColors.bgCard],
          ),
        ),
        child: _success ? _buildSuccess() : _buildConfirm(),
      ).animate().slideY(begin: 0.3).fadeIn(),
    );
  }

  Widget _buildConfirm() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.danger.withOpacity(0.15),
            ),
            child: const Icon(
              Icons.lock_open,
              color: AppColors.danger,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Are you sure you want to manually unlock the door?',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Device info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _infoRow('DEVICE ID', AppConstants.defaultDeviceId),
                const SizedBox(height: 8),
                _infoRow('CURRENT TIMESTAMP', _timestamp),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'This action will bypass all biometric and MFA protocols. A manual override log will be generated and broadcasted to all security administrators immediately.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _confirmUnlock,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.accentBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'CONFIRM UNLOCK',
                      style: GoogleFonts.spaceMono(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: GoogleFonts.spaceMono(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == 0 ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              Text(
                'AUTH PROTOCOL: ${AppConstants.authProtocol}',
                style: GoogleFonts.spaceMono(
                  fontSize: 9,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
            ),
            child: const Icon(Icons.check, color: AppColors.primary, size: 40),
          ).animate().scale().fadeIn(),
          const SizedBox(height: 20),
          Text(
            'Door Unlocked',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Override logged and broadcasted',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
