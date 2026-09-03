class TransportAdvice {
  final String general;
  final String nightTransit;
  final List<String> recommendedApps;
  final String verifiedCabs;

  const TransportAdvice({
    this.general = '',
    this.nightTransit = '',
    this.recommendedApps = const ['Uber', 'Ola'],
    this.verifiedCabs = '',
  });

  factory TransportAdvice.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TransportAdvice();
    return TransportAdvice(
      general: json['general'] as String? ?? '',
      nightTransit: json['nightTransit'] as String? ?? '',
      recommendedApps: (json['recommendedApps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const ['Uber', 'Ola'],
      verifiedCabs: json['verifiedCabs'] as String? ?? '',
    );
  }
}

class EmergencyNumbers {
  final String nationalHelpline;
  final String womenHelpline;
  final String womenHelplineAlt;
  final String policeHelpline;
  final String ambulance;
  final String touristHelpline;

  const EmergencyNumbers({
    this.nationalHelpline = '112',
    this.womenHelpline = '1091',
    this.womenHelplineAlt = '181',
    this.policeHelpline = '100',
    this.ambulance = '108',
    this.touristHelpline = '1363',
  });

  factory EmergencyNumbers.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EmergencyNumbers();
    return EmergencyNumbers(
      nationalHelpline: json['nationalHelpline'] as String? ?? '112',
      womenHelpline: json['womenHelpline'] as String? ?? '1091',
      womenHelplineAlt: json['womenHelplineAlt'] as String? ?? '181',
      policeHelpline: json['policeHelpline'] as String? ?? '100',
      ambulance: json['ambulance'] as String? ?? '108',
      touristHelpline: json['touristHelpline'] as String? ?? '1363',
    );
  }
}

class WomensSafetyGuide {
  final String city;
  final List<String> safeAreas;
  final List<String> cautionAreas;
  final TransportAdvice transportAdvice;
  final EmergencyNumbers emergencyNumbers;
  final List<String> localTips;

  const WomensSafetyGuide({
    required this.city,
    this.safeAreas = const [],
    this.cautionAreas = const [],
    this.transportAdvice = const TransportAdvice(),
    this.emergencyNumbers = const EmergencyNumbers(),
    this.localTips = const [],
  });

  factory WomensSafetyGuide.fromJson(Map<String, dynamic> json) {
    return WomensSafetyGuide(
      city: json['city'] as String? ?? 'Jaipur',
      safeAreas: (json['safeAreas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      cautionAreas: (json['cautionAreas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      transportAdvice: TransportAdvice.fromJson(json['transportAdvice'] as Map<String, dynamic>?),
      emergencyNumbers: EmergencyNumbers.fromJson(json['emergencyNumbers'] as Map<String, dynamic>?),
      localTips: (json['localTips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class EmergencyStation {
  final String id;
  final String name;
  final String type; // police or hospital
  final String address;
  final String phone;
  final String helpline;
  final String distanceText;
  final double lat;
  final double lng;
  final bool isOpen24Hours;

  const EmergencyStation({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    this.helpline = '112',
    required this.distanceText,
    required this.lat,
    required this.lng,
    this.isOpen24Hours = true,
  });

  factory EmergencyStation.fromJson(Map<String, dynamic> json) {
    return EmergencyStation(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'police',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      helpline: json['helpline'] as String? ?? '112',
      distanceText: json['distanceText'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 26.9124,
      lng: (json['lng'] as num?)?.toDouble() ?? 75.7873,
      isOpen24Hours: json['isOpen24Hours'] as bool? ?? true,
    );
  }
}

class WomenVerifiedListing {
  final String id;
  final String name;
  final String type; // stay or guide
  final String city;
  final String address;
  final double price;
  final double rating;
  final int reviewsCount;
  final bool isWomenVerified;
  final List<String> safetyBadges;
  final String photo;
  final String phone;
  final String description;

  const WomenVerifiedListing({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    this.address = '',
    this.price = 0,
    this.rating = 4.9,
    this.reviewsCount = 100,
    this.isWomenVerified = true,
    this.safetyBadges = const [],
    this.photo = '',
    this.phone = '',
    this.description = '',
  });

  factory WomenVerifiedListing.fromJson(Map<String, dynamic> json) {
    return WomenVerifiedListing(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'stay',
      city: json['city'] as String? ?? 'Jaipur',
      address: json['address'] as String? ?? '',
      price: (json['pricePerNight'] as num?)?.toDouble() ?? (json['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 100,
      isWomenVerified: json['isWomenVerified'] as bool? ?? true,
      safetyBadges: (json['safetyBadges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      photo: json['photo'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
