const translationService = require('../../../services/translation.service');

const translateController = {
  /**
   * Unified Live Exchange Pipeline (STT -> Translate -> TTS)
   * POST /api/v1/translate/live-exchange
   */
  async liveExchange(req, res, next) {
    try {
      const { text, audioBase64, sourceLanguage, targetLanguage, autoSpeak } = req.body;

      const result = await translationService.liveExchange({
        text,
        audioBase64,
        sourceLanguage: sourceLanguage || 'en',
        targetLanguage: targetLanguage || 'hi',
        autoSpeak: autoSpeak !== false,
      });

      return res.status(200).json({
        success: true,
        message: 'Live translation exchange processed successfully',
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Translate text
   * POST /api/v1/translate/translate-text
   */
  async translateText(req, res, next) {
    try {
      const { text, sourceLanguage, targetLanguage } = req.body;

      const result = await translationService.translateText({
        text,
        sourceLanguage: sourceLanguage || 'en',
        targetLanguage: targetLanguage || 'hi',
      });

      return res.status(200).json({
        success: true,
        message: 'Text translated successfully',
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Transcribe Speech to Text
   * POST /api/v1/translate/speech-to-text
   */
  async speechToText(req, res, next) {
    try {
      const { audioBase64, languageCode } = req.body;

      const result = await translationService.transcribeSpeech({
        audioBase64,
        languageCode: languageCode || 'en-US',
      });

      return res.status(200).json({
        success: true,
        message: 'Speech transcribed successfully',
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Synthesize Text to Speech
   * POST /api/v1/translate/text-to-speech
   */
  async textToSpeech(req, res, next) {
    try {
      const { text, targetLanguage, gender } = req.body;

      const result = await translationService.synthesizeSpeech({
        text,
        targetLanguage: targetLanguage || 'hi',
        gender: gender || 'FEMALE',
      });

      return res.status(200).json({
        success: true,
        message: 'Speech synthesized successfully',
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Get cached offline travel phrasebook
   * GET /api/v1/translate/phrasebook
   */
  async getPhrasebook(req, res, next) {
    try {
      const { sourceLanguage, targetLanguage } = req.query;

      const phrasebook = translationService.getOfflinePhrasebook({
        sourceLanguage: sourceLanguage || 'en',
        targetLanguage: targetLanguage || 'hi',
      });

      return res.status(200).json({
        success: true,
        message: 'Travel phrasebook retrieved successfully',
        data: phrasebook,
        languages: translationService.getSupportedLanguages(),
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = translateController;
