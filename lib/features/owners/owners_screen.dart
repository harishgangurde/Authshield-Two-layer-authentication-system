// lib/features/owners/owners_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/supabase_service.dart';
import '../../models/owner_model.dart';
import 'add_owner_screen.dart';
import 'widgets/owner_card.dart';

class OwnersScreen extends StatefulWidget {
  const OwnersScreen({super.key});

  @override
  State<OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<OwnersScreen> {
  final _supabase = SupabaseService();
  List<OwnerModel> _owners = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  Future<void> _loadOwners() async {
    setState(() => _loading = true);
    try {
      final owners = await _supabase.fetchOwners();
      if (mounted)
        setState(() {
          _owners = owners;
          _loading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteOwner(OwnerModel owner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text(
          'Remove Owner',
          style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary),
        ),
        content: Text(
          'Remove ${owner.name} from the system?',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Remove',
              style: GoogleFonts.inter(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _supabase.deleteOwner(owner.id!);
      _loadOwners();
    }
  }

  Future<void> _navigateToAdd() async {
    final added = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddOwnerScreen()));
    if (added == true) _loadOwners();
  }

  Future<void> _navigateToEdit(OwnerModel owner) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddOwnerScreen(existingOwner: owner)),
    );
    if (updated == true) _loadOwners();
  }

  double get _syncHealth {
    if (_owners.isEmpty) return 100;
    final active = _owners.where((o) => o.isActive).length;
    return (active / _owners.length * 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.shield, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'High-Tech Sentinel',
              style: GoogleFonts.spaceGrotesk(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentBlue,
              ),
              child: const Icon(
                Icons.person_add,
                color: Colors.white,
                size: 18,
              ),
            ),
            onPressed: _owners.length >= AppConstants.maxOwners
                ? null
                : _navigateToAdd,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bgCard,
        onRefresh: _loadOwners,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Owners',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Authorized personnel with biometric clearance.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 24),

                  // Owner list
                  if (_loading)
                    ..._buildShimmer()
                  else if (_owners.isEmpty)
                    _buildEmpty()
                  else
                    ..._owners.asMap().entries.map((entry) {
                      return OwnerCard(
                            owner: entry.value,
                            onEdit: () => _navigateToEdit(entry.value),
                            onDelete: () => _deleteOwner(entry.value),
                          )
                          .animate()
                          .fadeIn(delay: (100 + entry.key * 80).ms)
                          .slideY(begin: 0.1);
                    }),

                  const SizedBox(height: 24),

                  // System capacity
                  _buildCapacitySection().animate().fadeIn(delay: 500.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              'SYSTEM CAPACITY',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_owners.length.toString().padLeft(2, '0')}/${AppConstants.maxOwners}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'ACTIVE SLOTS',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 48, color: AppColors.bgCardLight),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_syncHealth.toStringAsFixed(0)}%',
                    style: GoogleFonts.spaceMono(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'SYNC HEALTH',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildShimmer() {
    return List.generate(
      3,
      (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.people_outline,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No owners yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _navigateToAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
              ),
              child: Text(
                'Add First Owner',
                style: GoogleFonts.spaceGrotesk(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
