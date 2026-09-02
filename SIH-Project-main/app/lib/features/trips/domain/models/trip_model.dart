/// Domain entity representing a travel trip itinerary
class TripModel {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> companions;
  final double budget;

  const TripModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.companions = const [],
    this.budget = 0.0,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      companions: (json['companions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      budget: json['budget'] is num ? (json['budget'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'companions': companions,
      'budget': budget,
    };
  }
}
