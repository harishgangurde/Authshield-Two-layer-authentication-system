// lib/models/alert_model.dart

enum AlertType {
  failedAuth,
  unrecognizedSubject,
  invalidKeypad,
  multipleFailures,
  motionDetected,
}

class AlertModel {
  final String? id;
  final AlertType type;
  final String title;
  final String deviceId;
  final String? imageUrl;
  final DateTime timestamp;
  final bool dismissed;
  final bool lockoutInitiated;
  final String cameraId;

  AlertModel({
    this.id,
    required this.type,
    required this.title,
    required this.deviceId,
    this.imageUrl,
    required this.timestamp,
    this.dismissed = false,
    this.lockoutInitiated = false,
    this.cameraId = 'CAM_01_ENTRY',
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id']?.toString(),
      type: _parseType(json['type'] ?? ''),
      title: json['title'] ?? 'Unknown Alert',
      deviceId: json['device_id'] ?? 'HUB-01',
      imageUrl: json['image_url'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      dismissed: json['dismissed'] ?? false,
      lockoutInitiated: json['lockout_initiated'] ?? false,
      cameraId: json['camera_id'] ?? 'CAM_01_ENTRY',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type.name,
      'title': title,
      'device_id': deviceId,
      'image_url': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'dismissed': dismissed,
      'lockout_initiated': lockoutInitiated,
      'camera_id': cameraId,
    };
  }

  static AlertType _parseType(String value) {
    switch (value) {
      case 'unrecognizedSubject':
        return AlertType.unrecognizedSubject;
      case 'invalidKeypad':
        return AlertType.invalidKeypad;
      case 'multipleFailures':
        return AlertType.multipleFailures;
      case 'motionDetected':
        return AlertType.motionDetected;
      default:
        return AlertType.failedAuth;
    }
  }

  String get typeLabel {
    switch (type) {
      case AlertType.unrecognizedSubject:
        return 'FAILED AUTHENTICATION';
      case AlertType.invalidKeypad:
        return 'FAILED AUTHENTICATION';
      case AlertType.multipleFailures:
        return 'FAILED AUTHENTICATION';
      case AlertType.motionDetected:
        return 'MOTION DETECTED';
      default:
        return 'FAILED AUTHENTICATION';
    }
  }

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final amPm = timestamp.hour >= 12 ? 'PM' : 'AM';
    final hour12 = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Alert at $hour12:$m $amPm, ${months[timestamp.month - 1]} ${timestamp.day}th';
  }
}
