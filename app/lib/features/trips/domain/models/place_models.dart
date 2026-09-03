import 'trip_model.dart';

/// Place Alternative recommendation model for "Swap this stop"
class PlaceAlternative {
  final String id;
  final String placeId;
  final String name;
  final String category;
  final String costCategory;
  final String description;
  final double rating;
  final int userRatingsTotal;
  final double cost;
  final int durationMinutes;
  final LocationData location;
  final String imageUrl;
  final String swapReason;

  const PlaceAlternative({
    required this.id,
    required this.placeId,
    required this.name,
    this.category = 'attraction',
    this.costCategory = 'activities',
    this.description = '',
    this.rating = 4.5,
    this.userRatingsTotal = 100,
    this.cost = 0.0,
    this.durationMinutes = 90,
    this.location = const LocationData(),
    this.imageUrl = '',
    this.swapReason = '',
  });

  factory PlaceAlternative.fromJson(Map<String, dynamic> json) {
    return PlaceAlternative(
      id: json['id'] as String? ?? json['placeId'] as String? ?? '',
      placeId: json['placeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'attraction',
      costCategory: json['costCategory'] as String? ?? 'activities',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      userRatingsTotal: (json['userRatingsTotal'] as num?)?.toInt() ?? 100,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 90,
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : const LocationData(),
      imageUrl: json['imageUrl'] as String? ?? '',
      swapReason: json['swapReason'] as String? ?? '',
    );
  }
}

/// Place Autocomplete Prediction for "Add custom stop"
class PlaceAutocompletePrediction {
  final String placeId;
  final String name;
  final String address;
  final String description;
  final String category;
  final String costCategory;
  final double estimatedCost;
  final double rating;
  final LocationData location;
  final String imageUrl;

  const PlaceAutocompletePrediction({
    required this.placeId,
    required this.name,
    this.address = '',
    this.description = '',
    this.category = 'attraction',
    this.costCategory = 'activities',
    this.estimatedCost = 300.0,
    this.rating = 4.5,
    this.location = const LocationData(),
    this.imageUrl = '',
  });

  factory PlaceAutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompletePrediction(
      placeId: json['placeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'attraction',
      costCategory: json['costCategory'] as String? ?? 'activities',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 300.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : const LocationData(),
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}
