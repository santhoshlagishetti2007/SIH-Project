const mongoose = require('mongoose');
const LocalFind = require('../models/local_find.model');

class MarketplaceService {
  /**
   * Fetch local vendor listings with destination, category, and search filters
   */
  async getListings({ city, category, search, regionTag, isFeatured, limit = 50, skip = 0 }) {
    if (mongoose.connection.readyState === 1) {
      try {
        const count = await LocalFind.countDocuments();
        if (count === 0) {
          await this.seedDefaults();
        }

        const query = {};

        if (city && city.trim().length > 0 && city.toLowerCase() !== 'all') {
          query['vendorLocation.city'] = new RegExp(city.trim(), 'i');
        }

        if (category && category.trim().length > 0 && category.toLowerCase() !== 'all') {
          query.category = category.trim().toLowerCase();
        }

        if (isFeatured !== undefined) {
          query.isFeatured = isFeatured === 'true' || isFeatured === true;
        }

        if (regionTag && regionTag.trim().length > 0) {
          query.regionTags = new RegExp(regionTag.trim(), 'i');
        }

        if (search && search.trim().length > 0) {
          const s = search.trim();
          query.$or = [
            { name: new RegExp(s, 'i') },
            { description: new RegExp(s, 'i') },
            { vendorName: new RegExp(s, 'i') },
            { story: new RegExp(s, 'i') },
            { regionTags: new RegExp(s, 'i') },
          ];
        }

        const listings = await LocalFind.find(query)
          .sort({ isFeatured: -1, rating: -1, createdAt: -1 })
          .skip(Number(skip))
          .limit(Number(limit));

        return listings;
      } catch (err) {
        console.warn(`[MarketplaceService] MongoDB query failed, using in-memory catalog: ${err.message}`);
      }
    }

    // In-memory catalog fallback
    return this._filterInMemoryListings({ city, category, search, regionTag, isFeatured });
  }

  /**
   * Get single listing details by ID
   */
  async getListingById(id) {
    if (mongoose.connection.readyState === 1) {
      try {
        const item = await LocalFind.findById(id);
        if (item) return item;
      } catch (err) {
        console.warn(`[MarketplaceService] MongoDB findById error: ${err.message}`);
      }
    }

    const seeds = LocalFind.getSeedData();
    return seeds.find((s) => s._id === id || s.name.toLowerCase().includes((id || '').toLowerCase())) || seeds[0];
  }

  /**
   * Create a new vendor listing
   */
  async createListing(data) {
    const payload = {
      ...data,
      photos: Array.isArray(data.photos) && data.photos.length > 0
        ? data.photos
        : ['https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=800&auto=format&fit=crop&q=80'],
      regionTags: Array.isArray(data.regionTags)
        ? data.regionTags
        : (data.regionTags ? data.regionTags.split(',').map((t) => t.trim()) : ['Handmade']),
    };

    if (mongoose.connection.readyState === 1) {
      const newListing = new LocalFind(payload);
      return await newListing.save();
    }

    return {
      id: `local_find_${Date.now()}`,
      ...payload,
      createdAt: new Date().toISOString(),
    };
  }

  /**
   * Update an existing listing
   */
  async updateListing(id, data) {
    if (mongoose.connection.readyState === 1) {
      return await LocalFind.findByIdAndUpdate(id, data, { new: true });
    }
    return { id, ...data };
  }

  /**
   * Delete a listing
   */
  async deleteListing(id) {
    if (mongoose.connection.readyState === 1) {
      return await LocalFind.findByIdAndDelete(id);
    }
    return { id, deleted: true };
  }

  /**
   * Pre-seed default artisan product catalog
   */
  async seedDefaults() {
    if (mongoose.connection.readyState === 1) {
      const seeds = LocalFind.getSeedData();
      await LocalFind.deleteMany({});
      return await LocalFind.insertMany(seeds);
    }
    return LocalFind.getSeedData();
  }

  _filterInMemoryListings({ city, category, search, regionTag, isFeatured }) {
    let list = LocalFind.getSeedData().map((item, index) => ({
      id: `seed_find_${index + 1}`,
      ...item,
    }));

    if (city && city.trim().length > 0 && city.toLowerCase() !== 'all') {
      const c = city.trim().toLowerCase();
      list = list.filter((item) =>
        item.vendorLocation.city.toLowerCase().includes(c) ||
        item.regionTags.some((t) => t.toLowerCase().includes(c))
      );
    }

    if (category && category.trim().length > 0 && category.toLowerCase() !== 'all') {
      const cat = category.trim().toLowerCase();
      list = list.filter((item) => item.category.toLowerCase() === cat);
    }

    if (isFeatured !== undefined) {
      const feat = isFeatured === 'true' || isFeatured === true;
      list = list.filter((item) => item.isFeatured === feat);
    }

    if (regionTag && regionTag.trim().length > 0) {
      const tag = regionTag.trim().toLowerCase();
      list = list.filter((item) => item.regionTags.some((t) => t.toLowerCase().includes(tag)));
    }

    if (search && search.trim().length > 0) {
      const s = search.trim().toLowerCase();
      list = list.filter((item) =>
        item.name.toLowerCase().includes(s) ||
        item.description.toLowerCase().includes(s) ||
        item.vendorName.toLowerCase().includes(s) ||
        item.story.toLowerCase().includes(s) ||
        item.regionTags.some((t) => t.toLowerCase().includes(s))
      );
    }

    return list;
  }
}

const marketplaceService = new MarketplaceService();

module.exports = marketplaceService;
