import 'package:flutter/material.dart';

/// Traveler Type classification for AI personalization & tailored recommendations
enum TravelerType {
  solo('solo', 'Solo Explorer', 'Wander independently at your own pace', Icons.person),
  backpacker('backpacker', 'Backpacker / Budget', 'Thrifty adventures, hostels & offbeat trails', Icons.backpack),
  family('family', 'Family Traveler', 'Kid-friendly, relaxed & curated for everyone', Icons.family_restroom),
  womanTraveler('woman_traveler', 'Woman Traveler', 'Safety-first verified stays & solo/group safety features', Icons.shield),
  luxury('luxury', 'Luxury & Leisure', 'Premium stays, fine dining & scenic comfort', Icons.hotel_class),
  group('group', 'Group & Friends', 'Social getaways, shared itineraries & squad vibes', Icons.groups),
  other('other', 'General Traveler', 'Custom exploration style', Icons.explore);

  final String value;
  final String title;
  final String description;
  final IconData icon;

  const TravelerType(this.value, this.title, this.description, this.icon);

  static TravelerType fromString(String? val) {
    if (val == null) return TravelerType.solo;
    return TravelerType.values.firstWhere(
      (type) => type.value.toLowerCase() == val.toLowerCase() || type.name.toLowerCase() == val.toLowerCase(),
      orElse: () => TravelerType.solo,
    );
  }
}
