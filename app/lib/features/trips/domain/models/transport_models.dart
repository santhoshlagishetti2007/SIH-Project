/// Single Mode Option for a transit leg
class TransitModeOption {
  final String mode; // 'walk', 'auto', 'bus', 'metro', 'cab'
  final String label;
  final String icon;
  final double cost;
  final int durationMinutes;
  final bool isAvailable;
  final bool isRecommended;
  final String description;

  const TransitModeOption({
    required this.mode,
    required this.label,
    required this.icon,
    required this.cost,
    required this.durationMinutes,
    this.isAvailable = true,
    this.isRecommended = false,
    this.description = '',
  });

  factory TransitModeOption.fromJson(Map<String, dynamic> json) {
    return TransitModeOption(
      mode: json['mode'] as String? ?? 'auto',
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 15,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isRecommended: json['isRecommended'] as bool? ?? false,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'label': label,
      'icon': icon,
      'cost': cost,
      'durationMinutes': durationMinutes,
      'isAvailable': isAvailable,
      'isRecommended': isRecommended,
      'description': description,
    };
  }

  TransitModeOption copyWith({
    String? mode,
    String? label,
    String? icon,
    double? cost,
    int? durationMinutes,
    bool? isAvailable,
    bool? isRecommended,
    String? description,
  }) {
    return TransitModeOption(
      mode: mode ?? this.mode,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      cost: cost ?? this.cost,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isAvailable: isAvailable ?? this.isAvailable,
      isRecommended: isRecommended ?? this.isRecommended,
      description: description ?? this.description,
    );
  }
}

/// Transit Leg between two consecutive itinerary stops
class TransitLeg {
  final String fromStopId;
  final String toStopId;
  final String fromStopName;
  final String toStopName;
  final double distanceKm;
  final int durationMinutes;
  final String selectedMode; // 'walk', 'auto', 'bus', 'metro', 'cab'
  final double estimatedCost;
  final List<TransitModeOption> modes;

  const TransitLeg({
    required this.fromStopId,
    required this.toStopId,
    this.fromStopName = '',
    this.toStopName = '',
    this.distanceKm = 0.0,
    this.durationMinutes = 15,
    this.selectedMode = 'auto',
    this.estimatedCost = 0.0,
    this.modes = const [],
  });

  factory TransitLeg.fromJson(Map<String, dynamic> json) {
    return TransitLeg(
      fromStopId: json['fromStopId'] as String? ?? '',
      toStopId: json['toStopId'] as String? ?? '',
      fromStopName: json['fromStopName'] as String? ?? '',
      toStopName: json['toStopName'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 15,
      selectedMode: json['selectedMode'] as String? ?? 'auto',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      modes: (json['modes'] as List<dynamic>?)
              ?.map((e) => TransitModeOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromStopId': fromStopId,
      'toStopId': toStopId,
      'fromStopName': fromStopName,
      'toStopName': toStopName,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'selectedMode': selectedMode,
      'estimatedCost': estimatedCost,
      'modes': modes.map((m) => m.toJson()).toList(),
    };
  }

  TransitLeg copyWith({
    String? fromStopId,
    String? toStopId,
    String? fromStopName,
    String? toStopName,
    double? distanceKm,
    int? durationMinutes,
    String? selectedMode,
    double? estimatedCost,
    List<TransitModeOption>? modes,
  }) {
    return TransitLeg(
      fromStopId: fromStopId ?? this.fromStopId,
      toStopId: toStopId ?? this.toStopId,
      fromStopName: fromStopName ?? this.fromStopName,
      toStopName: toStopName ?? this.toStopName,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      selectedMode: selectedMode ?? this.selectedMode,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      modes: modes ?? this.modes,
    );
  }

  /// Helper to select a new mode and compute the updated leg
  TransitLeg withSelectedMode(String newMode) {
    final matchedOption = modes.firstWhere(
      (m) => m.mode == newMode,
      orElse: () => TransitModeOption(
        mode: newMode,
        label: newMode,
        icon: '',
        cost: estimatedCost,
        durationMinutes: durationMinutes,
      ),
    );

    return copyWith(
      selectedMode: newMode,
      estimatedCost: matchedOption.cost,
      durationMinutes: matchedOption.durationMinutes,
    );
  }
}

/// Mode Rate parameters for admin configuration
class ModeRateConfig {
  final double baseFare;
  final double perKmRate;
  final double minFare;
  final double speedKmh;
  final bool isAvailable;
  final String notes;

  const ModeRateConfig({
    required this.baseFare,
    required this.perKmRate,
    this.minFare = 0.0,
    this.speedKmh = 20.0,
    this.isAvailable = true,
    this.notes = '',
  });

  factory ModeRateConfig.fromJson(Map<String, dynamic> json) {
    return ModeRateConfig(
      baseFare: (json['baseFare'] as num?)?.toDouble() ?? 0.0,
      perKmRate: (json['perKmRate'] as num?)?.toDouble() ?? 0.0,
      minFare: (json['minFare'] as num?)?.toDouble() ?? 0.0,
      speedKmh: (json['speedKmh'] as num?)?.toDouble() ?? 20.0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFare': baseFare,
      'perKmRate': perKmRate,
      'minFare': minFare,
      'speedKmh': speedKmh,
      'isAvailable': isAvailable,
      'notes': notes,
    };
  }

  ModeRateConfig copyWith({
    double? baseFare,
    double? perKmRate,
    double? minFare,
    double? speedKmh,
    bool? isAvailable,
    String? notes,
  }) {
    return ModeRateConfig(
      baseFare: baseFare ?? this.baseFare,
      perKmRate: perKmRate ?? this.perKmRate,
      minFare: minFare ?? this.minFare,
      speedKmh: speedKmh ?? this.speedKmh,
      isAvailable: isAvailable ?? this.isAvailable,
      notes: notes ?? this.notes,
    );
  }
}

/// City Transport Rate Configuration stored in MongoDB
class CityTransportRateConfig {
  final String id;
  final String city;
  final String currency;
  final bool isActive;
  final Map<String, ModeRateConfig> modes;

  const CityTransportRateConfig({
    this.id = '',
    required this.city,
    this.currency = 'INR',
    this.isActive = true,
    this.modes = const {},
  });

  factory CityTransportRateConfig.fromJson(Map<String, dynamic> json) {
    final rawModes = json['modes'] as Map<String, dynamic>? ?? {};
    final parsedModes = <String, ModeRateConfig>{};

    rawModes.forEach((key, val) {
      if (val is Map<String, dynamic>) {
        parsedModes[key] = ModeRateConfig.fromJson(val);
      }
    });

    return CityTransportRateConfig(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      city: json['city'] as String? ?? 'Default',
      currency: json['currency'] as String? ?? 'INR',
      isActive: json['isActive'] as bool? ?? true,
      modes: parsedModes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'currency': currency,
      'isActive': isActive,
      'modes': modes.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}
