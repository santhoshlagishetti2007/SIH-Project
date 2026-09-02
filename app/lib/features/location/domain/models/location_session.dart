/// Domain entity representing a realtime companion location sharing session
class LocationSession {
  final String sessionId;
  final String hostUserId;
  final String sessionName;
  final bool isActive;
  final double currentLatitude;
  final double currentLongitude;
  final DateTime updatedAt;

  const LocationSession({
    required this.sessionId,
    required this.hostUserId,
    required this.sessionName,
    required this.isActive,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.updatedAt,
  });

  factory LocationSession.fromJson(Map<String, dynamic> json) {
    return LocationSession(
      sessionId: json['sessionId']?.toString() ?? '',
      hostUserId: json['hostUserId']?.toString() ?? '',
      sessionName: json['sessionName']?.toString() ?? '',
      isActive: json['isActive'] == true,
      currentLatitude: json['currentLatitude'] is num
          ? (json['currentLatitude'] as num).toDouble()
          : 0.0,
      currentLongitude: json['currentLongitude'] is num
          ? (json['currentLongitude'] as num).toDouble()
          : 0.0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'hostUserId': hostUserId,
      'sessionName': sessionName,
      'isActive': isActive,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
