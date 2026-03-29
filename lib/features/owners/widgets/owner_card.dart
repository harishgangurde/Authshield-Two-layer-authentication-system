// lib/features/owners/widgets/owner_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/owner_model.dart';

class OwnerCard extends StatelessWidget {
  final OwnerModel owner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const OwnerCard({super.key, required this.owner, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: owner.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: owner.imageUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _avatarFallback(),
                        errorWidget: (_, __, ___) => _avatarFallback(),
                      )
                    : _avatarFallback(),
              ),
              if (owner.isActive)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.statusOnline,
                      border: Border.all(color: AppColors.bgCard, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Name & role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  owner.role.toUpperCase(),
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: _roleColor(owner.role),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Edit
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textMuted,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

          // Delete
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.textMuted,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      width: 52,
      height: 52,
      color: AppColors.bgCardLight,
      child: Center(
        child: Text(
          owner.initials,
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    final r = role.toLowerCase();
    if (r.contains('admin') || r.contains('primary')) return AppColors.primary;
    if (r.contains('manager')) return AppColors.accentBlue;
    if (r.contains('auditor')) return AppColors.warning;
    return AppColors.textMuted;
  }
}
