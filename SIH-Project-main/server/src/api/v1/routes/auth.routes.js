const express = require('express');
const authController = require('../controllers/auth.controller');
const { verifyAuth } = require('../middlewares/auth.middleware');

const router = express.Router();

// All auth routes require valid Firebase ID Token authentication
router.use(verifyAuth);

/**
 * @route   POST /api/v1/auth/sync-profile
 * @desc    Synchronize Firebase user with MongoDB profile
 * @access  Protected
 */
router.post('/sync-profile', authController.syncProfile);

/**
 * @route   GET /api/v1/auth/me
 * @desc    Get current authenticated user profile
 * @access  Protected
 */
router.get('/me', authController.getProfile);

/**
 * @route   PUT /api/v1/auth/profile
 * @desc    Update user profile & onboarding data
 * @access  Protected
 */
router.put('/profile', authController.updateProfile);

/**
 * @route   GET /api/v1/auth/emergency-contacts
 * @desc    Get user emergency contacts list
 * @access  Protected
 */
router.get('/emergency-contacts', authController.getEmergencyContacts);

/**
 * @route   PUT /api/v1/auth/emergency-contacts
 * @desc    Batch replace/set emergency contacts
 * @access  Protected
 */
router.put('/emergency-contacts', authController.updateEmergencyContacts);

/**
 * @route   POST /api/v1/auth/emergency-contacts
 * @desc    Add single emergency contact
 * @access  Protected
 */
router.post('/emergency-contacts', authController.addEmergencyContact);

/**
 * @route   DELETE /api/v1/auth/emergency-contacts/:contactId
 * @desc    Delete single emergency contact
 * @access  Protected
 */
router.delete('/emergency-contacts/:contactId', authController.deleteEmergencyContact);

module.exports = router;
