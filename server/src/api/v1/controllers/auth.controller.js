const User = require('../../../models/user.model');

/**
 * Controller for Authentication and Profile Management
 */
const authController = {
  /**
   * Sync Firebase User with MongoDB (Idempotent upsert)
   * POST /api/v1/auth/sync-profile
   */
  syncProfile: async (req, res, next) => {
    try {
      const uid = req.user.uid;
      const {
        email = req.user.email || '',
        displayName = req.user.name || 'Traveler',
        photoUrl = req.user.picture || null,
        phone = req.user.phone || '',
        authProvider = req.user.firebase?.sign_in_provider || 'password',
        homeCity,
        preferredLanguage,
        travelerType,
        emergencyContacts,
        isOnboarded,
      } = req.body;

      let user = await User.findOne({ uid });

      if (!user) {
        user = new User({
          uid,
          email: email.toLowerCase(),
          displayName: displayName || 'Traveler',
          photoUrl: photoUrl || null,
          phone: phone || '',
          authProvider: authProvider || 'password',
          homeCity: homeCity || '',
          preferredLanguage: preferredLanguage || 'en',
          travelerType: travelerType || 'solo',
          emergencyContacts: emergencyContacts || [],
          isOnboarded: isOnboarded !== undefined ? isOnboarded : false,
        });

        await user.save();

        return res.status(201).json({
          success: true,
          message: 'User profile created in MongoDB successfully',
          data: user,
          timestamp: new Date().toISOString(),
        });
      }

      // Existing user update
      if (displayName) user.displayName = displayName;
      if (email) user.email = email.toLowerCase();
      if (photoUrl) user.photoUrl = photoUrl;
      if (phone) user.phone = phone;
      if (homeCity !== undefined) user.homeCity = homeCity;
      if (preferredLanguage !== undefined) user.preferredLanguage = preferredLanguage;
      if (travelerType !== undefined) user.travelerType = travelerType;
      if (emergencyContacts !== undefined && Array.isArray(emergencyContacts)) {
        user.emergencyContacts = emergencyContacts;
      }
      if (isOnboarded !== undefined) user.isOnboarded = isOnboarded;

      await user.save();

      return res.status(200).json({
        success: true,
        message: 'User profile synchronized successfully',
        data: user,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get Current Authenticated User Profile
   * GET /api/v1/auth/me
   */
  getProfile: async (req, res, next) => {
    try {
      const uid = req.user.uid;
      let user = await User.findOne({ uid });

      if (!user) {
        // Auto-provision initial profile if first login
        user = await User.create({
          uid,
          email: (req.user.email || '').toLowerCase(),
          displayName: req.user.name || 'Traveler',
          photoUrl: req.user.picture || null,
          phone: req.user.phone || '',
          authProvider: req.user.firebase?.sign_in_provider || 'password',
          isOnboarded: false,
        });
      }

      return res.status(200).json({
        success: true,
        message: 'User profile fetched successfully',
        data: user,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Update Profile Details (Onboarding & Settings)
   * PUT /api/v1/auth/profile
   */
  updateProfile: async (req, res, next) => {
    try {
      const uid = req.user.uid;
      const {
        displayName,
        homeCity,
        preferredLanguage,
        travelerType,
        photoUrl,
        travelPreferences,
        isOnboarded,
      } = req.body;

      const allowedTravelerTypes = [
        'solo',
        'backpacker',
        'family',
        'woman_traveler',
        'luxury',
        'group',
        'other',
      ];

      if (travelerType && !allowedTravelerTypes.includes(travelerType)) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: `Invalid traveler type: "${travelerType}". Allowed values: ${allowedTravelerTypes.join(', ')}`,
          },
          timestamp: new Date().toISOString(),
        });
      }

      const updateFields = {};
      if (displayName !== undefined) updateFields.displayName = displayName;
      if (homeCity !== undefined) updateFields.homeCity = homeCity;
      if (preferredLanguage !== undefined) updateFields.preferredLanguage = preferredLanguage;
      if (travelerType !== undefined) updateFields.travelerType = travelerType;
      if (photoUrl !== undefined) updateFields.photoUrl = photoUrl;
      if (travelPreferences !== undefined) updateFields.travelPreferences = travelPreferences;
      if (isOnboarded !== undefined) updateFields.isOnboarded = isOnboarded;

      const updatedUser = await User.findOneAndUpdate(
        { uid },
        { $set: updateFields },
        { new: true, upsert: true, runValidators: true }
      );

      return res.status(200).json({
        success: true,
        message: 'Profile updated successfully',
        data: updatedUser,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get User Emergency Contacts
   * GET /api/v1/auth/emergency-contacts
   */
  getEmergencyContacts: async (req, res, next) => {
    try {
      const uid = req.user.uid;
      const user = await User.findOne({ uid }).select('emergencyContacts');

      if (!user) {
        return res.status(404).json({
          success: false,
          error: {
            code: 'PROFILE_NOT_FOUND',
            message: 'User profile not found',
          },
          timestamp: new Date().toISOString(),
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Emergency contacts retrieved successfully',
        data: user.emergencyContacts || [],
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Replace or Set Emergency Contacts List
   * PUT /api/v1/auth/emergency-contacts
   */
  updateEmergencyContacts: async (req, res, next) => {
    try {
      const uid = req.user.uid;
      const { contacts } = req.body;

      if (!Array.isArray(contacts)) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Contacts must be an array of objects containing name, phone, and relation.',
          },
          timestamp: new Date().toISOString(),
        });
      }

      for (const contact of contacts) {
        if (!contact.name || !contact.phone) {
          return res.status(400).json({
            success: false,
            error: {
              code: 'VALIDATION_ERROR',
              message: 'Each emergency contact must have a valid name and phone number.',
            },
            timestamp: new Date().toISOString(),
          });
        }
      }

      const user = await User.findOneAndUpdate(
        { uid },
        { $set: { emergencyContacts: contacts } },
        { new: true, upsert: true }
      );

      return res.status(200).json({
        success: true,
        message: 'Emergency contacts updated successfully',
        data: user.emergencyContacts,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Add a single emergency contact
   * POST /api/v1/auth/emergency-contacts
   */
  addEmergencyContact: async (req, res, next) => {
    try {
      const uid = req.user.uid;
      const { name, phone, relation = 'friend', isPrimary = false } = req.body;

      if (!name || !phone) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Contact name and phone number are required',
          },
          timestamp: new Date().toISOString(),
        });
      }

      const user = await User.findOne({ uid });
      if (!user) {
        return res.status(404).json({
          success: false,
          error: {
            code: 'PROFILE_NOT_FOUND',
            message: 'User profile not found',
          },
          timestamp: new Date().toISOString(),
        });
      }

      user.emergencyContacts.push({ name, phone, relation, isPrimary });
      await user.save();

      return res.status(201).json({
        success: true,
        message: 'Emergency contact added successfully',
        data: user.emergencyContacts,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Delete single emergency contact
   * DELETE /api/v1/auth/emergency-contacts/:contactId
   */
  deleteEmergencyContact: async (req, res, next) => {
    try {
      const uid = req.user.uid;
      const { contactId } = req.params;

      const user = await User.findOne({ uid });
      if (!user) {
        return res.status(404).json({
          success: false,
          error: {
            code: 'PROFILE_NOT_FOUND',
            message: 'User profile not found',
          },
          timestamp: new Date().toISOString(),
        });
      }

      user.emergencyContacts = user.emergencyContacts.filter(
        (c) => c._id.toString() !== contactId
      );
      await user.save();

      return res.status(200).json({
        success: true,
        message: 'Emergency contact deleted successfully',
        data: user.emergencyContacts,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = authController;
