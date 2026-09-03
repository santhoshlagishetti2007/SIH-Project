import 'package:flutter_test/flutter_test.dart';
import 'package:sanchari_app/features/trips/domain/models/destination_customs_models.dart';
import 'package:sanchari_app/features/reviews/domain/models/review_models.dart';
import 'package:sanchari_app/features/trips/domain/models/trip_model.dart';

void main() {
  group('Itinerary Generation & Cost Estimation Unit Tests', () {
    test('ItineraryDay correctly computes total dayCost including stops and transport', () {
      final day = ItineraryDay(
        dayNumber: 1,
        title: 'Forts & Palaces',
        theme: 'Heritage Exploration',
        dayTransportCost: 350.0,
        stops: [
          const ItineraryStop(
            id: 's1',
            name: 'Amer Fort',
            category: 'heritage',
            costCategory: 'activities',
            cost: 500.0,
            order: 0,
          ),
          const ItineraryStop(
            id: 's2',
            name: 'Pyaaz Kachori Breakfast',
            category: 'food',
            costCategory: 'food',
            cost: 150.0,
            order: 1,
          ),
          const ItineraryStop(
            id: 's3',
            name: 'City Palace',
            category: 'heritage',
            costCategory: 'activities',
            cost: 300.0,
            order: 2,
          ),
        ],
      );

      // Stops cost: 500 + 150 + 300 = 950
      // Day cost: 950 + 350 (transport) = 1300
      expect(day.dayCost, 1300.0);
    });

    test('TripModel accurately calculates estimatedTotalCost across multi-day itineraries', () {
      final trip = TripModel(
        id: 'trip_101',
        title: 'Rajasthan Royal Circuit',
        destination: 'Jaipur, Rajasthan',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 3),
        budget: 20000.0,
        itinerary: [
          ItineraryDay(
            dayNumber: 1,
            title: 'Day 1',
            theme: 'Heritage',
            dayTransportCost: 400.0,
            stops: [
              const ItineraryStop(id: '1', name: 'Amer Fort', cost: 500.0, costCategory: 'activities'),
              const ItineraryStop(id: '2', name: 'Royal Lunch', cost: 700.0, costCategory: 'food'),
            ],
          ),
          ItineraryDay(
            dayNumber: 2,
            title: 'Day 2',
            theme: 'Bazaars',
            dayTransportCost: 250.0,
            stops: [
              const ItineraryStop(id: '3', name: 'Johari Bazaar', cost: 1200.0, costCategory: 'activities'),
              const ItineraryStop(id: '4', name: 'Heritage Haveli', cost: 4000.0, costCategory: 'stay'),
            ],
          ),
        ],
      );

      // Day 1: 500 + 700 + 400 = 1600
      // Day 2: 1200 + 4000 + 250 = 5450
      // Total: 1600 + 5450 = 7050
      expect(trip.estimatedTotalCost, 7050.0);
      expect(trip.costBreakdown['activities'], 1700.0);
      expect(trip.costBreakdown['food'], 700.0);
      expect(trip.costBreakdown['stay'], 4000.0);
      expect(trip.costBreakdown['transport'], 650.0);
    });

    test('RatingBreakdown and ReviewSummary calculate correct counts and distributions', () {
      final breakdown = RatingBreakdown.fromJson({
        '5': 12,
        '4': 4,
        '3': 2,
        '2': 0,
        '1': 0,
      });

      expect(breakdown.star5, 12);
      expect(breakdown.star4, 4);
      expect(breakdown.star3, 2);
      expect(breakdown.star2, 0);
      expect(breakdown.star1, 0);

      final summary = ReviewSummary(
        targetId: 'eat_rawat',
        averageRating: 4.8,
        totalReviews: 18,
        ratingBreakdown: breakdown,
      );

      expect(summary.averageRating, 4.8);
      expect(summary.totalReviews, 18);
    });

    test('DestinationCustoms serializes and deserializes scam alerts and temple etiquette', () {
      final json = {
        'destination': 'Jaipur',
        'region': 'Rajasthan',
        'dressCode': {
          'general': 'Lightweight cottons',
          'religiousSites': 'Cover head and shoulders',
          'nightlife': 'Smart casuals',
        },
        'templeEtiquette': ['Remove shoes at entrance', 'Accept prasad with right hand'],
        'commonScams': [
          {
            'name': 'Gemstone Export Scam',
            'warning': 'Touts asking to mail gems abroad',
            'preventionTip': 'Never carry items for strangers',
          },
        ],
      };

      final customs = DestinationCustoms.fromJson(json);

      expect(customs.destination, 'Jaipur');
      expect(customs.dressCode.general, 'Lightweight cottons');
      expect(customs.templeEtiquette.length, 2);
      expect(customs.commonScams.first.name, 'Gemstone Export Scam');
    });
  });
}
