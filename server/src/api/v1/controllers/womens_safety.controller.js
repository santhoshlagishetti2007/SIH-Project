const womensSafetyService = require('../../../services/womens_safety.service');

const womensSafetyController = {
  /**
   * Get city safety guide
   * GET /api/v1/safety/women/guide/:city
   */
  async getCitySafetyGuide(req, res, next) {
    try {
      const { city } = req.params;
      const guide = await womensSafetyService.getCitySafetyGuide(city || 'Jaipur');

      return res.status(200).json({
        success: true,
        message: `Safety guide for ${city} retrieved successfully`,
        data: guide,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Update city safety guide (Admin)
   * PUT /api/v1/safety/women/guide/:city
   */
  async updateCitySafetyGuide(req, res, next) {
    try {
      const { city } = req.params;
      const updated = await womensSafetyService.updateCitySafetyGuide(city, req.body);

      return res.status(200).json({
        success: true,
        message: `Safety guide for ${city} updated successfully`,
        data: updated,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get nearest police stations & hospitals
   * GET /api/v1/safety/women/emergency-nearby
   */
  async getNearestEmergencyServices(req, res, next) {
    try {
      const { lat, lng, city, type } = req.query;

      const services = await womensSafetyService.getNearestEmergencyServices({
        lat: lat ? parseFloat(lat) : 26.9124,
        lng: lng ? parseFloat(lng) : 75.7873,
        city: city || 'Jaipur',
        type: type || 'all',
      });

      return res.status(200).json({
        success: true,
        message: 'Nearest emergency services retrieved successfully',
        count: services.length,
        data: services,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get women-verified stays and certified guides
   * GET /api/v1/safety/women/verified-stays-guides
   */
  async getWomenVerifiedStaysAndGuides(req, res, next) {
    try {
      const { city, category } = req.query;

      const listings = await womensSafetyService.getWomenVerifiedStaysAndGuides({
        city: city || 'Jaipur',
        category: category || 'all',
      });

      return res.status(200).json({
        success: true,
        message: 'Women-verified stays and certified guides retrieved',
        count: listings.length,
        data: listings,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = womensSafetyController;
