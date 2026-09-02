import 'emergency_contact.dart';
import 'traveler_type.dart';

/// Sanchari User Domain Entity linked with Firebase UID and MongoDB profile
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? phone;
  final String? photoUrl;
  final String homeCity;
  final String preferredLanguage;
  final TravelerType travelerType;
  final List<EmergencyContact> emergencyContacts;
  final bool isOnboarded;
  final String authProvider;
  final List<String> travelPreferences;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone,
    this.photoUrl,
    this.homeCity = '',
    this.preferredLanguage = 'en',
    this.travelerType = TravelerType.solo,
    this.emergencyContacts = const [],
    this.isOnboarded = false,
    this.authProvider = 'password',
    this.travelPreferences = const [],
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phone,
    String? photoUrl,
    String? homeCity,
    String? preferredLanguage,
    TravelerType? travelerType,
    List<EmergencyContact>? emergencyContacts,
    bool? isOnboarded,
    String? authProvider,
    List<String>? travelPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      homeCity: homeCity ?? this.homeCity,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      travelerType: travelerType ?? this.travelerType,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      authProvider: authProvider ?? this.authProvider,
      travelPreferences: travelPreferences ?? this.travelPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final contactsList = (json['emergencyContacts'] as List<dynamic>?)
            ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final prefs = (json['travelPreferences'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return UserModel(
      uid: json['uid']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? 'Traveler',
      phone: json['phone']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      homeCity: json['homeCity']?.toString() ?? '',
      preferredLanguage: json['preferredLanguage']?.toString() ?? 'en',
      travelerType: TravelerType.fromString(json['travelerType']?.toString()),
      emergencyContacts: contactsList,
      isOnboarded: json['isOnboarded'] == true,
      authProvider: json['authProvider']?.toString() ?? 'password',
      travelPreferences: prefs,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      if (phone != null) 'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'homeCity': homeCity,
      'preferredLanguage': preferredLanguage,
      'travelerType': travelerType.value,
      'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
      'isOnboarded': isOnboarded,
      'authProvider': authProvider,
      'travelPreferences': travelPreferences,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
