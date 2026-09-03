const Trip = require('../../../models/trip.model');
const placesService = require('../../../services/places.service');
const routesService = require('../../../services/routes.service');

/**
 * Seed a default rich 3-day trip if user doesn't have any trips yet
 */
const createSampleTripForUser = async (userId) => {
  const sampleTrip = new Trip({
    userId,
    title: 'Jaipur Heritage & Food Expedition',
    destination: 'Jaipur, Rajasthan',
    startDate: new Date('2026-09-10'),
    endDate: new Date('2026-09-13'),
    travelerType: 'solo',
    budget: 12000,
    currency: 'INR',
    companions: [],
    status: 'planned',
    itinerary: [
      {
        dayNumber: 1,
        date: '2026-09-10',
        title: 'Day 1: Royal Forts & Sunset Vista',
        theme: 'Fortresses & Panoramas',
        stops: [
          {
            id: 'stop_amber_fort',
            placeId: 'curated_amber_palace',
            name: 'Amber Palace & Sheesh Mahal',
            category: 'monument',
            costCategory: 'activities',
            description: 'Marvel at Rajput architecture, mirror mosaics, and morning courtyard breezes.',
            timeSlot: 'Morning',
            startTime: '09:00',
            endTime: '11:30',
            durationMinutes: 150,
            cost: 500,
            rating: 4.8,
            userRatingsTotal: 34200,
            imageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9855, lng: 75.8513, address: 'Amer, Jaipur, Rajasthan 302028', city: 'Jaipur' },
            order: 0,
            notes: 'Visit early to avoid crowds and catch the morning light on Maota lake.',
          },
          {
            id: 'stop_jaigarh_fort',
            placeId: 'curated_jaigarh_fort',
            name: 'Jaigarh Fort (Victory Citadel)',
            category: 'monument',
            costCategory: 'activities',
            description: 'Inspect the worlds largest cannon on wheels and underground water reservoir network.',
            timeSlot: 'Midday',
            startTime: '12:00',
            endTime: '14:00',
            durationMinutes: 120,
            cost: 350,
            rating: 4.6,
            userRatingsTotal: 18400,
            imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9845, lng: 75.8456, address: 'Cheel ka Teela, Jaipur', city: 'Jaipur' },
            order: 1,
            notes: 'Scenic connecting path from Amber Fort.',
          },
          {
            id: 'stop_rawat_lunch',
            placeId: 'curated_rawat_mishthan',
            name: 'Rawat Mishthan Bhandar',
            category: 'food',
            costCategory: 'food',
            description: 'Famous stop for authentic Pyaaz Kachori and sweet Lassi.',
            timeSlot: 'Afternoon',
            startTime: '14:30',
            endTime: '15:30',
            durationMinutes: 60,
            cost: 300,
            rating: 4.6,
            userRatingsTotal: 42000,
            imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9221, lng: 75.7972, address: 'Station Rd, Sindhi Camp, Jaipur', city: 'Jaipur' },
            order: 2,
            notes: 'Must try the signature Mawa Kachori for dessert.',
          },
          {
            id: 'stop_nahargarh_sunset',
            placeId: 'curated_nahargarh_fort',
            name: 'Nahargarh Fort & Sunset Point',
            category: 'monument',
            costCategory: 'activities',
            description: 'Golden hour sunset over the entire Pink City skyline.',
            timeSlot: 'Evening',
            startTime: '16:30',
            endTime: '18:30',
            durationMinutes: 120,
            cost: 300,
            rating: 4.7,
            userRatingsTotal: 29500,
            imageUrl: 'https://images.unsplash.com/photo-1605649487212-47bdab064df8?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9373, lng: 75.8155, address: 'Krishna Nagar, Brahampuri, Jaipur', city: 'Jaipur' },
            order: 3,
            notes: 'Arrive 30 mins before sunset for the best seating at Padao Cafe.',
          },
        ],
        transitLegs: [],
      },
      {
        dayNumber: 2,
        date: '2026-09-11',
        title: 'Day 2: Walled City Gems & Artisans',
        theme: 'Palaces & Bazaars',
        stops: [
          {
            id: 'stop_hawa_mahal',
            placeId: 'curated_hawa_mahal',
            name: 'Hawa Mahal (Palace of Winds)',
            category: 'attraction',
            costCategory: 'activities',
            description: 'Iconic 5-story pink honeycomb facade built for royal court ladies.',
            timeSlot: 'Morning',
            startTime: '08:30',
            endTime: '10:00',
            durationMinutes: 90,
            cost: 200,
            rating: 4.6,
            userRatingsTotal: 58000,
            imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9239, lng: 75.8267, address: 'Badi Choupad, Pink City, Jaipur', city: 'Jaipur' },
            order: 0,
            notes: 'Tattoo Cafe across the street gives great frontal photos.',
          },
          {
            id: 'stop_city_palace',
            placeId: 'curated_city_palace_jaipur',
            name: 'The Royal City Palace',
            category: 'monument',
            costCategory: 'activities',
            description: 'Peacock courtyard, armor museum, and royal textile collections.',
            timeSlot: 'Late Morning',
            startTime: '10:30',
            endTime: '12:30',
            durationMinutes: 120,
            cost: 700,
            rating: 4.7,
            userRatingsTotal: 41200,
            imageUrl: 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9258, lng: 75.8236, address: 'Gangori Bazaar, Pink City, Jaipur', city: 'Jaipur' },
            order: 1,
            notes: 'Audio guide is available at the entrance gate.',
          },
          {
            id: 'stop_lmb_dining',
            placeId: 'curated_lmb_sweet',
            name: 'Laxmi Misthan Bhandar (LMB)',
            category: 'food',
            costCategory: 'food',
            description: 'Signature Rajasthani Royal Thali lunch with Dal Baati Churma.',
            timeSlot: 'Lunch',
            startTime: '13:00',
            endTime: '14:15',
            durationMinutes: 75,
            cost: 650,
            rating: 4.5,
            userRatingsTotal: 18200,
            imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9216, lng: 75.8251, address: 'Johari Bazar, Jaipur', city: 'Jaipur' },
            order: 2,
            notes: 'Air-conditioned heritage dining hall.',
          },
          {
            id: 'stop_bapu_bazaar',
            placeId: 'curated_bapu_bazaar',
            name: 'Bapu Bazaar & Johari Artisan Market',
            category: 'shopping',
            costCategory: 'activities',
            description: 'Traditional handcrafted footwear, bandhani textiles, and brass souvenirs.',
            timeSlot: 'Afternoon',
            startTime: '15:00',
            endTime: '17:30',
            durationMinutes: 150,
            cost: 400,
            rating: 4.5,
            userRatingsTotal: 22000,
            imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9189, lng: 75.8242, address: 'Bapu Bazaar, Pink City, Jaipur', city: 'Jaipur' },
            order: 3,
            notes: 'Polite bargaining is customary.',
          },
        ],
        transitLegs: [],
      },
      {
        dayNumber: 3,
        date: '2026-09-12',
        title: 'Day 3: Sacred Springs & Cultural Feast',
        theme: 'Spiritual & Cultural Heritage',
        stops: [
          {
            id: 'stop_jal_mahal',
            placeId: 'curated_jal_mahal',
            name: 'Jal Mahal (Water Palace)',
            category: 'nature',
            costCategory: 'activities',
            description: 'Morning lakeside promenade and views of the submerged palace.',
            timeSlot: 'Morning',
            startTime: '08:30',
            endTime: '09:30',
            durationMinutes: 60,
            cost: 100,
            rating: 4.5,
            userRatingsTotal: 36000,
            imageUrl: 'https://images.unsplash.com/photo-1590766940554-634a7ed41450?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9534, lng: 75.8462, address: 'Amer Rd, Jal Mahal, Jaipur', city: 'Jaipur' },
            order: 0,
            notes: 'Great spot for morning chai and peaceful lake breeze.',
          },
          {
            id: 'stop_galta_ji',
            placeId: 'curated_galta_ji',
            name: 'Galtaji Monkey Temple & Springs',
            category: 'culture',
            costCategory: 'activities',
            description: 'Explore the holy cliffside water tanks and ancient pavilions.',
            timeSlot: 'Late Morning',
            startTime: '10:00',
            endTime: '12:00',
            durationMinutes: 120,
            cost: 200,
            rating: 4.5,
            userRatingsTotal: 14700,
            imageUrl: 'https://images.unsplash.com/photo-1548013146-72479768bbaa?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9161, lng: 75.8596, address: 'Galta Ji, Jaipur', city: 'Jaipur' },
            order: 1,
            notes: 'Keep snacks packed safely inside your backpack.',
          },
          {
            id: 'stop_tapri_cafe',
            placeId: 'curated_tapri_central',
            name: 'Tapri The Tea House',
            category: 'cafe',
            costCategory: 'food',
            description: 'Relax with artisanal masala chai, bun muska, and rooftop park views.',
            timeSlot: 'Afternoon',
            startTime: '13:00',
            endTime: '14:30',
            durationMinutes: 90,
            cost: 450,
            rating: 4.7,
            userRatingsTotal: 19800,
            imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.9069, lng: 75.8087, address: 'Prithviraj Road, C-Scheme, Jaipur', city: 'Jaipur' },
            order: 2,
            notes: 'Try the handmade khari biscuits and saunf chai.',
          },
          {
            id: 'stop_chokhi_dhani',
            placeId: 'curated_chokhi_dhani',
            name: 'Chokhi Dhani Ethnic Resort & Banquet',
            category: 'culture',
            costCategory: 'food',
            description: 'Grand cultural village finale with fire dancers, puppet shows, and royal banquet.',
            timeSlot: 'Evening',
            startTime: '18:00',
            endTime: '21:30',
            durationMinutes: 210,
            cost: 1200,
            rating: 4.6,
            userRatingsTotal: 31000,
            imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=800&auto=format&fit=crop&q=80',
            location: { lat: 26.7663, lng: 75.8344, address: '12 Miles, Tonk Rd, Jaipur', city: 'Jaipur' },
            order: 3,
            notes: 'Includes grand sit-down traditional Rajasthani dinner.',
          },
        ],
        transitLegs: [],
      },
    ],
  });

  // Compute transit legs for each day
  for (const day of sampleTrip.itinerary) {
    day.transitLegs = await routesService.calculateTransitLegsForStops(day.stops, 'Jaipur');
  }

  sampleTrip.recalculateTotalCosts();
  await sampleTrip.save();
  return sampleTrip;
};

/**
 * Controller methods for Trip and Itinerary Management
 */
const tripController = {
  /**
   * Get all trips for the authenticated user (seeds sample if none exist)
   */
  async getMyTrips(req, res, next) {
    try {
      const userId = req.user?.uid || 'dev-user-001';
      let trips = await Trip.find({ userId }).sort({ createdAt: -1 });

      if (trips.length === 0) {
        const seeded = await createSampleTripForUser(userId);
        trips = [seeded];
      }

      return res.status(200).json({
        success: true,
        message: 'Trips retrieved successfully',
        data: trips,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get trip by ID
   */
  async getTripById(req, res, next) {
    try {
      const { tripId } = req.params;
      const userId = req.user?.uid || 'dev-user-001';

      let trip = await Trip.findById(tripId);

      if (!trip) {
        trip = await Trip.findOne({ userId }).sort({ createdAt: -1 });
        if (!trip) {
          trip = await createSampleTripForUser(userId);
        }
      }

      return res.status(200).json({
        success: true,
        message: 'Trip details retrieved successfully',
        data: trip,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Create new trip
   */
  async createTrip(req, res, next) {
    try {
      const userId = req.user?.uid || 'dev-user-001';
      const tripData = {
        ...req.body,
        userId,
      };

      const newTrip = new Trip(tripData);

      // Auto-calculate transit legs if stops are provided without legs
      if (Array.isArray(newTrip.itinerary)) {
        for (const day of newTrip.itinerary) {
          if (!day.transitLegs || day.transitLegs.length === 0) {
            day.transitLegs = await routesService.calculateTransitLegsForStops(
              day.stops,
              newTrip.destination || 'Jaipur'
            );
          }
        }
      }

      newTrip.recalculateTotalCosts();
      await newTrip.save();

      return res.status(201).json({
        success: true,
        message: 'Trip created successfully',
        data: newTrip,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Persist updated itinerary to MongoDB
   * PATCH /api/trips/:tripId/itinerary & PATCH /api/v1/trips/:tripId/itinerary
   */
  async updateTripItinerary(req, res, next) {
    try {
      const { tripId } = req.params;
      const userId = req.user?.uid || 'dev-user-001';
      const { itinerary, title, budget } = req.body;

      let trip = await Trip.findById(tripId);

      if (!trip) {
        trip = await Trip.findOne({ userId });
        if (!trip) {
          trip = await createSampleTripForUser(userId);
        }
      }

      if (itinerary && Array.isArray(itinerary)) {
        // Compute / preserve transit legs for updated days
        for (const day of itinerary) {
          if (!day.transitLegs || day.transitLegs.length === 0 || day.transitLegs.length !== Math.max(0, day.stops.length - 1)) {
            day.transitLegs = await routesService.calculateTransitLegsForStops(
              day.stops,
              trip.destination || 'Jaipur'
            );
          }
        }
        trip.itinerary = itinerary;
      }

      if (title) trip.title = title;
      if (budget !== undefined) trip.budget = budget;

      // Recalculate costs dynamically
      trip.recalculateTotalCosts();

      trip.markModified('itinerary');
      trip.markModified('costBreakdown');
      const savedTrip = await trip.save();

      return res.status(200).json({
        success: true,
        message: 'Itinerary updated and total costs recalculated successfully',
        data: savedTrip,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Calculate transit legs for a given set of stops in a day
   * POST /api/v1/trips/transport/calculate-legs
   */
  async calculateTransitLegs(req, res, next) {
    try {
      const { stops, city } = req.body;

      if (!Array.isArray(stops) || stops.length < 2) {
        return res.status(200).json({
          success: true,
          message: 'At least 2 stops required for transit legs',
          data: [],
          timestamp: new Date().toISOString(),
        });
      }

      const legs = await routesService.calculateTransitLegsForStops(stops, city || 'Jaipur');

      return res.status(200).json({
        success: true,
        message: 'Transit legs calculated successfully',
        data: legs,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get 3 similar alternatives matching category near stop location
   * GET /api/v1/trips/places/alternatives
   */
  async getSwapAlternatives(req, res, next) {
    try {
      const { category, lat, lng, city, placeName, excludePlaceId } = req.query;

      const alternatives = await placesService.getSimilarAlternatives({
        category: category || 'attraction',
        lat: lat ? parseFloat(lat) : undefined,
        lng: lng ? parseFloat(lng) : undefined,
        city: city || 'Jaipur',
        placeName,
        excludePlaceId,
      });

      return res.status(200).json({
        success: true,
        message: 'Swap alternatives retrieved successfully',
        data: alternatives,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Places Autocomplete Search
   * GET /api/v1/trips/places/autocomplete
   */
  async placesAutocomplete(req, res, next) {
    try {
      const { input, lat, lng, city } = req.query;

      if (!input || input.trim().length === 0) {
        return res.status(200).json({
          success: true,
          message: 'Empty query',
          data: [],
          timestamp: new Date().toISOString(),
        });
      }

      const suggestions = await placesService.autocompletePlaces({
        input,
        lat: lat ? parseFloat(lat) : undefined,
        lng: lng ? parseFloat(lng) : undefined,
        city,
      });

      return res.status(200).json({
        success: true,
        message: 'Autocomplete predictions fetched successfully',
        data: suggestions,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get 3 authentic local eateries near a stop with 24-hour server-side caching
   * GET /api/v1/trips/places/eat-nearby
   */
  async getEatNearby(req, res, next) {
    try {
      const { lat, lng, stopId, stopName, city, radius } = req.query;

      const result = await placesService.getEatNearby({
        lat: lat ? parseFloat(lat) : undefined,
        lng: lng ? parseFloat(lng) : undefined,
        stopId,
        stopName,
        city: city || 'Jaipur',
        radius: radius ? parseInt(radius, 10) : 2500,
      });

      return res.status(200).json({
        success: true,
        message: 'Authentic local eateries near stop retrieved successfully',
        data: result.data,
        fromCache: result.fromCache,
        cacheSource: result.cacheSource,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Delete trip
   */
  async deleteTrip(req, res, next) {
    try {
      const { tripId } = req.params;
      const userId = req.user?.uid || 'dev-user-001';

      await Trip.findOneAndDelete({ _id: tripId, userId });

      return res.status(200).json({
        success: true,
        message: 'Trip deleted successfully',
        data: { tripId },
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = tripController;
