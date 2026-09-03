const envConfig = require('../config/env.config');
const crypto = require('crypto');
const PlacesCache = require('../models/places_cache.model');

/**
 * List of generic international fast-food chains to filter out
 */
const EXCLUDED_GENERIC_CHAINS = [
  'mcdonald',
  'kfc',
  'subway',
  'domino',
  'pizza hut',
  'burger king',
  'starbucks',
  'dunkin',
  'taco bell',
  'wendy',
  'costa coffee',
  'baskin robbins',
  'popeye',
  'pizzahut',
  'papa john',
];

/**
 * Curated authentic local eateries catalog
 */
const CURATED_AUTHENTIC_EATERIES = [
  // Jaipur / Amer / Nahargarh
  {
    placeId: 'eatery_1135_ad',
    name: '1135 AD (Amber Fort Royal Dining)',
    cuisineType: 'Rajasthani Heritage & Mughlai',
    description: 'Dine in an authentic gold-enameled palace hall serving royal thalis, laal maas, and artisanal breads.',
    rating: 4.7,
    userRatingsTotal: 4800,
    priceLevel: '₹₹₹',
    priceLevelNum: 3,
    estimatedCost: 1200,
    city: 'Jaipur',
    location: { lat: 26.9855, lng: 75.8513, address: 'Level 2, Jalebi Chowk, Amber Fort, Jaipur, Rajasthan 302028', city: 'Jaipur' },
    photoUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=800&auto=format&fit=crop&q=80',
    openNow: true,
    specialties: ['Royal Rajasthani Thali', 'Laal Maas', 'Jungli Murgh', 'Kesari Kheer'],
  },
  {
    placeId: 'eatery_padao_nahargarh',
    name: 'Padao Nahargarh Sunset Restaurant',
    cuisineType: 'Rooftop Cafe & North Indian',
    description: 'Perched atop Nahargarh Fort offering fresh snacks, chilled beverages, and panoramic 360-degree city views.',
    rating: 4.6,
    userRatingsTotal: 6200,
    priceLevel: '₹₹',
    priceLevelNum: 2,
    estimatedCost: 450,
    city: 'Jaipur',
    location: { lat: 26.9373, lng: 75.8155, address: 'Nahargarh Fort, Krishna Nagar, Jaipur, Rajasthan 302002', city: 'Jaipur' },
    photoUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80',
    openNow: true,
    specialties: ['Sunset Chai & Pakoras', 'Paneer Tikka', 'Masala Fries', 'Kachori Platter'],
  },
  {
    placeId: 'eatery_lmb_sweet',
    name: 'Laxmi Misthan Bhandar (LMB)',
    cuisineType: 'Heritage Pure Vegetarian & Sweets',
    description: 'Legendary 1727 heritage institution renowned across India for royal Rajasthani Thali, Ghewar, and Dal Baati.',
    rating: 4.5,
    userRatingsTotal: 18200,
    priceLevel: '₹₹',
    priceLevelNum: 2,
    estimatedCost: 650,
    city: 'Jaipur',
    location: { lat: 26.9216, lng: 75.8251, address: 'Johari Bazar, Pink City, Jaipur, Rajasthan 302003', city: 'Jaipur' },
    photoUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
    openNow: true,
    specialties: ['Rajasthani Royal Thali', 'Paneer Ghewar', 'Dal Baati Churma', 'Pyaaz Kachori'],
  },
  {
    placeId: 'eatery_rawat_mishthan',
    name: 'Rawat Mishthan Bhandar',
    cuisineType: 'Iconic Breakfast, Chaat & Sweets',
    description: 'Famous breakfast haven acclaimed across India for steaming crispy Mawa & Pyaaz Kachoris and fresh Lassi.',
    rating: 4.6,
    userRatingsTotal: 42000,
    priceLevel: '₹',
    priceLevelNum: 1,
    estimatedCost: 250,
    city: 'Jaipur',
    location: { lat: 26.9221, lng: 75.7972, address: 'Station Rd, Sindhi Camp, Jaipur, Rajasthan 302006', city: 'Jaipur' },
    photoUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
    openNow: true,
    specialties: ['Crispy Pyaaz Kachori', 'Mawa Kachori', 'Gulab Jamun', 'Malpua with Rabdi'],
  },
  {
    placeId: 'eatery_tapri_central',
    name: 'Tapri The Tea House & Rooftop',
    cuisineType: 'Artisanal Tea & Modern Fusion Bites',
    description: 'Chic rooftop cafe overlooking Central Park serving handmade masala chai, bun muska, and modern Indian tapas.',
    rating: 4.7,
    userRatingsTotal: 19800,
    priceLevel: '₹₹',
    priceLevelNum: 2,
    estimatedCost: 400,
    city: 'Jaipur',
    location: { lat: 26.9069, lng: 75.8087, address: 'B4-E, Prithviraj Road, C-Scheme, Ashok Nagar, Jaipur', city: 'Jaipur' },
    photoUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&auto=format&fit=crop&q=80',
    openNow: true,
    specialties: ['Handmade Saunf Chai', 'Tadke Wali Maggi', 'Khari with Herb Dip', 'Cheese Corn Balls'],
  },
  {
    placeId: 'eatery_handi_restaurant',
    name: 'Handi Heritage Restaurant',
    cuisineType: 'Authentic Mughlai & Tandoor',
    description: 'Award-winning dining hall famed for clay-pot handi preparations, rumaali rotis, and smoked tandoori specials.',
    rating: 4.5,
    userRatingsTotal: 9800,
    priceLevel: '₹₹',
    priceLevelNum: 2,
    estimatedCost: 700,
    city: 'Jaipur',
    location: { lat: 26.9185, lng: 75.8062, address: 'Opp GPO, MI Road, Jaipur, Rajasthan 302001', city: 'Jaipur' },
    photoUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop&q=80',
    openNow: true,
    specialties: ['Handi Mutton Special', 'Paneer Tikka Butter Masala', 'Mughlai Biryani', 'Firni'],
  },
  {
    placeId: 'eatery_peacock_rooftop',
    name: 'Peacock Rooftop Restaurant',
    cuisineType: 'North Indian & Continental Garden',
    description: 'Artistic garden rooftop filled with painted bird motifs, live traditional music, and freshly prepared organic curries.',
    rating: 4.6,
    userRatingsTotal: 11400,
    priceLevel: '₹₹',
    priceLevelNum: 2,
    estimatedCost: 500,
    city: 'Jaipur',
    location: { lat: 26.9152, lng: 75.7942, address: 'Hotel Pearl Palace, 51 Hari Kishan Somani Marg, Hathroi Fort, Jaipur', city: 'Jaipur' },
    photoUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80',
    openNow: true,
    specialties: ['Butter Chicken Special', 'Stuffed Tomato Curry', 'Palak Paneer', 'Fresh Mint Paratha'],
  },
  {
    placeId: 'eatery_spice_court',
    name: 'Spice Court Fine Dining',
    cuisineType: 'Traditional Rajasthani & Courtyard',
    description: 'Breezy heritage courtyard dining with traditional puppet shows and authentic Keema Baati and Gatte ki Sabzi.',
    rating: 4.5,
    userRatingsTotal: 7600,
    priceLevel: '₹₹',
    priceLevelNum: 2,
    estimatedCost: 600,
    city: 'Jaipur',
    location: { lat: 26.9077, lng: 75.7891, address: 'Hari Bhawan, Jacob Rd, Civil Lines, Jaipur, Rajasthan 302006', city: 'Jaipur' },
    photoUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
    openNow: true,
    specialties: ['Keema Baati', 'Gatte Ki Sabzi', 'Ker Sangri', 'Shahi Tukda'],
  },
];

/**
 * Curated knowledge base for places across major categories and Indian/global destinations
 */
const CURATED_PLACES_DATABASE = [
  // Jaipur / Heritage & Rajasthan
  {
    placeId: 'curated_amber_palace',
    name: 'Amber Palace & Sheesh Mahal',
    category: 'monument',
    costCategory: 'activities',
    description: 'Iconic 16th-century hilltop palace featuring ornate mirror halls and panoramic Maota lake views.',
    rating: 4.8,
    userRatingsTotal: 34200,
    cost: 500,
    durationMinutes: 150,
    city: 'Jaipur',
    location: { lat: 26.9855, lng: 75.8513, address: 'Devisinghpura, Amer, Jaipur, Rajasthan 302028', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_jaigarh_fort',
    name: 'Jaigarh Fort (Victory Fort)',
    category: 'monument',
    costCategory: 'activities',
    description: 'Stunning military citadel housing the historic Jaivana Cannon overlooking the Aravalli hills.',
    rating: 4.6,
    userRatingsTotal: 18400,
    cost: 350,
    durationMinutes: 120,
    city: 'Jaipur',
    location: { lat: 26.9845, lng: 75.8456, address: 'Cheel ka Teela, Amer, Jaipur, Rajasthan 302001', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_nahargarh_fort',
    name: 'Nahargarh Fort & Sunset Point',
    category: 'monument',
    costCategory: 'activities',
    description: 'Historic hilltop fort with sweeping panoramic sunset vistas overlooking the Pink City.',
    rating: 4.7,
    userRatingsTotal: 29500,
    cost: 300,
    durationMinutes: 120,
    city: 'Jaipur',
    location: { lat: 26.9373, lng: 75.8155, address: 'Krishna Nagar, Brahampuri, Jaipur, Rajasthan 302002', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1605649487212-47bdab064df8?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_city_palace_jaipur',
    name: 'The Royal City Palace',
    category: 'monument',
    costCategory: 'activities',
    description: 'Opulent royal complex with courtyards, Peacock Gate, museum galleries, and Rajput architecture.',
    rating: 4.7,
    userRatingsTotal: 41200,
    cost: 700,
    durationMinutes: 120,
    city: 'Jaipur',
    location: { lat: 26.9258, lng: 75.8236, address: 'Gangori Bazaar, J.D.A. Market, Pink City, Jaipur, Rajasthan 302002', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_hawa_mahal',
    name: 'Hawa Mahal (Palace of Winds)',
    category: 'attraction',
    costCategory: 'activities',
    description: 'Distinctive pink sandstone facade with 953 honeycomb windows designed for royal breezes.',
    rating: 4.6,
    userRatingsTotal: 58000,
    cost: 200,
    durationMinutes: 60,
    city: 'Jaipur',
    location: { lat: 26.9239, lng: 75.8267, address: 'Hawa Mahal Rd, Badi Choupad, J.D.A. Market, Pink City, Jaipur', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_jantar_mantar',
    name: 'Jantar Mantar Astronomical Observatory',
    category: 'attraction',
    costCategory: 'activities',
    description: 'UNESCO World Heritage 18th-century stone sundials and celestial calculation instruments.',
    rating: 4.6,
    userRatingsTotal: 25300,
    cost: 250,
    durationMinutes: 90,
    city: 'Jaipur',
    location: { lat: 26.9248, lng: 75.8246, address: 'Gangori Bazaar, J.D.A. Market, Pink City, Jaipur', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1627916607164-7b20241db935?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_lmb_sweet',
    name: 'Laxmi Misthan Bhandar (LMB)',
    category: 'food',
    costCategory: 'food',
    description: 'Legendary Johari Bazaar restaurant serving authentic Rajasthani Thali, Ghewar, and Pyaz Kachori.',
    rating: 4.5,
    userRatingsTotal: 18200,
    cost: 650,
    durationMinutes: 75,
    city: 'Jaipur',
    location: { lat: 26.9216, lng: 75.8251, address: 'Johari Bazar, Pink City, Jaipur, Rajasthan 302003', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_chokhi_dhani',
    name: 'Chokhi Dhani Ethnic Resort & Dining',
    category: 'culture',
    costCategory: 'food',
    description: 'Immersive Rajasthani cultural village with folk dance, camel rides, and traditional thali banquet.',
    rating: 4.6,
    userRatingsTotal: 31000,
    cost: 1200,
    durationMinutes: 180,
    city: 'Jaipur',
    location: { lat: 26.7663, lng: 75.8344, address: '12 Miles, Tonk Rd, Goner Phatak, Jaipur, Rajasthan 303905', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_rawat_mishthan',
    name: 'Rawat Mishthan Bhandar',
    category: 'food',
    costCategory: 'food',
    description: 'Famous breakfast haven acclaimed across India for crispy Mawa & Pyaaz Kachoris.',
    rating: 4.6,
    userRatingsTotal: 42000,
    cost: 300,
    durationMinutes: 45,
    city: 'Jaipur',
    location: { lat: 26.9221, lng: 75.7972, address: 'Station Rd, Sindhi Camp, Jaipur, Rajasthan 302006', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_tapri_central',
    name: 'Tapri The Tea House & Rooftop',
    category: 'cafe',
    costCategory: 'food',
    description: 'Trendy rooftop cafe overlooking Central Park serving artisanal masala chai and modern bites.',
    rating: 4.7,
    userRatingsTotal: 19800,
    cost: 400,
    durationMinutes: 60,
    city: 'Jaipur',
    location: { lat: 26.9069, lng: 75.8087, address: 'B4-E, Prithviraj Road, C-Scheme, Ashok Nagar, Jaipur', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_bapu_bazaar',
    name: 'Bapu Bazaar & Johari Artisan Market',
    category: 'shopping',
    costCategory: 'activities',
    description: 'Vibrant pink-walled market famous for handcrafted mojari footwear, textiles, and gemstones.',
    rating: 4.5,
    userRatingsTotal: 22000,
    cost: 400,
    durationMinutes: 120,
    city: 'Jaipur',
    location: { lat: 26.9189, lng: 75.8242, address: 'Bapu Bazaar, Pink City, Jaipur, Rajasthan 302003', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_jal_mahal',
    name: 'Jal Mahal (Water Palace)',
    category: 'nature',
    costCategory: 'activities',
    description: 'Serene palace appearing to float in the center of Man Sagar Lake against picturesque hills.',
    rating: 4.5,
    userRatingsTotal: 36000,
    cost: 100,
    durationMinutes: 45,
    city: 'Jaipur',
    location: { lat: 26.9534, lng: 75.8462, address: 'Amer Rd, Jal Mahal, Amber, Jaipur, Rajasthan 302002', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1590766940554-634a7ed41450?w=800&auto=format&fit=crop&q=80',
  },
  {
    placeId: 'curated_galta_ji',
    name: 'Galtaji Monkey Temple & Sacred Kunds',
    category: 'culture',
    costCategory: 'activities',
    description: 'Ancient mountain temple pass with holy natural springs and friendly macaque colonies.',
    rating: 4.5,
    userRatingsTotal: 14700,
    cost: 200,
    durationMinutes: 90,
    city: 'Jaipur',
    location: { lat: 26.9161, lng: 75.8596, address: 'Galta Ji, Khania-Balaji, Jaipur, Rajasthan 302031', city: 'Jaipur' },
    imageUrl: 'https://images.unsplash.com/photo-1548013146-72479768bbaa?w=800&auto=format&fit=crop&q=80',
  },
];

class PlacesService {
  hasGoogleMapsKey() {
    return Boolean(
      envConfig.google.mapsApiKey &&
        envConfig.google.mapsApiKey !== 'your_google_maps_api_key_here' &&
        envConfig.google.mapsApiKey.length > 10
    );
  }

  /**
   * Get 3 authentic local eateries near a stop with 24-hour server-side TTL caching
   */
  async getEatNearby({ lat, lng, stopId, stopName, city = 'Jaipur', radius = 2500 }) {
    const latNum = lat ? parseFloat(lat) : 26.9124;
    const lngNum = lng ? parseFloat(lng) : 75.7873;

    // Cache key incorporates location rounded to ~100m or stop ID
    const cacheKey = stopId
      ? `eat_nearby:${stopId}`
      : `eat_nearby:${latNum.toFixed(3)},${lngNum.toFixed(3)}:${radius}`;

    const cacheMetadata = {
      category: 'eat_nearby',
      location: { lat: latNum, lng: lngNum, city },
    };

    return await PlacesCache.getOrSet(
      cacheKey,
      async () => {
        if (this.hasGoogleMapsKey()) {
          try {
            const googleResults = await this._queryGooglePlacesEatNearby({
              lat: latNum,
              lng: lngNum,
              radius,
              city,
            });
            if (googleResults && googleResults.length >= 2) {
              return googleResults.slice(0, 3);
            }
          } catch (err) {
            console.warn(`[PlacesService] Google Places Eat Nearby query failed, falling back to curated authentic catalog: ${err.message}`);
          }
        }

        // Curated authentic catalog fallback
        return this._getCuratedEatNearby({ lat: latNum, lng: lngNum, stopName, city });
      },
      cacheMetadata
    );
  }

  async getSimilarAlternatives({ category, lat, lng, city, placeName, excludePlaceId }) {
    if (this.hasGoogleMapsKey()) {
      try {
        const results = await this._queryGooglePlacesAlternatives({
          category,
          lat,
          lng,
          city,
          placeName,
          excludePlaceId,
        });
        if (results && results.length >= 2) {
          return results.slice(0, 3);
        }
      } catch (err) {
        console.warn(`[PlacesService] Google Places API query failed, using curated catalog: ${err.message}`);
      }
    }

    return this._getCatalogAlternatives({
      category,
      lat,
      lng,
      city,
      placeName,
      excludePlaceId,
    });
  }

  async autocompletePlaces({ input, lat, lng, city }) {
    const query = (input || '').trim();
    if (!query) {
      return [];
    }

    if (this.hasGoogleMapsKey()) {
      try {
        const suggestions = await this._queryGooglePlacesAutocomplete({
          input: query,
          lat,
          lng,
          city,
        });
        if (suggestions && suggestions.length > 0) {
          return suggestions;
        }
      } catch (err) {
        console.warn(`[PlacesService] Google Autocomplete query failed, using catalog: ${err.message}`);
      }
    }

    return this._getCatalogAutocomplete({ query, lat, lng, city });
  }

  /**
   * Query Google Places Nearby Search for authentic eateries
   * @private
   */
  async _queryGooglePlacesEatNearby({ lat, lng, radius, city }) {
    const mapsKey = envConfig.google.mapsApiKey;
    const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=${radius}&type=restaurant&keyword=${encodeURIComponent('local authentic food restaurant')}&key=${mapsKey}`;

    const response = await fetch(url);
    const data = await response.json();

    if (data.status === 'OK' && Array.isArray(data.results)) {
      return data.results
        .filter((place) => {
          // 1. Filter out generic international fast-food chains
          const nameLower = (place.name || '').toLowerCase();
          const isChain = EXCLUDED_GENERIC_CHAINS.some((chain) => nameLower.includes(chain));
          if (isChain) return false;

          // 2. Bias toward higher-rated eateries
          return (place.rating || 0) >= 3.8;
        })
        .sort((a, b) => (b.rating || 0) - (a.rating || 0))
        .slice(0, 3)
        .map((place) => {
          const placeLat = place.geometry?.location?.lat || lat;
          const placeLng = place.geometry?.location?.lng || lng;
          const distMeters = this._calculateHaversineDistanceMeters(lat, lng, placeLat, placeLng);
          const priceLevel = place.price_level || 2;

          let photoUrl = '';
          if (place.photos && place.photos.length > 0) {
            photoUrl = `https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${place.photos[0].photo_reference}&key=${mapsKey}`;
          } else {
            photoUrl = 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80';
          }

          return {
            id: `eatery_google_${place.place_id}`,
            placeId: place.place_id,
            name: place.name,
            cuisineType: this._detectCuisineType(place.name, place.types),
            description: place.vicinity || `Popular authentic dining in ${city}`,
            rating: place.rating || 4.5,
            userRatingsTotal: place.user_ratings_total || 250,
            priceLevel: '₹'.repeat(Math.min(4, Math.max(1, priceLevel))),
            priceLevelNum: priceLevel,
            estimatedCost: 200 * priceLevel,
            distanceMeters: Math.round(distMeters),
            distanceKm: Number((distMeters / 1000).toFixed(1)),
            address: place.vicinity || `${place.name}, ${city}`,
            location: { lat: placeLat, lng: placeLng, address: place.vicinity || '', city },
            photoUrl,
            openNow: place.opening_hours ? Boolean(place.opening_hours.open_now) : true,
            specialties: ['Chef Signature Special', 'Traditional Regional Thali', 'Tandoori Platters'],
          };
        });
    }

    return [];
  }

  /**
   * Curated authentic eateries selection matching stop proximity
   * @private
   */
  _getCuratedEatNearby({ lat, lng, _city }) {
    const list = CURATED_AUTHENTIC_EATERIES.map((eatery) => {
      const distMeters = this._calculateHaversineDistanceMeters(
        lat,
        lng,
        eatery.location.lat,
        eatery.location.lng
      );

      return {
        id: eatery.placeId,
        placeId: eatery.placeId,
        name: eatery.name,
        cuisineType: eatery.cuisineType,
        description: eatery.description,
        rating: eatery.rating,
        userRatingsTotal: eatery.userRatingsTotal,
        priceLevel: eatery.priceLevel,
        priceLevelNum: eatery.priceLevelNum,
        estimatedCost: eatery.estimatedCost,
        distanceMeters: Math.round(distMeters),
        distanceKm: Number((distMeters / 1000).toFixed(1)),
        address: eatery.location.address,
        location: eatery.location,
        photoUrl: eatery.photoUrl,
        openNow: eatery.openNow,
        specialties: eatery.specialties,
      };
    });

    // Sort by proximity and rating
    list.sort((a, b) => a.distanceMeters - b.distanceMeters);

    return list.slice(0, 3);
  }

  async _queryGooglePlacesAlternatives({ category, lat, lng, city, placeName, excludePlaceId }) {
    const mapsKey = envConfig.google.mapsApiKey;
    let url;

    if (lat && lng && Number(lat) !== 0 && Number(lng) !== 0) {
      const typeParam = this._mapCategoryToGoogleType(category);
      url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=15000&type=${typeParam}&key=${mapsKey}`;
    } else {
      const searchTerms = `${category} in ${city || 'India'}`;
      url = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodeURIComponent(searchTerms)}&key=${mapsKey}`;
    }

    const response = await fetch(url);
    const data = await response.json();

    if (data.status === 'OK' && Array.isArray(data.results)) {
      return data.results
        .filter((item) => item.place_id !== excludePlaceId && item.name !== placeName)
        .slice(0, 3)
        .map((place) => this._formatGooglePlaceResult(place, category, city));
    }

    return [];
  }

  async _queryGooglePlacesAutocomplete({ input, lat, lng }) {
    const mapsKey = envConfig.google.mapsApiKey;
    let url = `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${encodeURIComponent(input)}&key=${mapsKey}`;

    if (lat && lng && Number(lat) !== 0 && Number(lng) !== 0) {
      url += `&location=${lat},${lng}&radius=30000`;
    }

    const response = await fetch(url);
    const data = await response.json();

    if (data.status === 'OK' && Array.isArray(data.predictions)) {
      return data.predictions.slice(0, 6).map((pred) => ({
        placeId: pred.place_id,
        name: pred.structured_formatting?.main_text || pred.description,
        address: pred.structured_formatting?.secondary_text || pred.description,
        description: pred.description,
        category: this._detectCategoryFromTypes(pred.types),
        costCategory: this._categoryToCostCategory(this._detectCategoryFromTypes(pred.types)),
        estimatedCost: this._estimateCostByCategory(this._detectCategoryFromTypes(pred.types)),
      }));
    }

    return [];
  }

  _getCatalogAlternatives({ category, city, placeName, excludePlaceId }) {
    const normalizedCategory = (category || '').toLowerCase();
    const normalizedCity = (city || '').toLowerCase();

    let matches = CURATED_PLACES_DATABASE.filter(
      (p) =>
        p.placeId !== excludePlaceId &&
        p.name !== placeName &&
        (this._normalizeCategory(p.category) === this._normalizeCategory(normalizedCategory) ||
          p.costCategory === this._categoryToCostCategory(normalizedCategory))
    );

    if (normalizedCity) {
      const cityMatches = matches.filter((p) => p.city && p.city.toLowerCase().includes(normalizedCity));
      if (cityMatches.length >= 3) {
        matches = cityMatches;
      }
    }

    if (matches.length < 3) {
      const fillerAlternatives = this._generateSyntheticAlternatives(category, city, placeName);
      matches = [...matches, ...fillerAlternatives];
    }

    return matches.slice(0, 3).map((item) => ({
      id: item.placeId || `alt_${crypto.randomUUID()}`,
      placeId: item.placeId || `alt_place_${Date.now()}`,
      name: item.name,
      category: item.category || normalizedCategory || 'attraction',
      costCategory: item.costCategory || this._categoryToCostCategory(category),
      description: item.description,
      rating: item.rating || 4.6,
      userRatingsTotal: item.userRatingsTotal || 1200,
      cost: item.cost || this._estimateCostByCategory(category),
      durationMinutes: item.durationMinutes || 90,
      location: item.location || {
        lat: 26.9124,
        lng: 75.7873,
        address: `${item.name}, ${city || 'City Center'}`,
        city: city || 'Destination City',
      },
      imageUrl: item.imageUrl || this._getDefaultImageForCategory(category),
      swapReason: `Top-rated ${category || 'sight'} nearby with authentic local reviews`,
    }));
  }

  _getCatalogAutocomplete({ query, city }) {
    const q = query.toLowerCase();

    const dbMatches = CURATED_PLACES_DATABASE.filter(
      (p) => p.name.toLowerCase().includes(q) || p.category.toLowerCase().includes(q) || p.description.toLowerCase().includes(q)
    ).map((p) => ({
      placeId: p.placeId,
      name: p.name,
      address: p.location.address,
      description: p.description,
      category: p.category,
      costCategory: p.costCategory,
      estimatedCost: p.cost,
      rating: p.rating,
      location: p.location,
      imageUrl: p.imageUrl,
    }));

    const isExactMatch = dbMatches.some((m) => m.name.toLowerCase() === q);
    if (!isExactMatch) {
      const detectedCategory = this._detectCategoryFromQuery(q);
      const customEntry = {
        placeId: `custom_place_${Date.now()}`,
        name: this._titleCase(query),
        address: `${this._titleCase(query)}, ${city || 'City Center'}`,
        description: `Custom traveler stop in ${city || 'destination'}`,
        category: detectedCategory,
        costCategory: this._categoryToCostCategory(detectedCategory),
        estimatedCost: this._estimateCostByCategory(detectedCategory),
        rating: 4.5,
        location: {
          lat: 26.9124 + (Math.random() - 0.5) * 0.05,
          lng: 75.7873 + (Math.random() - 0.5) * 0.05,
          address: `${this._titleCase(query)}, ${city || 'Main Area'}`,
          city: city || 'City',
        },
        imageUrl: this._getDefaultImageForCategory(detectedCategory),
      };
      dbMatches.unshift(customEntry);
    }

    return dbMatches.slice(0, 6);
  }

  _formatGooglePlaceResult(place, category, city) {
    let photoUrl = '';
    if (place.photos && place.photos.length > 0 && envConfig.google.mapsApiKey) {
      photoUrl = `https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${place.photos[0].photo_reference}&key=${envConfig.google.mapsApiKey}`;
    } else {
      photoUrl = this._getDefaultImageForCategory(category);
    }

    const detectedCategory = place.types ? this._detectCategoryFromTypes(place.types) : category;

    return {
      id: `google_${place.place_id}`,
      placeId: place.place_id,
      name: place.name,
      category: detectedCategory,
      costCategory: this._categoryToCostCategory(detectedCategory),
      description: place.vicinity || `Popular ${detectedCategory} spot in ${city || 'the area'}`,
      rating: place.rating || 4.5,
      userRatingsTotal: place.user_ratings_total || 250,
      cost: this._estimateCostByCategory(detectedCategory, place.price_level),
      durationMinutes: 90,
      location: {
        lat: place.geometry?.location?.lat || 0,
        lng: place.geometry?.location?.lng || 0,
        address: place.vicinity || `${place.name}, ${city || ''}`,
        city: city || '',
      },
      imageUrl: photoUrl,
      swapReason: 'High customer satisfaction rating and proximity',
    };
  }

  _detectCuisineType(name, types = []) {
    const n = (name || '').toLowerCase();
    if (n.includes('thali') || n.includes('rajasthan') || n.includes('marwar')) return 'Rajasthani Heritage Thali';
    if (n.includes('chai') || n.includes('tea') || n.includes('cafe')) return 'Artisanal Tea & Cafe Bites';
    if (n.includes('kachori') || n.includes('chaat') || n.includes('sweets') || n.includes('mishthan')) return 'Authentic Sweets & Street Chaat';
    if (n.includes('mughlai') || n.includes('biryani') || n.includes('kebab') || n.includes('handi')) return 'Mughlai & Tandoor Specialties';
    if (n.includes('dosa') || n.includes('south') || n.includes('idli')) return 'South Indian Tiffin';
    if (types.includes('bakery')) return 'Bakery & Artisan Desserts';
    return 'Regional Authentic Dining';
  }

  _calculateHaversineDistanceMeters(lat1, lon1, lat2, lon2) {
    if (!lat1 || !lat2 || (lat1 === lat2 && lon1 === lon2)) {
      return 650;
    }
    const R = 6371000; // meters
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLon = (lon2 - lon1) * (Math.PI / 180);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.max(100, Math.round(R * c));
  }

  _normalizeCategory(cat) {
    if (!cat) return 'attraction';
    const c = cat.toLowerCase();
    if (['restaurant', 'cafe', 'food', 'bakery', 'bar'].includes(c)) return 'food';
    if (['monument', 'museum', 'historical', 'palace', 'fort'].includes(c)) return 'monument';
    if (['nature', 'beach', 'park', 'lake', 'garden'].includes(c)) return 'nature';
    if (['shopping', 'bazaar', 'market', 'mall'].includes(c)) return 'shopping';
    if (['culture', 'temple', 'religious', 'heritage'].includes(c)) return 'culture';
    return 'attraction';
  }

  _categoryToCostCategory(cat) {
    const norm = this._normalizeCategory(cat);
    if (norm === 'food') return 'food';
    if (['hotel', 'resort', 'stay'].includes(cat)) return 'stay';
    if (['taxi', 'transit', 'transport', 'train', 'flight'].includes(cat)) return 'transport';
    return 'activities';
  }

  _estimateCostByCategory(cat, priceLevel = 2) {
    const norm = this._normalizeCategory(cat);
    const multiplier = Math.max(1, priceLevel || 2);
    if (norm === 'food') return 350 * multiplier;
    if (norm === 'monument') return 250 * multiplier;
    if (norm === 'nature') return 100 * multiplier;
    if (norm === 'shopping') return 400 * multiplier;
    if (norm === 'culture') return 150 * multiplier;
    return 300 * multiplier;
  }

  _detectCategoryFromQuery(query) {
    const q = query.toLowerCase();
    if (q.includes('cafe') || q.includes('coffee') || q.includes('tea') || q.includes('chai')) return 'cafe';
    if (q.includes('restaurant') || q.includes('dhaba') || q.includes('food') || q.includes('bhojnalaya')) return 'restaurant';
    if (q.includes('fort') || q.includes('palace') || q.includes('mahal') || q.includes('museum')) return 'monument';
    if (q.includes('temple') || q.includes('mandir') || q.includes('church') || q.includes('ashram')) return 'culture';
    if (q.includes('beach') || q.includes('lake') || q.includes('waterfall') || q.includes('garden') || q.includes('park')) return 'nature';
    if (q.includes('bazaar') || q.includes('market') || q.includes('mall') || q.includes('shop')) return 'shopping';
    return 'attraction';
  }

  _mapCategoryToGoogleType(cat) {
    const norm = this._normalizeCategory(cat);
    if (norm === 'food') return 'restaurant';
    if (norm === 'monument') return 'tourist_attraction';
    if (norm === 'nature') return 'park';
    if (norm === 'shopping') return 'shopping_mall';
    if (norm === 'culture') return 'place_of_worship';
    return 'tourist_attraction';
  }

  _detectCategoryFromTypes(types = []) {
    if (types.includes('restaurant') || types.includes('food') || types.includes('cafe')) return 'food';
    if (types.includes('museum') || types.includes('hindu_temple') || types.includes('church')) return 'culture';
    if (types.includes('park') || types.includes('natural_feature')) return 'nature';
    if (types.includes('shopping_mall') || types.includes('store')) return 'shopping';
    return 'attraction';
  }

  _getDefaultImageForCategory(cat) {
    const norm = this._normalizeCategory(cat);
    if (norm === 'food') return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80';
    if (norm === 'monument') return 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=800&auto=format&fit=crop&q=80';
    if (norm === 'nature') return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80';
    if (norm === 'shopping') return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop&q=80';
    if (norm === 'culture') return 'https://images.unsplash.com/photo-1548013146-72479768bbaa?w=800&auto=format&fit=crop&q=80';
    return 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&auto=format&fit=crop&q=80';
  }

  _generateSyntheticAlternatives(category, city, baseName) {
    const locName = city || 'Heritage City';
    const norm = this._normalizeCategory(category);

    if (norm === 'food') {
      return [
        {
          placeId: `syn_food_1_${Date.now()}`,
          name: `${locName} Royal Dining Courtyard`,
          category: 'restaurant',
          costCategory: 'food',
          description: `Authentic regional delicacies and thali dining in central ${locName}.`,
          rating: 4.7,
          userRatingsTotal: 3400,
          cost: 550,
          city: locName,
        },
        {
          placeId: `syn_food_2_${Date.now()}`,
          name: 'The Heritage Spices Bistro',
          category: 'cafe',
          costCategory: 'food',
          description: 'Cozy artisanal cafe serving fresh brew, local sweets, and light street treats.',
          rating: 4.6,
          userRatingsTotal: 1800,
          cost: 380,
          city: locName,
        },
      ];
    }

    return [
      {
        placeId: `syn_attraction_1_${Date.now()}`,
        name: `${locName} Heritage Gateway & Gallery`,
        category: norm || 'monument',
        costCategory: 'activities',
        description: `Stunning historical architectural landmark and viewing pavilion near ${baseName || locName}.`,
        rating: 4.7,
        userRatingsTotal: 5200,
        cost: 350,
        city: locName,
      },
      {
        placeId: `syn_attraction_2_${Date.now()}`,
        name: `${locName} Cultural Crafts & Sights Center`,
        category: norm || 'attraction',
        costCategory: 'activities',
        description: 'Vibrant destination with scenic overlooks, artisanal exhibits, and cultural tours.',
        rating: 4.5,
        userRatingsTotal: 2800,
        cost: 250,
        city: locName,
      },
    ];
  }

  _titleCase(str) {
    return str
      .toLowerCase()
      .split(' ')
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ');
  }
}

const placesService = new PlacesService();

module.exports = placesService;
