// lib/models/owner_model.dart

class OwnerModel {
  final String? id;
  final String name;
  final String role;
  final String? imageUrl;
  final bool isActive;
  final DateTime? createdAt;
  final String? faceEmbedding; // stored face data for recognition

  OwnerModel({
    this.id,
    required this.name,
    required this.role,
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
    this.faceEmbedding,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      role: json['role'] ?? 'Member',
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      faceEmbedding: json['face_embedding'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'role': role,
      'image_url': imageUrl,
      'is_active': isActive,
      'face_embedding': faceEmbedding,
    };
  }

  OwnerModel copyWith({
    String? id,
    String? name,
    String? role,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    String? faceEmbedding,
  }) {
    return OwnerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      faceEmbedding: faceEmbedding ?? this.faceEmbedding,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
