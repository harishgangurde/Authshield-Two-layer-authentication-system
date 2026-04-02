import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/supabase_service.dart';
import '../../models/owner_model.dart';

class AddOwnerScreen extends StatefulWidget {
  final OwnerModel? existingOwner;
  const AddOwnerScreen({super.key, this.existingOwner});

  @override
  State<AddOwnerScreen> createState() => _AddOwnerScreenState();
}

class _AddOwnerScreenState extends State<AddOwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _supabase = SupabaseService();
  final _picker = ImagePicker();

  File? _imageFile;
  String? _existingImageUrl;
  bool _saving = false;
  bool get _isEditing => widget.existingOwner != null;

  static const List<String> _rolePresets = [
    'Primary Admin',
    'Hardware Manager',
    'Security Auditor',
    'Access Control',
    'Guest',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingOwner!.name;
      _roleController.text = widget.existingOwner!.role;
      _existingImageUrl = widget.existingOwner!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
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
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text(
                'Camera',
                style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.accentBlue,
              ),
              title: Text(
                'Gallery',
                style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final xFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 800,
      );

      if (xFile != null && mounted) {
        setState(() => _imageFile = File(xFile.path));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.warning,
          content: Text(
            'Please add a face image for owner registration',
            style: GoogleFonts.inter(color: Colors.black),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final id = _isEditing ? widget.existingOwner!.id! : const Uuid().v4();
      String? imageUrl = _existingImageUrl;

      if (_imageFile != null) {
        imageUrl = await _supabase.uploadOwnerImage(id, _imageFile!);
      }

      final owner = OwnerModel(
        id: id,
        name: _nameController.text.trim(),
        role: _roleController.text.trim(),
        imageUrl: imageUrl,
        isActive: true,
        faceEmbedding: null,
      );

      if (_isEditing) {
        await _supabase.updateOwner(owner);
      } else {
        await _supabase.addOwner(owner);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text(
              _isEditing
                  ? 'Owner updated successfully'
                  : 'Owner added successfully',
              style: GoogleFonts.inter(color: Colors.black),
            ),
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Owner' : 'Add Owner',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgCard,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(55),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : _existingImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(55),
                                  child: Image.network(
                                    _existingImageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: AppColors.textMuted,
                                  size: 48,
                                ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Add clear face photo',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ).animate().fadeIn(delay: 120.ms),
            const SizedBox(height: 32),
            _buildLabel('FULL NAME'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary),
              decoration: _inputDecoration('e.g. Harshada'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 20),
            _buildLabel('ROLE / CLEARANCE'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _roleController,
              style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary),
              decoration: _inputDecoration('e.g. Admin'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Role is required' : null,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _rolePresets.map((r) {
                return GestureDetector(
                  onTap: () => setState(() => _roleController.text = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _roleController.text == r
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _roleController.text == r
                            ? AppColors.primary.withOpacity(0.4)
                            : AppColors.bgCardLight,
                      ),
                    ),
                    child: Text(
                      r,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _roleController.text == r
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditing ? 'SAVE CHANGES' : 'ADD OWNER',
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.spaceMono(
        fontSize: 10,
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bgCardLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bgCardLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
