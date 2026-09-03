const mongoose = require('mongoose');
const { TransportRateConfig, DEFAULT_CITY_RATES } = require('../../../models/transport_rate.model');

// In-memory fallback cache for test/dev mode when MongoDB is disconnected
const memoryRateStore = new Map(DEFAULT_CITY_RATES.map((r) => [r.city.toLowerCase(), { ...r }]));

/**
 * Seed default city rate tables if database is connected and empty
 */
const ensureDefaultCityRates = async () => {
  if (mongoose.connection.readyState === 1) {
    try {
      const count = await TransportRateConfig.countDocuments();
      if (count === 0) {
        for (const rate of DEFAULT_CITY_RATES) {
          await TransportRateConfig.findOneAndUpdate(
            { city: rate.city },
            rate,
            { upsert: true, new: true }
          );
        }
      }
    } catch (err) {
      console.warn(`[AdminController] Error seeding default city rates: ${err.message}`);
    }
  }
};

const adminController = {
  /**
   * Get all city transport rate tables
   * GET /api/v1/admin/transport-rates
   */
  async getTransportRates(_req, res, next) {
    try {
      if (mongoose.connection.readyState === 1) {
        await ensureDefaultCityRates();
        const rates = await TransportRateConfig.find().sort({ city: 1 });
        return res.status(200).json({
          success: true,
          message: 'City transport rates retrieved successfully',
          data: rates,
          timestamp: new Date().toISOString(),
        });
      }

      // Memory fallback
      const rates = Array.from(memoryRateStore.values());
      return res.status(200).json({
        success: true,
        message: 'City transport rates retrieved successfully',
        data: rates,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get transport rate table for a specific city
   * GET /api/v1/admin/transport-rates/:city
   */
  async getTransportRatesByCity(req, res, next) {
    try {
      const { city } = req.params;

      if (mongoose.connection.readyState === 1) {
        let config = await TransportRateConfig.findOne({
          city: { $regex: new RegExp(`^${city}$`, 'i') },
        });

        if (!config) {
          config = await TransportRateConfig.findOne({ city: 'Default' });
          if (!config) {
            await ensureDefaultCityRates();
            config = await TransportRateConfig.findOne({ city: 'Default' });
          }
        }

        return res.status(200).json({
          success: true,
          message: `Transport rates for ${city} retrieved successfully`,
          data: config,
          timestamp: new Date().toISOString(),
        });
      }

      // Memory fallback
      const match = memoryRateStore.get(city.toLowerCase()) || memoryRateStore.get('default');
      return res.status(200).json({
        success: true,
        message: `Transport rates for ${city} retrieved successfully`,
        data: match,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Create or update transport rate table for a city
   * PUT /api/v1/admin/transport-rates/:city
   */
  async updateTransportRatesByCity(req, res, next) {
    try {
      const { city } = req.params;
      const { modes, currency, isActive } = req.body;

      const formattedCity = city.charAt(0).toUpperCase() + city.slice(1).toLowerCase();

      if (mongoose.connection.readyState === 1) {
        const updateData = {};
        if (modes) updateData.modes = modes;
        if (currency) updateData.currency = currency;
        if (isActive !== undefined) updateData.isActive = isActive;

        const updatedConfig = await TransportRateConfig.findOneAndUpdate(
          { city: { $regex: new RegExp(`^${city}$`, 'i') } },
          {
            $set: {
              city: formattedCity,
              ...updateData,
            },
          },
          { upsert: true, new: true, runValidators: true }
        );

        return res.status(200).json({
          success: true,
          message: `Transport rate configuration for ${city} saved to MongoDB`,
          data: updatedConfig,
          timestamp: new Date().toISOString(),
        });
      }

      // Memory fallback update
      const existing = memoryRateStore.get(city.toLowerCase()) || {
        city: formattedCity,
        currency: currency || 'INR',
        isActive: isActive !== undefined ? isActive : true,
        modes: {},
      };

      const updated = {
        ...existing,
        city: formattedCity,
        currency: currency || existing.currency,
        isActive: isActive !== undefined ? isActive : existing.isActive,
        modes: {
          ...existing.modes,
          ...(modes || {}),
        },
      };

      memoryRateStore.set(city.toLowerCase(), updated);

      return res.status(200).json({
        success: true,
        message: `Transport rate configuration for ${city} saved to MongoDB`,
        data: updated,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Reset all city rate tables to default seed
   * POST /api/v1/admin/transport-rates/reset-defaults
   */
  async resetDefaultRates(_req, res, next) {
    try {
      if (mongoose.connection.readyState === 1) {
        await TransportRateConfig.deleteMany({});
        for (const rate of DEFAULT_CITY_RATES) {
          await TransportRateConfig.create(rate);
        }

        const rates = await TransportRateConfig.find().sort({ city: 1 });

        return res.status(200).json({
          success: true,
          message: 'City transport rates reset to defaults successfully',
          data: rates,
          timestamp: new Date().toISOString(),
        });
      }

      // Reset memory store
      memoryRateStore.clear();
      for (const r of DEFAULT_CITY_RATES) {
        memoryRateStore.set(r.city.toLowerCase(), { ...r });
      }

      return res.status(200).json({
        success: true,
        message: 'City transport rates reset to defaults successfully',
        data: Array.from(memoryRateStore.values()),
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = adminController;
