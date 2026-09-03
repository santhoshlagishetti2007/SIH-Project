class DressCode {
  final String general;
  final String religiousSites;
  final String nightlife;

  const DressCode({
    this.general = 'Comfortable modest casuals.',
    this.religiousSites = 'Cover shoulders and knees. Remove footwear before entering sanctums.',
    this.nightlife = 'Smart casuals.',
  });

  factory DressCode.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DressCode();
    return DressCode(
      general: json['general'] as String? ?? 'Comfortable modest casuals.',
      religiousSites: json['religiousSites'] as String? ?? 'Cover shoulders and knees.',
      nightlife: json['nightlife'] as String? ?? 'Smart casuals.',
    );
  }
}

class TippingNorms {
  final String restaurants;
  final String autosCabs;
  final String guidesDrivers;
  final String hotelStaff;

  const TippingNorms({
    this.restaurants = '7% - 10% for good service.',
    this.autosCabs = 'Round up fare or ₹20 - ₹50.',
    this.guidesDrivers = '₹300 - ₹600/day for tour guides.',
    this.hotelStaff = '₹50 - ₹100 for luggage assistance.',
  });

  factory TippingNorms.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TippingNorms();
    return TippingNorms(
      restaurants: json['restaurants'] as String? ?? '7% - 10%',
      autosCabs: json['autosCabs'] as String? ?? 'Round up fare',
      guidesDrivers: json['guidesDrivers'] as String? ?? '₹300 - ₹600/day',
      hotelStaff: json['hotelStaff'] as String? ?? '₹50 - ₹100',
    );
  }
}

class CommonScam {
  final String name;
  final String warning;
  final String preventionTip;

  const CommonScam({
    required this.name,
    required this.warning,
    required this.preventionTip,
  });

  factory CommonScam.fromJson(Map<String, dynamic> json) {
    return CommonScam(
      name: json['name'] as String? ?? '',
      warning: json['warning'] as String? ?? '',
      preventionTip: json['preventionTip'] as String? ?? '',
    );
  }
}

class DestinationCustoms {
  final String destination;
  final String region;
  final DressCode dressCode;
  final List<String> templeEtiquette;
  final TippingNorms tippingNorms;
  final List<CommonScam> commonScams;
  final List<String> dos;
  final List<String> donts;
  final List<String> localCustoms;

  const DestinationCustoms({
    required this.destination,
    this.region = 'India',
    this.dressCode = const DressCode(),
    this.templeEtiquette = const [],
    this.tippingNorms = const TippingNorms(),
    this.commonScams = const [],
    this.dos = const [],
    this.donts = const [],
    this.localCustoms = const [],
  });

  factory DestinationCustoms.fromJson(Map<String, dynamic> json) {
    return DestinationCustoms(
      destination: json['destination'] as String? ?? 'Jaipur',
      region: json['region'] as String? ?? 'India',
      dressCode: DressCode.fromJson(json['dressCode'] as Map<String, dynamic>?),
      templeEtiquette: (json['templeEtiquette'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tippingNorms: TippingNorms.fromJson(json['tippingNorms'] as Map<String, dynamic>?),
      commonScams: (json['commonScams'] as List<dynamic>?)
              ?.map((e) => CommonScam.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dos: (json['dos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      donts: (json['donts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      localCustoms: (json['localCustoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
