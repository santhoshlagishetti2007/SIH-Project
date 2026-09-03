const express = require('express');
const translateController = require('../controllers/translate.controller');
const { verifyAuth } = require('../middlewares/auth.middleware');

const router = express.Router();

// Apply auth middleware to all translation endpoints
router.use(verifyAuth);

// Live unified conversation exchange (STT -> Translation -> TTS)
router.post('/live-exchange', translateController.liveExchange);

// Individual micro-service translation endpoints
router.post('/translate-text', translateController.translateText);
router.post('/speech-to-text', translateController.speechToText);
router.post('/text-to-speech', translateController.textToSpeech);

// Offline travel phrasebook
router.get('/phrasebook', translateController.getPhrasebook);

module.exports = router;
