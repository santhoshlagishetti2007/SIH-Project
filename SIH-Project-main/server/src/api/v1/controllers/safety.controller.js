const safetyService = require('../../../services/safety.service');

const safetyController = {
  /**
   * Trigger emergency SOS alert
   * POST /api/v1/safety/sos-trigger
   */
  async triggerSos(req, res, next) {
    try {
      const { userId, userName, userPhone, location, emergencyContacts, autoDialNumber } = req.body;

      const result = await safetyService.triggerSos({
        userId: userId || req.user?.uid || 'anonymous_user',
        userName: userName || req.user?.displayName || 'Traveler',
        userPhone: userPhone || req.user?.phone || '',
        location: location || { lat: 26.9124, lng: 75.7873 },
        emergencyContacts: emergencyContacts || req.user?.emergencyContacts || [],
        autoDialNumber: autoDialNumber || '112',
      });

      return res.status(201).json({
        success: true,
        message: 'Emergency SOS alert activated and dispatched to contacts',
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Start Live Trip Location Sharing
   * POST /api/v1/safety/share-trip/start
   */
  async startTripShare(req, res, next) {
    try {
      const { userId, userName, userPhone, location, emergencyContacts, durationHours } = req.body;

      const result = await safetyService.startTripShare({
        userId: userId || req.user?.uid || 'anonymous_user',
        userName: userName || req.user?.displayName || 'Traveler',
        userPhone: userPhone || req.user?.phone || '',
        location: location || { lat: 26.9124, lng: 75.7873 },
        emergencyContacts: emergencyContacts || [],
        durationHours: durationHours || 12,
      });

      return res.status(201).json({
        success: true,
        message: 'Live trip location sharing session started',
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Periodic live location ping update
   * POST /api/v1/safety/share-trip/update
   */
  async updateLiveLocation(req, res, next) {
    try {
      const { sessionId, lat, lng, speed, battery, address } = req.body;

      if (!sessionId || lat === undefined || lng === undefined) {
        return res.status(400).json({
          success: false,
          message: 'sessionId, lat, and lng are required',
          timestamp: new Date().toISOString(),
        });
      }

      const updated = await safetyService.updateLiveLocation({
        sessionId,
        lat: parseFloat(lat),
        lng: parseFloat(lng),
        speed: speed ? parseFloat(speed) : 0,
        battery: battery ? parseInt(battery, 10) : 80,
        address,
      });

      return res.status(200).json({
        success: true,
        message: 'Live location updated successfully',
        data: updated,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Stop active sharing or SOS session
   * POST /api/v1/safety/share-trip/stop
   */
  async stopSession(req, res, next) {
    try {
      const { sessionId, userId } = req.body;

      if (!sessionId) {
        return res.status(400).json({
          success: false,
          message: 'sessionId is required to stop session',
          timestamp: new Date().toISOString(),
        });
      }

      const stopped = await safetyService.stopSession({
        sessionId,
        userId: userId || req.user?.uid,
      });

      return res.status(200).json({
        success: true,
        message: 'Location sharing session stopped',
        data: stopped,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get active session by ID (used by web map viewer)
   * GET /api/v1/safety/session/:sessionId
   */
  async getSession(req, res, next) {
    try {
      const { sessionId } = req.params;
      const session = await safetyService.getSession(sessionId);

      if (!session) {
        return res.status(404).json({
          success: false,
          message: 'Safety session not found',
          timestamp: new Date().toISOString(),
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Safety session retrieved',
        data: session,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = safetyController;
