const { GoogleGenAI } = require('@google/genai');
const envConfig = require('./env.config');

let geminiClient = null;

/**
 * Initialize Google Gemini AI Client
 */
const initGeminiClient = () => {
  if (geminiClient) return geminiClient;

  if (envConfig.google.geminiApiKey && envConfig.google.geminiApiKey !== 'your_gemini_api_key_here') {
    try {
      geminiClient = new GoogleGenAI({ apiKey: envConfig.google.geminiApiKey });
      console.log('[Google AI] Gemini AI client initialized.');
      return geminiClient;
    } catch (error) {
      console.warn(`[Google AI] Gemini client init warning: ${error.message}`);
    }
  } else {
    console.log('[Google AI] Gemini API key not provided. AI companion will run with mock responses in dev.');
  }

  return null;
};

/**
 * Get Google AI state
 */
const getGoogleAIState = () => {
  return {
    isConfigured: !!(envConfig.google.geminiApiKey && envConfig.google.geminiApiKey !== 'your_gemini_api_key_here'),
    hasMapsKey: !!(envConfig.google.mapsApiKey && envConfig.google.mapsApiKey !== 'your_google_maps_api_key_here'),
  };
};

module.exports = {
  initGeminiClient,
  getGoogleAIState,
};
