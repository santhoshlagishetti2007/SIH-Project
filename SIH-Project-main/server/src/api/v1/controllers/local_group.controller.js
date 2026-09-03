const localGroupService = require('../../../services/local_group.service');

const localGroupController = {
  /**
   * Get community groups
   * GET /api/v1/groups?city=Jaipur&category=heritage_walk&status=verified&search=walk
   */
  async getGroups(req, res, next) {
    try {
      const { city, category, status, search } = req.query;

      const groups = await localGroupService.getGroups({
        city: city || 'all',
        category: category || 'all',
        status: status || 'verified',
        search: search || '',
      });

      return res.status(200).json({
        success: true,
        message: 'Community groups retrieved successfully',
        count: groups.length,
        data: groups,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get group by ID
   * GET /api/v1/groups/:id
   */
  async getGroupById(req, res, next) {
    try {
      const { id } = req.params;
      const group = await localGroupService.getGroupById(id);

      if (!group) {
        return res.status(404).json({
          success: false,
          message: 'Local community group not found',
          timestamp: new Date().toISOString(),
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Community group details retrieved',
        data: group,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Submit new community group (starts as 'pending' verification)
   * POST /api/v1/groups
   */
  async createGroup(req, res, next) {
    try {
      const { name, city, description, category, leadName, leadPhone, leadEmail, leadWhatsapp, meetingPoint, schedule, coverPhoto, tags, documentType, documentId } = req.body;

      if (!name || !description || !leadName) {
        return res.status(400).json({
          success: false,
          message: 'name, description, and leadName are required',
          timestamp: new Date().toISOString(),
        });
      }

      const group = await localGroupService.createGroup({
        name,
        city,
        description,
        category,
        leadName,
        leadPhone,
        leadEmail,
        leadWhatsapp,
        meetingPoint,
        schedule,
        coverPhoto,
        tags,
        documentType,
        documentId,
      });

      return res.status(201).json({
        success: true,
        message: 'Community group submitted for admin verification',
        data: group,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Admin: Approve or Reject a Community Group
   * PATCH /api/v1/groups/:id/verify
   */
  async verifyGroup(req, res, next) {
    try {
      const { id } = req.params;
      const { status, reviewerNotes, verifiedBy } = req.body;

      if (!status || !['verified', 'rejected', 'pending'].includes(status)) {
        return res.status(400).json({
          success: false,
          message: 'Status must be verified, rejected, or pending',
          timestamp: new Date().toISOString(),
        });
      }

      const updated = await localGroupService.approveOrRejectGroup(id, {
        status,
        reviewerNotes,
        verifiedBy: verifiedBy || req.user?.uid || 'admin_user',
      });

      if (!updated) {
        return res.status(404).json({
          success: false,
          message: 'Local community group not found',
          timestamp: new Date().toISOString(),
        });
      }

      return res.status(200).json({
        success: true,
        message: `Community group marked as ${status}`,
        data: updated,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Traveler request to join / message group lead
   * POST /api/v1/groups/:id/join
   */
  async requestToJoinGroup(req, res, next) {
    try {
      const { id } = req.params;
      const { userId, userName, userPhone, message } = req.body;

      const result = await localGroupService.requestToJoinGroup(id, {
        userId: userId || req.user?.uid || 'traveler_user',
        userName: userName || req.user?.displayName || 'Traveler',
        userPhone: userPhone || req.user?.phone || '',
        message: message || 'Hi! I would love to join your upcoming community walk.',
      });

      if (!result) {
        return res.status(404).json({
          success: false,
          message: 'Local community group not found',
          timestamp: new Date().toISOString(),
        });
      }

      return res.status(200).json({
        success: true,
        message: result.message,
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Admin: List pending groups awaiting verification
   * GET /api/v1/groups/admin/pending
   */
  async getAdminPendingGroups(_req, res, next) {
    try {
      const pendingGroups = await localGroupService.getAdminPendingGroups();

      return res.status(200).json({
        success: true,
        message: 'Pending community groups awaiting review',
        count: pendingGroups.length,
        data: pendingGroups,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = localGroupController;
