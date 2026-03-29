// lib/core/services/supabase_service.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../../models/owner_model.dart';
import '../../models/alert_model.dart';
import '../../models/log_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  // ── OWNERS ─────────────────────────────────────────────────────────────────
  Future<List<OwnerModel>> fetchOwners() async {
    final response = await client
        .from(AppConstants.ownersTable)
        .select()
        .order('created_at', ascending: true);
    return (response as List).map((e) => OwnerModel.fromJson(e)).toList();
  }

  Future<OwnerModel> addOwner(OwnerModel owner) async {
    final response = await client
        .from(AppConstants.ownersTable)
        .insert(owner.toJson())
        .select()
        .single();
    return OwnerModel.fromJson(response);
  }

  Future<void> updateOwner(OwnerModel owner) async {
    await client
        .from(AppConstants.ownersTable)
        .update(owner.toJson())
        .eq('id', owner.id!);
  }

  Future<void> deleteOwner(String ownerId) async {
    await client.from(AppConstants.ownersTable).delete().eq('id', ownerId);
  }

  Future<String?> uploadOwnerImage(String ownerId, File imageFile) async {
    final fileName = '$ownerId/profile.jpg';
    await client.storage
        .from(AppConstants.ownerImagesBucket)
        .upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage
        .from(AppConstants.ownerImagesBucket)
        .getPublicUrl(fileName);
  }

  // ── ALERTS ─────────────────────────────────────────────────────────────────
  Future<List<AlertModel>> fetchAlerts({int limit = 20}) async {
    final response = await client
        .from(AppConstants.alertsTable)
        .select()
        .order('timestamp', ascending: false)
        .limit(limit);
    return (response as List).map((e) => AlertModel.fromJson(e)).toList();
  }

  Future<void> dismissAlert(String alertId) async {
    await client
        .from(AppConstants.alertsTable)
        .update({'dismissed': true})
        .eq('id', alertId);
  }

  Future<void> clearAllAlerts() async {
    await client
        .from(AppConstants.alertsTable)
        .update({'dismissed': true})
        .eq('dismissed', false);
  }

  Future<void> initiateLockout(String alertId) async {
    await client
        .from(AppConstants.alertsTable)
        .update({'lockout_initiated': true})
        .eq('id', alertId);
    await addLog(
      LogModel(
        action: 'Lockout Initiated',
        deviceId: AppConstants.defaultDeviceId,
        status: LogStatus.manual,
        timestamp: DateTime.now(),
      ),
    );
  }

  // ── LOGS ───────────────────────────────────────────────────────────────────
  Future<List<LogModel>> fetchLogs({
    int limit = 30,
    DateTime? fromDate,
    DateTime? toDate,
    LogStatus? status,
  }) async {
    final response = await client
        .from(AppConstants.logsTable)
        .select()
        .order('timestamp', ascending: false)
        .limit(limit);

    var logs = (response as List).map((e) => LogModel.fromJson(e)).toList();

    if (fromDate != null) {
      logs = logs.where((l) => l.timestamp.isAfter(fromDate)).toList();
    }
    if (toDate != null) {
      logs = logs.where((l) => l.timestamp.isBefore(toDate)).toList();
    }
    if (status != null) {
      logs = logs.where((l) => l.status == status).toList();
    }

    return logs;
  }

  Future<void> addLog(LogModel log) async {
    await client.from(AppConstants.logsTable).insert(log.toJson());
  }

  Future<LogModel?> fetchLastAlert() async {
    final response = await client
        .from(AppConstants.logsTable)
        .select()
        .eq('status', 'failure')
        .order('timestamp', ascending: false)
        .limit(1)
        .maybeSingle();
    return response != null ? LogModel.fromJson(response) : null;
  }

  // ── REALTIME ───────────────────────────────────────────────────────────────
  RealtimeChannel subscribeToAlerts(Function(AlertModel) onNewAlert) {
    return client
        .channel(AppConstants.alertsChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppConstants.alertsTable,
          callback: (payload) =>
              onNewAlert(AlertModel.fromJson(payload.newRecord)),
        )
        .subscribe();
  }

  RealtimeChannel subscribeToLogs(Function(LogModel) onNewLog) {
    return client
        .channel(AppConstants.logsChannel)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppConstants.logsTable,
          callback: (payload) => onNewLog(LogModel.fromJson(payload.newRecord)),
        )
        .subscribe();
  }

  // ── DASHBOARD STATS ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final ownersRes = await client.from(AppConstants.ownersTable).select('id');
    final alertsRes = await client
        .from(AppConstants.alertsTable)
        .select('id')
        .eq('dismissed', false);
    final lastAlert = await fetchLastAlert();

    return {
      'ownerCount': (ownersRes as List).length,
      'activeAlerts': (alertsRes as List).length,
      'lastAlert': lastAlert,
    };
  }

  Future<List<LogModel>> fetchRecentLogs({int limit = 3}) async {
    final response = await client
        .from(AppConstants.logsTable)
        .select()
        .order('timestamp', ascending: false)
        .limit(limit);
    return (response as List).map((e) => LogModel.fromJson(e)).toList();
  }

  Future<void> logManualUnlock(String deviceId) async {
    await addLog(
      LogModel(
        action: 'Manual Unlock',
        deviceId: deviceId,
        status: LogStatus.manual,
        timestamp: DateTime.now(),
      ),
    );
  }
}
