const envConfig = require('../config/env.config');
const { TransportRateConfig, DEFAULT_CITY_RATES } = require('../models/transport_rate.model');

/**
 * Service to compute route distances, travel durations, and multi-tier public transport costs
 */
class RoutesService {
  /**
   * Check if Google Maps / Routes API key is available
   */
  hasGoogleMapsKey() {
    return Boolean(
      envConfig.google.mapsApiKey &&
        envConfig.google.mapsApiKey !== 'your_google_maps_api_key_here' &&
        envConfig.google.mapsApiKey.length > 10
    );
  }

  /**
   * Get transport rate table for a city from MongoDB (with fallback to default seed)
   */
  async getCityRateConfig(city) {
    const normalizedCity = (city || 'Default').trim();

    try {
      const mongoose = require('mongoose');
      if (mongoose.connection.readyState === 1) {
        // 1. Try exact match in MongoDB
        let config = await TransportRateConfig.findOne({
          city: { $regex: new RegExp(`^${normalizedCity}$`, 'i') },
          isActive: true,
        }).maxTimeMS(2000);

        if (!config) {
          // 2. Try 'Default' in MongoDB
          config = await TransportRateConfig.findOne({ city: 'Default', isActive: true }).maxTimeMS(2000);
        }

        if (config) {
          return config.toObject();
        }
      }
    } catch (err) {
      console.warn(`[RoutesService] MongoDB fetch error for transport rate, using memory default: ${err.message}`);
    }

    // 3. Fallback to in-memory default seed
    const match = DEFAULT_CITY_RATES.find(
      (r) => r.city.toLowerCase() === normalizedCity.toLowerCase()
    );
    return match || DEFAULT_CITY_RATES.find((r) => r.city === 'Default') || DEFAULT_CITY_RATES[0];
  }

  /**
   * Calculate travel distance (km) and travel duration (minutes) between two stops
   */
  async calculateDistanceMatrix({ origin, destination, mode = 'DRIVE' }) {
    // 1. Try Google Distance Matrix / Routes API if key is present
    if (this.hasGoogleMapsKey()) {
      try {
        const googleResult = await this._queryGoogleDistanceMatrix({ origin, destination, mode });
        if (googleResult) {
          return googleResult;
        }
      } catch (err) {
        console.warn(`[RoutesService] Google Distance Matrix failed, falling back to urban calculation: ${err.message}`);
      }
    }

    // 2. Urban road distance & speed calculation fallback
    return this._calculateUrbanDistanceFallback(origin, destination);
  }

  /**
   * Compute transit options between two consecutive stops for a city
   */
  async computeLegTransitOptions({ fromStop, toStop, city = 'Jaipur', selectedMode }) {
    const origin = fromStop.location || { lat: 0, lng: 0, address: fromStop.name };
    const destination = toStop.location || { lat: 0, lng: 0, address: toStop.name };

    const { distanceKm } = await this.calculateDistanceMatrix({ origin, destination });
    const rateConfig = await this.getCityRateConfig(city);
    const modesConfig = rateConfig.modes || {};

    const availableModes = [];

    // 1. Walking
    const walkConfig = modesConfig.walking || { baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 4.5, isAvailable: true };
    if (walkConfig.isAvailable) {
      const walkMinutes = Math.max(3, Math.round((distanceKm / (walkConfig.speedKmh || 4.5)) * 60));
      availableModes.push({
        mode: 'walk',
        label: 'Walk',
        icon: 'directions_walk',
        cost: 0,
        durationMinutes: walkMinutes,
        isAvailable: distanceKm <= 3.5,
        isRecommended: distanceKm <= 1.2,
        description: `${distanceKm.toFixed(1)} km pedestrian walk`,
      });
    }

    // 2. Auto-rickshaw
    const autoConfig = modesConfig.auto || { baseFare: 30, perKmRate: 15.0, minFare: 30, speedKmh: 22, isAvailable: true };
    if (autoConfig.isAvailable) {
      const autoMinutes = Math.max(5, Math.round((distanceKm / (autoConfig.speedKmh || 22)) * 60) + 4);
      const autoFare = Math.round(
        Math.max(
          autoConfig.minFare || 30,
          (autoConfig.baseFare || 30) + Math.max(0, distanceKm - 1.5) * (autoConfig.perKmRate || 15)
        )
      );
      availableModes.push({
        mode: 'auto',
        label: 'Auto-Rickshaw',
        icon: 'electric_rickshaw',
        cost: autoFare,
        durationMinutes: autoMinutes,
        isAvailable: true,
        isRecommended: distanceKm > 1.2 && distanceKm <= 7.0,
        description: `Local 3-wheeler auto (~₹${autoConfig.perKmRate}/km)`,
      });
    }

    // 3. City Bus
    const busConfig = modesConfig.bus || { baseFare: 10, perKmRate: 3.5, minFare: 10, speedKmh: 18, isAvailable: true };
    if (busConfig.isAvailable) {
      const busMinutes = Math.max(8, Math.round((distanceKm / (busConfig.speedKmh || 18)) * 60) + 7);
      const busFare = Math.round(
        Math.max(
          busConfig.minFare || 10,
          (busConfig.baseFare || 10) + Math.max(0, distanceKm - 2.0) * (busConfig.perKmRate || 3.5)
        )
      );
      availableModes.push({
        mode: 'bus',
        label: 'City Bus',
        icon: 'directions_bus',
        cost: busFare,
        durationMinutes: busMinutes,
        isAvailable: distanceKm >= 1.0,
        isRecommended: distanceKm > 7.0 && !modesConfig.metro?.isAvailable,
        description: 'Public transit bus route',
      });
    }

    // 4. Metro Rail (if available in city)
    const metroConfig = modesConfig.metro || { baseFare: 15, perKmRate: 4.0, minFare: 15, speedKmh: 32, isAvailable: false };
    if (metroConfig.isAvailable) {
      const metroMinutes = Math.max(6, Math.round((distanceKm / (metroConfig.speedKmh || 32)) * 60) + 5);
      const metroFare = Math.round(
        Math.max(
          metroConfig.minFare || 12,
          (metroConfig.baseFare || 12) + Math.max(0, distanceKm - 2.0) * (metroConfig.perKmRate || 3.5)
        )
      );
      availableModes.push({
        mode: 'metro',
        label: 'Metro Rail',
        icon: 'subway',
        cost: metroFare,
        durationMinutes: metroMinutes,
        isAvailable: distanceKm >= 1.5,
        isRecommended: distanceKm > 3.0,
        description: 'Rapid transit network',
      });
    }

    // 5. Cab / Taxi
    const cabConfig = modesConfig.cab || { baseFare: 60, perKmRate: 20.0, minFare: 60, speedKmh: 25, isAvailable: true };
    if (cabConfig.isAvailable) {
      const cabMinutes = Math.max(5, Math.round((distanceKm / (cabConfig.speedKmh || 25)) * 60) + 3);
      const cabFare = Math.round(
        Math.max(
          cabConfig.minFare || 60,
          (cabConfig.baseFare || 60) + Math.max(0, distanceKm - 2.0) * (cabConfig.perKmRate || 20)
        )
      );
      availableModes.push({
        mode: 'cab',
        label: 'Cab / Taxi',
        icon: 'local_taxi',
        cost: cabFare,
        durationMinutes: cabMinutes,
        isAvailable: true,
        isRecommended: distanceKm > 10.0,
        description: 'AC ride-hail / taxi',
      });
    }

    // Determine default/selected mode
    let chosenMode = selectedMode;
    if (!chosenMode || !availableModes.some((m) => m.mode === chosenMode)) {
      const recommended = availableModes.find((m) => m.isRecommended && m.isAvailable);
      chosenMode = recommended ? recommended.mode : (availableModes[1]?.mode || 'auto');
    }

    const selectedOption = availableModes.find((m) => m.mode === chosenMode) || availableModes[0];

    return {
      fromStopId: fromStop.id,
      toStopId: toStop.id,
      fromStopName: fromStop.name,
      toStopName: toStop.name,
      distanceKm: Number(distanceKm.toFixed(2)),
      durationMinutes: selectedOption.durationMinutes,
      selectedMode: chosenMode,
      estimatedCost: selectedOption.cost,
      modes: availableModes,
    };
  }

  /**
   * Calculate all transit legs for a list of consecutive stops
   */
  async calculateTransitLegsForStops(stops = [], city = 'Jaipur') {
    if (!Array.isArray(stops) || stops.length < 2) {
      return [];
    }

    const legs = [];
    for (let i = 0; i < stops.length - 1; i++) {
      const fromStop = stops[i];
      const toStop = stops[i + 1];
      const leg = await this.computeLegTransitOptions({
        fromStop,
        toStop,
        city,
      });
      legs.push(leg);
    }

    return legs;
  }

  /**
   * Query Google Distance Matrix API
   * @private
   */
  async _queryGoogleDistanceMatrix({ origin, destination }) {
    const mapsKey = envConfig.google.mapsApiKey;
    let originsParam;
    let destsParam;

    if (origin.lat && origin.lng && origin.lat !== 0) {
      originsParam = `${origin.lat},${origin.lng}`;
    } else {
      originsParam = encodeURIComponent(origin.address || origin.name || 'Origin');
    }

    if (destination.lat && destination.lng && destination.lat !== 0) {
      destsParam = `${destination.lat},${destination.lng}`;
    } else {
      destsParam = encodeURIComponent(destination.address || destination.name || 'Destination');
    }

    const url = `https://maps.googleapis.com/maps/api/distancematrix/json?origins=${originsParam}&destinations=${destsParam}&mode=driving&key=${mapsKey}`;

    const res = await fetch(url);
    const data = await res.json();

    if (data.status === 'OK' && data.rows?.[0]?.elements?.[0]?.status === 'OK') {
      const element = data.rows[0].elements[0];
      const distanceMeters = element.distance?.value || 3000;
      const durationSeconds = element.duration?.value || 600;

      return {
        distanceKm: Number((distanceMeters / 1000).toFixed(2)),
        durationMinutes: Math.max(3, Math.round(durationSeconds / 60)),
      };
    }

    return null;
  }

  /**
   * Accurate Haversine urban distance calculation with road winding factor
   * @private
   */
  _calculateUrbanDistanceFallback(origin, destination) {
    let lat1 = origin.lat;
    let lon1 = origin.lng;
    let lat2 = destination.lat;
    let lon2 = destination.lng;

    // If coordinates are missing or identical (0,0), synthesize a realistic city stop distance
    if (!lat1 || !lat2 || (lat1 === lat2 && lon1 === lon2)) {
      const pseudoDist = 2.5 + (Math.abs(this._stringHash(origin.address || origin.name || 'A') - this._stringHash(destination.address || destination.name || 'B')) % 45) / 10;
      return {
        distanceKm: Number(pseudoDist.toFixed(2)),
        durationMinutes: Math.max(5, Math.round((pseudoDist / 20) * 60) + 4),
      };
    }

    // Haversine formula
    const R = 6371; // Earth radius in km
    const dLat = this._deg2rad(lat2 - lat1);
    const dLon = this._deg2rad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this._deg2rad(lat1)) * Math.cos(this._deg2rad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const straightLineKm = R * c;

    // Urban road networks are ~1.28x longer than straight-line geodesics
    const roadTortuosity = 1.28;
    const distanceKm = Math.max(0.4, Number((straightLineKm * roadTortuosity).toFixed(2)));

    // Urban traffic speed estimate ~20 km/h + 3 min signal buffer
    const durationMinutes = Math.max(3, Math.round((distanceKm / 20) * 60) + 3);

    return {
      distanceKm,
      durationMinutes,
    };
  }

  _deg2rad(deg) {
    return deg * (Math.PI / 180);
  }

  _stringHash(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = (hash << 5) - hash + str.charCodeAt(i);
      hash |= 0;
    }
    return Math.abs(hash);
  }
}

const routesService = new RoutesService();

module.exports = routesService;
