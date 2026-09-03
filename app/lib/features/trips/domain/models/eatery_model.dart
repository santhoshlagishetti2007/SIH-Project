import 'trip_model.dart';

/// Authentic local eatery recommendation near an itinerary stop
class NearbyEatery {
  final String id;
  final String placeId;
  final String name;
  final String cuisineType;
  final String description;
  final double rating;
  final int userRatingsTotal;
  final String priceLevel; // '₹', '₹₹', '₹₹₹'
  final int priceLevelNum;
  final double estimatedCost;
  final int distanceMeters;
  final double distanceKm;
  final String address;
  final LocationData location;
  final String photoUrl;
  final bool openNow;
  final List<String> specialties;

  const NearbyEatery({
    required this.id,
    required this.placeId,
    required this.name,
    this.cuisineType = 'Regional Authentic Dining',
    this.description = '',
    this.rating = 4.5,
    this.userRatingsTotal = 250,
    this.priceLevel = '₹₹',
    this.priceLevelNum = 2,
    this.estimatedCost = 400.0,
    this.distanceMeters = 500,
    this.distanceKm = 0.5,
    this.address = '',
    this.location = const LocationData(),
    this.photoUrl = '',
    this.openNow = true,
    this.specialties = const [],
  });

  factory NearbyEatery.fromJson(Map<String, dynamic> json) {
    return NearbyEatery(
      id: json['id'] as String? ?? json['placeId'] as String? ?? '',
      placeId: json['placeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      cuisineType: json['cuisineType'] as String? ?? 'Regional Authentic Dining',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      userRatingsTotal: (json['userRatingsTotal'] as num?)?.toInt() ?? 250,
      priceLevel: json['priceLevel'] as String? ?? '₹₹',
      priceLevelNum: (json['priceLevelNum'] as num?)?.toInt() ?? 2,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 400.0,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 500,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.5,
      address: json['address'] as String? ?? '',
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : const LocationData(),
      photoUrl: json['photoUrl'] as String? ?? '',
      openNow: json['openNow'] as bool? ?? true,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'name': name,
      'cuisineType': cuisineType,
      'description': description,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'priceLevel': priceLevel,
      'priceLevelNum': priceLevelNum,
      'estimatedCost': estimatedCost,
      'distanceMeters': distanceMeters,
      'distanceKm': distanceKm,
      'address': address,
      'location': location.toJson(),
      'photoUrl': photoUrl,
      'openNow': openNow,
      'specialties': specialties,
    };
  }
}
