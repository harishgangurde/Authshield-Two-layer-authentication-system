// lib/models/log_model.dart

enum LogStatus { success, failure, manual }

class LogModel {
  final String? id;
  final String action;
  final String deviceId;
  final LogStatus status;
  final DateTime timestamp;
  final String? ownerName;

  LogModel({
    this.id,
    required this.action,
    required this.deviceId,
    required this.status,
    required this.timestamp,
    this.ownerName,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id']?.toString(),
      action: json['action'] ?? '',
      deviceId: json['device_id'] ?? 'UNKNOWN',
      status: _parseStatus(json['status'] ?? ''),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      ownerName: json['owner_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'action': action,
      'device_id': deviceId,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'owner_name': ownerName,
    };
  }

  static LogStatus _parseStatus(String value) {
    switch (value) {
      case 'failure':
        return LogStatus.failure;
      case 'manual':
        return LogStatus.manual;
      default:
        return LogStatus.success;
    }
  }

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get formattedDate {
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
    return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
  }

  String get statusLabel {
    switch (status) {
      case LogStatus.success:
        return 'SUCCESS';
      case LogStatus.failure:
        return 'FAILURE';
      case LogStatus.manual:
        return 'MANUAL';
    }
  }
}
