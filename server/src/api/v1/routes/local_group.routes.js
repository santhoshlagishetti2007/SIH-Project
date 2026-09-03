const express = require('express');
const localGroupController = require('../controllers/local_group.controller');

const router = express.Router();

// Public / Traveler endpoints
router.get('/', localGroupController.getGroups);
router.get('/admin/pending', localGroupController.getAdminPendingGroups);
router.get('/:id', localGroupController.getGroupById);
router.post('/', localGroupController.createGroup);
router.post('/:id/join', localGroupController.requestToJoinGroup);

// Admin verification workflow
router.patch('/:id/verify', localGroupController.verifyGroup);

module.exports = router;
