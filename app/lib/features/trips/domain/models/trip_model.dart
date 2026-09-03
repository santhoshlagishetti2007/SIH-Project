import 'transport_models.dart';

/// Location Coordinates & Address Data
class LocationData {
  final double lat;
  final double lng;
  final String address;
  final String city;

  const LocationData({
    this.lat = 0.0,
    this.lng = 0.0,
    this.address = '',
    this.city = '',
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
      'city': city,
    };
  }

  LocationData copyWith({
    double? lat,
    double? lng,
    String? address,
    String? city,
  }) {
    return LocationData(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      city: city ?? this.city,
    );
  }
}

/// Single Stop in an Itinerary Day
class ItineraryStop {
  final String id;
  final String placeId;
  final String name;
  final String category;
  final String costCategory; // activities, food, stay, transport, other
  final String description;
  final LocationData location;
  final String timeSlot;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final double cost;
  final double rating;
  final int userRatingsTotal;
  final String imageUrl;
  final int order;
  final String notes;
  final bool isCustom;

  const ItineraryStop({
    required this.id,
    this.placeId = '',
    required this.name,
    this.category = 'attraction',
    this.costCategory = 'activities',
    this.description = '',
    this.location = const LocationData(),
    this.timeSlot = 'Morning',
    this.startTime = '09:00',
    this.endTime = '11:00',
    this.durationMinutes = 120,
    this.cost = 0.0,
    this.rating = 4.5,
    this.userRatingsTotal = 100,
    this.imageUrl = '',
    this.order = 0,
    this.notes = '',
    this.isCustom = false,
  });

  factory ItineraryStop.fromJson(Map<String, dynamic> json) {
    return ItineraryStop(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      placeId: json['placeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'attraction',
      costCategory: json['costCategory'] as String? ?? 'activities',
      description: json['description'] as String? ?? '',
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : const LocationData(),
      timeSlot: json['timeSlot'] as String? ?? 'Morning',
      startTime: json['startTime'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? '11:00',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 120,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      userRatingsTotal: (json['userRatingsTotal'] as num?)?.toInt() ?? 100,
      imageUrl: json['imageUrl'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String? ?? '',
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'name': name,
      'category': category,
      'costCategory': costCategory,
      'description': description,
      'location': location.toJson(),
      'timeSlot': timeSlot,
      'startTime': startTime,
      'endTime': endTime,
      'durationMinutes': durationMinutes,
      'cost': cost,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'imageUrl': imageUrl,
      'order': order,
      'notes': notes,
      'isCustom': isCustom,
    };
  }

  ItineraryStop copyWith({
    String? id,
    String? placeId,
    String? name,
    String? category,
    String? costCategory,
    String? description,
    LocationData? location,
    String? timeSlot,
    String? startTime,
    String? endTime,
    int? durationMinutes,
    double? cost,
    double? rating,
    int? userRatingsTotal,
    String? imageUrl,
    int? order,
    String? notes,
    bool? isCustom,
  }) {
    return ItineraryStop(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      category: category ?? this.category,
      costCategory: costCategory ?? this.costCategory,
      description: description ?? this.description,
      location: location ?? this.location,
      timeSlot: timeSlot ?? this.timeSlot,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      cost: cost ?? this.cost,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      notes: notes ?? this.notes,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

/// Day in a Travel Itinerary
class ItineraryDay {
  final int dayNumber;
  final String date;
  final String title;
  final String theme;
  final double dayCost;
  final double dayTransportCost;
  final List<ItineraryStop> stops;
  final List<TransitLeg> transitLegs;

  const ItineraryDay({
    required this.dayNumber,
    this.date = '',
    required this.title,
    this.theme = 'Exploration',
    this.dayCost = 0.0,
    this.dayTransportCost = 0.0,
    this.stops = const [],
    this.transitLegs = const [],
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 1,
      date: json['date'] as String? ?? '',
      title: json['title'] as String? ?? 'Day 1',
      theme: json['theme'] as String? ?? 'Exploration',
      dayCost: (json['dayCost'] as num?)?.toDouble() ?? 0.0,
      dayTransportCost: (json['dayTransportCost'] as num?)?.toDouble() ?? 0.0,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => ItineraryStop.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      transitLegs: (json['transitLegs'] as List<dynamic>?)
              ?.map((e) => TransitLeg.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'date': date,
      'title': title,
      'theme': theme,
      'dayCost': dayCost,
      'dayTransportCost': dayTransportCost,
      'stops': stops.map((s) => s.toJson()).toList(),
      'transitLegs': transitLegs.map((l) => l.toJson()).toList(),
    };
  }

  ItineraryDay copyWith({
    int? dayNumber,
    String? date,
    String? title,
    String? theme,
    double? dayCost,
    double? dayTransportCost,
    List<ItineraryStop>? stops,
    List<TransitLeg>? transitLegs,
  }) {
    return ItineraryDay(
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      title: title ?? this.title,
      theme: theme ?? this.theme,
      dayCost: dayCost ?? this.dayCost,
      dayTransportCost: dayTransportCost ?? this.dayTransportCost,
      stops: stops ?? this.stops,
      transitLegs: transitLegs ?? this.transitLegs,
    );
  }
}

/// Cost Breakdown across Expense Categories
class CostBreakdown {
  final double activities;
  final double food;
  final double stay;
  final double transport;
  final double other;
  final double total;

  const CostBreakdown({
    this.activities = 0.0,
    this.food = 0.0,
    this.stay = 0.0,
    this.transport = 0.0,
    this.other = 0.0,
    this.total = 0.0,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    return CostBreakdown(
      activities: (json['activities'] as num?)?.toDouble() ?? 0.0,
      food: (json['food'] as num?)?.toDouble() ?? 0.0,
      stay: (json['stay'] as num?)?.toDouble() ?? 0.0,
      transport: (json['transport'] as num?)?.toDouble() ?? 0.0,
      other: (json['other'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activities': activities,
      'food': food,
      'stay': stay,
      'transport': transport,
      'other': other,
      'total': total,
    };
  }
}

/// Full Trip Entity
class TripModel {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String travelerType;
  final double budget;
  final double estimatedTotalCost;
  final String currency;
  final List<String> companions;
  final String status;
  final List<ItineraryDay> itinerary;
  final CostBreakdown costBreakdown;

  const TripModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.travelerType = 'solo',
    this.budget = 15000.0,
    this.estimatedTotalCost = 0.0,
    this.currency = 'INR',
    this.companions = const [],
    this.status = 'planned',
    this.itinerary = const [],
    this.costBreakdown = const CostBreakdown(),
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      travelerType: json['travelerType'] as String? ?? 'solo',
      budget: (json['budget'] as num?)?.toDouble() ?? 15000.0,
      estimatedTotalCost: (json['estimatedTotalCost'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      companions: (json['companions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] as String? ?? 'planned',
      itinerary: (json['itinerary'] as List<dynamic>?)
              ?.map((e) => ItineraryDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      costBreakdown: json['costBreakdown'] != null
          ? CostBreakdown.fromJson(json['costBreakdown'] as Map<String, dynamic>)
          : const CostBreakdown(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'travelerType': travelerType,
      'budget': budget,
      'estimatedTotalCost': estimatedTotalCost,
      'currency': currency,
      'companions': companions,
      'status': status,
      'itinerary': itinerary.map((d) => d.toJson()).toList(),
      'costBreakdown': costBreakdown.toJson(),
    };
  }

  TripModel copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? travelerType,
    double? budget,
    double? estimatedTotalCost,
    String? currency,
    List<String>? companions,
    String? status,
    List<ItineraryDay>? itinerary,
    CostBreakdown? costBreakdown,
  }) {
    return TripModel(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      travelerType: travelerType ?? this.travelerType,
      budget: budget ?? this.budget,
      estimatedTotalCost: estimatedTotalCost ?? this.estimatedTotalCost,
      currency: currency ?? this.currency,
      companions: companions ?? this.companions,
      status: status ?? this.status,
      itinerary: itinerary ?? this.itinerary,
      costBreakdown: costBreakdown ?? this.costBreakdown,
    );
  }

  /// Recalculate all costs dynamically including stops and transit leg transport costs
  TripModel recalculateCosts() {
    double activitiesSum = 0.0;
    double foodSum = 0.0;
    double staySum = 0.0;
    double transportSum = 0.0;
    double otherSum = 0.0;
    double grandTotal = 0.0;

    final updatedDays = itinerary.map((day) {
      double dayStopSum = 0.0;
      double dayTransitSum = 0.0;

      // 1. Calculate stops cost
      for (final stop in day.stops) {
        dayStopSum += stop.cost;
        switch (stop.costCategory.toLowerCase()) {
          case 'activities':
            activitiesSum += stop.cost;
            break;
          case 'food':
            foodSum += stop.cost;
            break;
          case 'stay':
            staySum += stop.cost;
            break;
          case 'transport':
            transportSum += stop.cost;
            break;
          default:
            otherSum += stop.cost;
            break;
        }
      }

      // 2. Calculate transit legs transport cost
      for (final leg in day.transitLegs) {
        dayTransitSum += leg.estimatedCost;
        transportSum += leg.estimatedCost;
      }

      final totalDayCost = dayStopSum + dayTransitSum;
      grandTotal += totalDayCost;

      return day.copyWith(
        dayCost: totalDayCost,
        dayTransportCost: dayTransitSum,
      );
    }).toList();

    final newBreakdown = CostBreakdown(
      activities: activitiesSum,
      food: foodSum,
      stay: staySum,
      transport: transportSum,
      other: otherSum,
      total: grandTotal,
    );

    return copyWith(
      itinerary: updatedDays,
      costBreakdown: newBreakdown,
      estimatedTotalCost: grandTotal,
    );
  }
}
