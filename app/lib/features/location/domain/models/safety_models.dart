class LiveLocationData {
  final double lat;
  final double lng;
  final double accuracy;
  final double speed;
  final int battery;
  final String address;

  const LiveLocationData({
    required this.lat,
    required this.lng,
    this.accuracy = 10,
    this.speed = 0,
    this.battery = 85,
    this.address = 'Pink City, Jaipur',
  });

  factory LiveLocationData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LiveLocationData(lat: 26.9124, lng: 75.7873);
    return LiveLocationData(
      lat: (json['lat'] as num?)?.toDouble() ?? 26.9124,
      lng: (json['lng'] as num?)?.toDouble() ?? 75.7873,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 10.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      battery: (json['battery'] as num?)?.toInt() ?? 85,
      address: json['address'] as String? ?? 'Live Location',
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'accuracy': accuracy,
    'speed': speed,
    'battery': battery,
    'address': address,
  };
}

class SosNotificationLog {
  final String contactName;
  final String contactPhone;
  final String message;
  final String status;

  const SosNotificationLog({
    required this.contactName,
    required this.contactPhone,
    required this.message,
    this.status = 'dispatched',
  });

  factory SosNotificationLog.fromJson(Map<String, dynamic> json) {
    return SosNotificationLog(
      contactName: json['contactName'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'dispatched',
    );
  }
}

class SosTriggerResult {
  final bool success;
  final String sessionId;
  final String trackingUrl;
  final String publicTrackingUrl;
  final String googleMapsUrl;
  final int contactsNotifiedCount;
  final List<SosNotificationLog> notifications;
  final String emergencyHelpline;

  const SosTriggerResult({
    required this.success,
    required this.sessionId,
    required this.trackingUrl,
    required this.publicTrackingUrl,
    required this.googleMapsUrl,
    required this.contactsNotifiedCount,
    this.notifications = const [],
    this.emergencyHelpline = '112',
  });

  factory SosTriggerResult.fromJson(Map<String, dynamic> json) {
    final list = json['notifications'] as List<dynamic>? ?? [];
    return SosTriggerResult(
      success: json['success'] as bool? ?? true,
      sessionId: json['sessionId'] as String? ?? '',
      trackingUrl: json['trackingUrl'] as String? ?? '',
      publicTrackingUrl: json['publicTrackingUrl'] as String? ?? '',
      googleMapsUrl: json['googleMapsUrl'] as String? ?? '',
      contactsNotifiedCount: (json['contactsNotifiedCount'] as num?)?.toInt() ?? 0,
      notifications: list.map((e) => SosNotificationLog.fromJson(e as Map<String, dynamic>)).toList(),
      emergencyHelpline: json['emergencyHelpline'] as String? ?? '112',
    );
  }
}
