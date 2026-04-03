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
          ? (DateTime.tryParse(json['timestamp']) ?? DateTime.now()).toLocal()
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

  bool get isCritical {
    return type == AlertType.unrecognizedSubject ||
        type == AlertType.failedAuth ||
        type == AlertType.multipleFailures;
  }

  String get formattedTime {
    final localTime = timestamp.toLocal();

    final m = localTime.minute.toString().padLeft(2, '0');
    final amPm = localTime.hour >= 12 ? 'PM' : 'AM';
    final hour12 = localTime.hour == 0
        ? 12
        : localTime.hour > 12
            ? localTime.hour - 12
            : localTime.hour;

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

    String getDaySuffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    return 'Alert at $hour12:$m $amPm, ${months[localTime.month - 1]} ${localTime.day}${getDaySuffix(localTime.day)}';
  }
}
