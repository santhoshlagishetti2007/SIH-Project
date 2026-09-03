const mongoose = require('mongoose');

/**
 * Places Server-Side 24-Hour TTL Cache Schema
 */
const PlacesCacheSchema = new mongoose.Schema(
  {
    cacheKey: {
      type: String,
      required: true,
      unique: true,
      index: true,
      trim: true,
    },
    category: {
      type: String,
      required: true,
      default: 'eat_nearby',
      index: true,
    },
    location: {
      lat: { type: Number, default: 0 },
      lng: { type: Number, default: 0 },
      city: { type: String, default: '' },
    },
    data: {
      type: mongoose.Schema.Types.Mixed,
      required: true,
    },
    createdAt: {
      type: Date,
      default: Date.now,
      expires: 86400, // 24 hours TTL in seconds (86,400s = 1 day)
    },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      transform: (_doc, ret) => {
        ret.id = ret._id.toString();
        delete ret.__v;
        return ret;
      },
    },
  }
);

// In-memory cache map for high performance
const inMemoryCache = new Map();
const MEMORY_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours

/**
 * Static helper to get cached place results or fetch and save
 */
PlacesCacheSchema.statics.getOrSet = async function (cacheKey, fetchFunction, metadata = {}) {
  const now = Date.now();

  // 1. Check in-memory cache
  if (inMemoryCache.has(cacheKey)) {
    const memoryItem = inMemoryCache.get(cacheKey);
    if (now - memoryItem.timestamp < MEMORY_TTL_MS) {
      return { data: memoryItem.data, fromCache: true, cacheSource: 'memory' };
    }
    inMemoryCache.delete(cacheKey);
  }

  // 2. Check MongoDB cache (if connected)
  if (mongoose.connection.readyState === 1) {
    try {
      const cached = await this.findOne({ cacheKey }).maxTimeMS(2000);
      if (cached && cached.data) {
        // Populate memory cache
        inMemoryCache.set(cacheKey, { data: cached.data, timestamp: now });
        return { data: cached.data, fromCache: true, cacheSource: 'mongodb' };
      }
    } catch (err) {
      console.warn(`[PlacesCache] MongoDB read error: ${err.message}`);
    }
  }

  // 3. Cache miss: execute fetchFunction
  const freshData = await fetchFunction();

  // 4. Save to in-memory cache
  inMemoryCache.set(cacheKey, { data: freshData, timestamp: now });

  // 5. Save to MongoDB with 24h TTL (if connected)
  if (mongoose.connection.readyState === 1) {
    try {
      await this.findOneAndUpdate(
        { cacheKey },
        {
          cacheKey,
          category: metadata.category || 'eat_nearby',
          location: metadata.location || { lat: 0, lng: 0, city: '' },
          data: freshData,
          createdAt: new Date(),
        },
        { upsert: true, new: true }
      );
    } catch (err) {
      console.warn(`[PlacesCache] MongoDB write error: ${err.message}`);
    }
  }

  return { data: freshData, fromCache: false, cacheSource: 'live' };
};

const PlacesCache = mongoose.model('PlacesCache', PlacesCacheSchema);

module.exports = PlacesCache;
