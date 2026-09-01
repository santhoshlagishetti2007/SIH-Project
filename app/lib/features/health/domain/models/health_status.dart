/// Domain entity representing health check information returned by the backend
class HealthStatus {
  final String service;
  final String version;
  final String status;
  final int uptimeSeconds;
  final String uptimeHuman;
  final String environment;
  final DateTime serverTime;
  final String databaseStatus;
  final String firebaseStatus;
  final bool googleAiConfigured;
  final int latencyMs;

  const HealthStatus({
    required this.service,
    required this.version,
    required this.status,
    required this.uptimeSeconds,
    required this.uptimeHuman,
    required this.environment,
    required this.serverTime,
    required this.databaseStatus,
    required this.firebaseStatus,
    required this.googleAiConfigured,
    required this.latencyMs,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json, {int latencyMs = 0}) {
    final services = json['services'] as Map<String, dynamic>? ?? {};
    final dbObj = services['database'] as Map<String, dynamic>? ?? {};
    final fbObj = services['firebase'] as Map<String, dynamic>? ?? {};
    final aiObj = services['googleAI'] as Map<String, dynamic>? ?? {};

    return HealthStatus(
      service: json['service']?.toString() ?? 'sanchari-backend',
      version: json['version']?.toString() ?? '1.0.0',
      status: json['status']?.toString() ?? 'healthy',
      uptimeSeconds: json['uptimeSeconds'] is int ? json['uptimeSeconds'] as int : 0,
      uptimeHuman: json['uptimeHuman']?.toString() ?? '0s',
      environment: json['environment']?.toString() ?? 'development',
      serverTime: json['serverTime'] != null
          ? DateTime.tryParse(json['serverTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      databaseStatus: dbObj['status']?.toString() ?? 'unknown',
      firebaseStatus: fbObj['status']?.toString() ?? 'unconfigured',
      googleAiConfigured: aiObj['isConfigured'] == true,
      latencyMs: latencyMs,
    );
  }

  bool get isHealthy => status.toLowerCase() == 'healthy';
}
