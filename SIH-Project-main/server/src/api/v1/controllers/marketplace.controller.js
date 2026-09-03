const marketplaceService = require('../../../services/marketplace.service');

const marketplaceController = {
  /**
   * Get all local vendor listings with filters
   * GET /api/v1/marketplace/finds
   */
  async getListings(req, res, next) {
    try {
      const { city, category, search, regionTag, isFeatured, limit, skip } = req.query;

      const listings = await marketplaceService.getListings({
        city,
        category,
        search,
        regionTag,
        isFeatured,
        limit: limit ? parseInt(limit, 10) : 50,
        skip: skip ? parseInt(skip, 10) : 0,
      });

      return res.status(200).json({
        success: true,
        message: 'Local vendor listings retrieved successfully',
        count: listings.length,
        data: listings,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get listing by ID
   * GET /api/v1/marketplace/finds/:id
   */
  async getListingById(req, res, next) {
    try {
      const { id } = req.params;
      const listing = await marketplaceService.getListingById(id);

      if (!listing) {
        return res.status(404).json({
          success: false,
          message: 'Local find item not found',
          timestamp: new Date().toISOString(),
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Local find item retrieved successfully',
        data: listing,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Create a new vendor listing
   * POST /api/v1/marketplace/finds
   */
  async createListing(req, res, next) {
    try {
      const listingData = req.body;

      if (!listingData.name || !listingData.price || !listingData.vendorName) {
        return res.status(400).json({
          success: false,
          message: 'Item name, price, and vendor name are required fields',
          timestamp: new Date().toISOString(),
        });
      }

      const newListing = await marketplaceService.createListing(listingData);

      return res.status(201).json({
        success: true,
        message: 'Vendor listing published successfully',
        data: newListing,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Update a vendor listing
   * PUT /api/v1/marketplace/finds/:id
   */
  async updateListing(req, res, next) {
    try {
      const { id } = req.params;
      const updated = await marketplaceService.updateListing(id, req.body);

      return res.status(200).json({
        success: true,
        message: 'Vendor listing updated successfully',
        data: updated,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Delete a vendor listing
   * DELETE /api/v1/marketplace/finds/:id
   */
  async deleteListing(req, res, next) {
    try {
      const { id } = req.params;
      await marketplaceService.deleteListing(id);

      return res.status(200).json({
        success: true,
        message: 'Vendor listing deleted successfully',
        data: { id },
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Reset/Seed default listings
   * POST /api/v1/marketplace/finds/seed-defaults
   */
  async seedDefaults(_req, res, next) {
    try {
      const seeded = await marketplaceService.seedDefaults();

      return res.status(200).json({
        success: true,
        message: 'Default local finds seeded successfully',
        count: seeded.length,
        data: seeded,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = marketplaceController;
