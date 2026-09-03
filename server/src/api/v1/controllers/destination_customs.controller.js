const destinationCustomsService = require('../../../services/destination_customs.service');

const destinationCustomsController = {
  /**
   * Get customs and etiquette for a specific destination
   * GET /api/v1/destinations/customs/:destination
   */
  async getDestinationCustoms(req, res, next) {
    try {
      const { destination } = req.params;
      const customs = await destinationCustomsService.getDestinationCustoms(destination || 'Jaipur');

      return res.status(200).json({
        success: true,
        message: `Cultural guide and etiquette for ${destination} retrieved successfully`,
        data: customs,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Update destination customs (Admin)
   * PUT /api/v1/destinations/customs/:destination
   */
  async updateDestinationCustoms(req, res, next) {
    try {
      const { destination } = req.params;
      const updated = await destinationCustomsService.updateDestinationCustoms(destination, req.body);

      return res.status(200).json({
        success: true,
        message: `Cultural guide for ${destination} updated successfully`,
        data: updated,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * List all destination customs guides
   * GET /api/v1/destinations/customs
   */
  async getAllDestinations(req, res, next) {
    try {
      const list = await destinationCustomsService.getAllDestinationsCustomsSummary();

      return res.status(200).json({
        success: true,
        message: 'Destination customs summaries retrieved',
        count: list.length,
        data: list,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = destinationCustomsController;
