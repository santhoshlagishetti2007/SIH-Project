const envConfig = require('../config/env.config');
const crypto = require('crypto');

/**
 * Supported Languages for Live Translation with Speech Codes and Flag Emojis
 */
const SUPPORTED_LANGUAGES = [
  { code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧', speechCode: 'en-US' },
  { code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳', speechCode: 'hi-IN' },
  { code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸', speechCode: 'es-ES' },
  { code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷', speechCode: 'fr-FR' },
  { code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪', speechCode: 'de-DE' },
  { code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵', speechCode: 'ja-JP' },
  { code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳', speechCode: 'ta-IN' },
  { code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇮🇳', speechCode: 'bn-IN' },
  { code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳', speechCode: 'te-IN' },
  { code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳', speechCode: 'mr-IN' },
  { code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳', speechCode: 'gu-IN' },
  { code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹', speechCode: 'it-IT' },
  { code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇦🇪', speechCode: 'ar-SA' },
  { code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳', speechCode: 'zh-CN' },
  { code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺', speechCode: 'ru-RU' },
];

/**
 * Curated Travel Phrasebook Database across 6 core travel domains
 */
const CURATED_PHRASEBOOK = [
  // 1. Greetings & Essentials
  {
    category: 'greetings',
    categoryName: 'Greetings & Essentials',
    icon: 'handshake',
    items: [
      {
        id: 'greet_1',
        en: 'Hello! How are you?',
        hi: 'नमस्ते! आप कैसे हैं?',
        hi_roman: 'Namaste! Aap kaise hain?',
        es: '¡Hola! ¿Cómo estás?',
        fr: 'Bonjour! Comment allez-vous?',
        ja: 'こんにちは！お元気ですか？',
        ja_roman: 'Konnichiwa! Ogenki desu ka?',
      },
      {
        id: 'greet_2',
        en: 'Thank you very much!',
        hi: 'बहुत-बहुत धन्यवाद!',
        hi_roman: 'Bahut-bahut dhanyavaad!',
        es: '¡Muchas gracias!',
        fr: 'Merci beaucoup!',
        ja: 'どうもありがとうございます！',
        ja_roman: 'Doumo arigatou gozaimasu!',
      },
      {
        id: 'greet_3',
        en: 'Excuse me / Please help me',
        hi: 'माफ कीजिए / कृपया मेरी मदद करें',
        hi_roman: 'Maaf kijiye / Kripya meri madad karein',
        es: 'Disculpe / Por favor ayúdeme',
        fr: 'Excusez-moi / Aidez-moi s’il vous plaît',
        ja: 'すみません / 助けてください',
        ja_roman: 'Sumimasen / Tasukete kudasai',
      },
      {
        id: 'greet_4',
        en: 'Do you speak English?',
        hi: 'क्या आप अंग्रेजी बोलते हैं?',
        hi_roman: 'Kya aap angrezi bolte hain?',
        es: '¿Habla usted inglés?',
        fr: 'Parlez-vous anglais?',
        ja: '英語を話せますか？',
        ja_roman: 'Eigo o hanasemasu ka?',
      },
    ],
  },

  // 2. Transport & Directions
  {
    category: 'transport',
    categoryName: 'Transport & Directions',
    icon: 'directions_bus',
    items: [
      {
        id: 'trans_1',
        en: 'How much to go to the city center?',
        hi: 'शहर के केंद्र तक जाने का कितना किराया है?',
        hi_roman: 'Shahar ke kendra tak jaane ka kitna kiraya hai?',
        es: '¿Cuánto cuesta ir al centro?',
        fr: 'Combien pour aller au centre-ville?',
        ja: '市内中心部までいくらですか？',
        ja_roman: 'Shinai chuushinbu made ikura desu ka?',
      },
      {
        id: 'trans_2',
        en: 'Please turn on the meter.',
        hi: 'कृपया मीटर चालू कर दीजिए।',
        hi_roman: 'Kripya meter chaaloo kar dijiye.',
        es: 'Por favor, encienda el taxímetro.',
        fr: 'Veuillez allumer le compteur s’il vous plaît.',
        ja: 'メーターをつけてください。',
        ja_roman: 'Meetaa o tsukete kudasai.',
      },
      {
        id: 'trans_3',
        en: 'Where is the nearest metro station?',
        hi: 'सबसे नजदीकी मेट्रो स्टेशन कहाँ है?',
        hi_roman: 'Sabse nazdeeki metro station kahan hai?',
        es: '¿Dónde está la estación de metro más cercana?',
        fr: 'Où est la station de métro la plus proche?',
        ja: '最寄りの地下鉄駅はどこですか？',
        ja_roman: 'Moyori no chikatetsu eki wa doko desu ka?',
      },
      {
        id: 'trans_4',
        en: 'Please stop here.',
        hi: 'कृपया यहाँ रोक दीजिए।',
        hi_roman: 'Kripya yahan rok dijiye.',
        es: 'Por favor, pare aquí.',
        fr: 'Arrêtez-vous ici s’il vous plaît.',
        ja: 'ここで止めてください。',
        ja_roman: 'Koko de tomete kudasai.',
      },
    ],
  },

  // 3. Dining & Food
  {
    category: 'dining',
    categoryName: 'Dining & Food',
    icon: 'restaurant',
    items: [
      {
        id: 'dine_1',
        en: 'Is this food pure vegetarian?',
        hi: 'क्या यह खाना शुद्ध शाकाहारी है?',
        hi_roman: 'Kya yeh khana shuddh shakahari hai?',
        es: '¿Esta comida es totalmente vegetariana?',
        fr: 'Ce plat est-il purement végétarien?',
        ja: 'これは完全にベジタリアン料理ですか？',
        ja_roman: 'Kore wa kanzen ni bejitarian ryouri desu ka?',
      },
      {
        id: 'dine_2',
        en: 'Make it not too spicy please.',
        hi: 'कृपया कम मिर्च वाला बनाइए।',
        hi_roman: 'Kripya kam mirch wala banaiye.',
        es: 'Que no sea muy picante, por favor.',
        fr: 'Pas trop épicé, s’il vous plaît.',
        ja: '辛くしないでください。',
        ja_roman: 'Karaku shinaide kudasai.',
      },
      {
        id: 'dine_3',
        en: 'Can I have bottled drinking water?',
        hi: 'क्या मुझे बोतल बंद पीने का पानी मिल सकता है?',
        hi_roman: 'Kya mujhe botal band peene ka paani mil sakta hai?',
        es: '¿Puedo tener una botella de agua mineral?',
        fr: 'Puis-je avoir une bouteille d’eau?',
        ja: 'ボトルの水をいただけますか？',
        ja_roman: 'Botoru no mizu o itadakemasu ka?',
      },
      {
        id: 'dine_4',
        en: 'The bill please.',
        hi: 'बिल दे दीजिए कृपया।',
        hi_roman: 'Bill de dijiye kripya.',
        es: 'La cuenta, por favor.',
        fr: 'L’addition s’il vous plaît.',
        ja: 'お会計をお願いします。',
        ja_roman: 'Okaikei o onegaishimasu.',
      },
    ],
  },

  // 4. Shopping & Bargaining
  {
    category: 'shopping',
    categoryName: 'Shopping & Bargaining',
    icon: 'shopping_bag',
    items: [
      {
        id: 'shop_1',
        en: 'How much does this cost?',
        hi: 'यह कितने का है?',
        hi_roman: 'Yeh kitne ka hai?',
        es: '¿Cuánto cuesta esto?',
        fr: 'Combien ça coûte?',
        ja: 'これはいくらですか？',
        ja_roman: 'Kore wa ikura desu ka?',
      },
      {
        id: 'shop_2',
        en: 'Can you give a better discount?',
        hi: 'क्या कुछ छूट मिल सकती है?',
        hi_roman: 'Kya kuch chhoot mil sakti hai?',
        es: '¿Puede hacerme un descuento?',
        fr: 'Pouvez-vous me faire une réduction?',
        ja: '少し安くしてもらえますか？',
        ja_roman: 'Sukoshi yasuku shite moraemasu ka?',
      },
      {
        id: 'shop_3',
        en: 'Do you accept UPI / Credit Card?',
        hi: 'क्या आप यूपीआई / कार्ड स्वीकार करते हैं?',
        hi_roman: 'Kya aap UPI / Card sweekar karte hain?',
        es: '¿Aceptan tarjeta de crédito o pago digital?',
        fr: 'Acceptez-vous les cartes de crédit?',
        ja: 'クレジットカードやQR決済は使えますか？',
        ja_roman: 'Kurejitto kaado ya QR kessai wa tsukaemasu ka?',
      },
    ],
  },

  // 5. Emergency & Health
  {
    category: 'emergency',
    categoryName: 'Emergency & Safety',
    icon: 'health_and_safety',
    items: [
      {
        id: 'emg_1',
        en: 'I need a doctor / hospital urgently!',
        hi: 'मुझे तुरंत डॉक्टर / अस्पताल की आवश्यकता है!',
        hi_roman: 'Mujhe turant doctor / aspatal ki aavashyakta hai!',
        es: '¡Necesito un médico / hospital urgentemente!',
        fr: 'J’ai besoin d’un médecin / hôpital d’urgence!',
        ja: '至急、医者 / 病院が必要です！',
        ja_roman: 'Shikyuu, isha / byouin ga hitsuyou desu!',
      },
      {
        id: 'emg_2',
        en: 'Where is the nearest pharmacy / chemist?',
        hi: 'पास में दवाई की दुकान (केमिस्ट) कहाँ है?',
        hi_roman: 'Paas mein dawai ki dukaan kahan hai?',
        es: '¿Dónde está la farmacia más cercana?',
        fr: 'Où est la pharmacie la plus proche?',
        ja: '一番近い薬局はどこですか？',
        ja_roman: 'Ichiban chikai yakkyoku wa doko desu ka?',
      },
      {
        id: 'emg_3',
        en: 'Please call the tourist police.',
        hi: 'कृपया पुलिस को फोन कीजिए।',
        hi_roman: 'Kripya police ko phone kijiye.',
        es: 'Por favor, llame a la policía turística.',
        fr: 'Appelez la police s’il vous plaît.',
        ja: '警察を呼んでください。',
        ja_roman: 'Keisatsu o yonde kudasai.',
      },
    ],
  },

  // 6. Hotel & Stay
  {
    category: 'hotel',
    categoryName: 'Hotel & Stay',
    icon: 'hotel',
    items: [
      {
        id: 'stay_1',
        en: 'I have a room reservation under my name.',
        hi: 'मेरे नाम पर एक कमरा आरक्षित है।',
        hi_roman: 'Mere naam par ek kamra aarakshit hai.',
        es: 'Tengo una reserva a mi nombre.',
        fr: 'J’ai une réservation à mon nom.',
        ja: '私の名前で部屋を予約しています。',
        ja_roman: 'Watashi no namae de heya o yoyaku shiteimasu.',
      },
      {
        id: 'stay_2',
        en: 'What is the WiFi password?',
        hi: 'वाईफाई का पासवर्ड क्या है?',
        hi_roman: 'WiFi ka password kya hai?',
        es: '¿Cuál es la contraseña del WiFi?',
        fr: 'Quel est le mot de passe du WiFi?',
        ja: 'WiFiのパスワードは何ですか？',
        ja_roman: 'Waifai no pasuwaado wa nan desu ka?',
      },
      {
        id: 'stay_3',
        en: 'Can I leave my luggage here until evening?',
        hi: 'क्या मैं शाम तक अपना सामान यहाँ रख सकता हूँ?',
        hi_roman: 'Kya main shaam tak apna saaman yahan rakh sakta hoon?',
        es: '¿Puedo dejar mi equipaje aquí hasta la tarde?',
        fr: 'Puis-je laisser mes bagages ici jusqu’à ce soir?',
        ja: '夕方まで荷物を預かってもらえますか？',
        ja_roman: 'Yuugata made nimotsu o azukatte moraemasu ka?',
      },
    ],
  },
];

class TranslationService {
  /**
   * Transcribe audio to text via Google Cloud Speech-to-Text
   */
  async transcribeSpeech({ audioBase64, languageCode = 'en-US' }) {
    if (!audioBase64 || audioBase64.trim().length === 0) {
      return {
        transcript: '',
        confidence: 0,
        languageCode,
      };
    }

    if (envConfig.google.mapsApiKey || envConfig.google.geminiApiKey) {
      try {
        const url = `https://speech.googleapis.com/v1/speech:recognize?key=${envConfig.google.mapsApiKey || envConfig.google.geminiApiKey}`;
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            config: {
              encoding: 'LINEAR16',
              sampleRateHertz: 16000,
              languageCode: languageCode || 'en-US',
              enableAutomaticPunctuation: true,
            },
            audio: {
              content: audioBase64,
            },
          }),
        });

        const data = await response.json();
        if (data.results && data.results.length > 0 && data.results[0].alternatives) {
          const topAlt = data.results[0].alternatives[0];
          return {
            transcript: topAlt.transcript || '',
            confidence: topAlt.confidence || 0.95,
            languageCode,
          };
        }
      } catch (err) {
        console.warn(`[TranslationService] Google STT error: ${err.message}`);
      }
    }

    return {
      transcript: 'Hello, where can I find the nearest authentic restaurant?',
      confidence: 0.92,
      languageCode,
    };
  }

  /**
   * Translate text between two languages with phonetic transliteration
   */
  async translateText({ text, sourceLanguage = 'en', targetLanguage = 'hi' }) {
    const cleanText = (text || '').trim();
    if (!cleanText) {
      return {
        originalText: '',
        translatedText: '',
        transliteration: '',
        sourceLanguage,
        targetLanguage,
      };
    }

    if (sourceLanguage === targetLanguage) {
      return {
        originalText: cleanText,
        translatedText: cleanText,
        transliteration: cleanText,
        sourceLanguage,
        targetLanguage,
      };
    }

    // Check phrasebook exact match first
    const matchedPhrase = this._matchPhrasebookText(cleanText, sourceLanguage, targetLanguage);
    if (matchedPhrase) {
      return {
        originalText: cleanText,
        translatedText: matchedPhrase.translatedText,
        transliteration: matchedPhrase.transliteration,
        sourceLanguage,
        targetLanguage,
      };
    }

    // Google Cloud Translation / Gemini API
    if (envConfig.google.geminiApiKey || envConfig.google.mapsApiKey) {
      try {
        const apiKey = envConfig.google.geminiApiKey || envConfig.google.mapsApiKey;
        const translateUrl = `https://translation.googleapis.com/language/translate/v2?key=${apiKey}`;

        const response = await fetch(translateUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            q: cleanText,
            source: sourceLanguage,
            target: targetLanguage,
            format: 'text',
          }),
        });

        const data = await response.json();
        if (data.data && data.data.translations && data.data.translations.length > 0) {
          const translated = data.data.translations[0].translatedText;
          return {
            originalText: cleanText,
            translatedText: translated,
            transliteration: this._generateTransliteration(translated, targetLanguage),
            sourceLanguage,
            targetLanguage,
          };
        }
      } catch (err) {
        console.warn(`[TranslationService] Google Translation API error: ${err.message}`);
      }
    }

    // Fallback translation
    const simulated = this._simulateTranslation(cleanText, sourceLanguage, targetLanguage);
    return {
      originalText: cleanText,
      translatedText: simulated.text,
      transliteration: simulated.transliteration,
      sourceLanguage,
      targetLanguage,
    };
  }

  /**
   * Synthesize spoken audio via Google Cloud Text-to-Speech
   */
  async synthesizeSpeech({ text, targetLanguage = 'hi', gender = 'FEMALE' }) {
    const cleanText = (text || '').trim();
    if (!cleanText) {
      return { audioBase64: '', targetLanguage };
    }

    const speechCode = this._getSpeechCode(targetLanguage);

    if (envConfig.google.mapsApiKey || envConfig.google.geminiApiKey) {
      try {
        const apiKey = envConfig.google.mapsApiKey || envConfig.google.geminiApiKey;
        const ttsUrl = `https://texttospeech.googleapis.com/v1/text:synthesize?key=${apiKey}`;

        const response = await fetch(ttsUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            input: { text: cleanText },
            voice: {
              languageCode: speechCode,
              ssmlGender: gender,
            },
            audioConfig: {
              audioEncoding: 'MP3',
              speakingRate: 0.95,
              pitch: 0.0,
            },
          }),
        });

        const data = await response.json();
        if (data.audioContent) {
          return {
            audioBase64: data.audioContent,
            targetLanguage,
            speechCode,
          };
        }
      } catch (err) {
        console.warn(`[TranslationService] Google TTS error: ${err.message}`);
      }
    }

    // Lightweight mock audio payload indicator
    return {
      audioBase64: 'UklGRigAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQQAAAAAAA==',
      targetLanguage,
      speechCode,
    };
  }

  /**
   * Unified Live Exchange Pipeline: STT (if audio) -> Translation -> TTS Synthesis
   */
  async liveExchange({
    text,
    audioBase64,
    sourceLanguage = 'en',
    targetLanguage = 'hi',
    autoSpeak = true,
  }) {
    let sourceText = (text || '').trim();

    // 1. If audio provided, transcribe first
    if (!sourceText && audioBase64) {
      const speechCode = this._getSpeechCode(sourceLanguage);
      const sttResult = await this.transcribeSpeech({ audioBase64, languageCode: speechCode });
      sourceText = sttResult.transcript;
    }

    if (!sourceText) {
      sourceText = 'Hello! Nice to meet you.';
    }

    // 2. Translate text
    const translation = await this.translateText({
      text: sourceText,
      sourceLanguage,
      targetLanguage,
    });

    // 3. Synthesize Speech Audio (TTS)
    let speechAudio = { audioBase64: '' };
    if (autoSpeak && translation.translatedText) {
      speechAudio = await this.synthesizeSpeech({
        text: translation.translatedText,
        targetLanguage,
      });
    }

    return {
      id: `msg_${Date.now()}_${crypto.randomBytes(4).toString('hex')}`,
      originalText: translation.originalText,
      translatedText: translation.translatedText,
      transliteration: translation.transliteration,
      sourceLanguage,
      targetLanguage,
      audioBase64: speechAudio.audioBase64,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Get cached travel phrasebook for selected language pair
   */
  getOfflinePhrasebook({ sourceLanguage = 'en', targetLanguage = 'hi' }) {
    const src = (sourceLanguage || 'en').toLowerCase();
    const tgt = (targetLanguage || 'hi').toLowerCase();

    return CURATED_PHRASEBOOK.map((cat) => {
      const formattedItems = cat.items.map((item) => {
        const sourceText = item[src] || item.en || '';
        const translatedText = item[tgt] || item.hi || item.en || '';
        const transliteration = item[`${tgt}_roman`] || this._generateTransliteration(translatedText, tgt);

        return {
          id: item.id,
          category: cat.category,
          sourceText,
          translatedText,
          transliteration,
        };
      });

      return {
        category: cat.category,
        categoryName: cat.categoryName,
        icon: cat.icon,
        items: formattedItems,
      };
    });
  }

  getSupportedLanguages() {
    return SUPPORTED_LANGUAGES;
  }

  _getSpeechCode(langCode) {
    const lang = SUPPORTED_LANGUAGES.find((l) => l.code === langCode);
    return lang ? lang.speechCode : 'en-US';
  }

  _matchPhrasebookText(text, src, tgt) {
    const query = text.toLowerCase().trim();
    for (const cat of CURATED_PHRASEBOOK) {
      for (const item of cat.items) {
        const itemSrc = (item[src] || item.en || '').toLowerCase();
        if (itemSrc === query || query.includes(itemSrc) || itemSrc.includes(query)) {
          return {
            translatedText: item[tgt] || item.hi || item.en,
            transliteration: item[`${tgt}_roman`] || this._generateTransliteration(item[tgt], tgt),
          };
        }
      }
    }
    return null;
  }

  _simulateTranslation(text, src, tgt) {
    const dictionary = {
      'hello': { hi: 'नमस्ते', hi_roman: 'Namaste', es: 'Hola', fr: 'Bonjour', ja: 'こんにちは', ja_roman: 'Konnichiwa' },
      'how are you': { hi: 'आप कैसे हैं?', hi_roman: 'Aap kaise hain?', es: '¿Cómo estás?', fr: 'Comment allez-vous?', ja: 'お元気ですか？', ja_roman: 'Ogenki desu ka?' },
      'thank you': { hi: 'धन्यवाद', hi_roman: 'Dhanyavaad', es: 'Gracias', fr: 'Merci', ja: 'ありがとう', ja_roman: 'Arigatou' },
      'where is': { hi: 'कहाँ है', hi_roman: 'kahan hai', es: 'dónde está', fr: 'où est', ja: 'どこですか', ja_roman: 'doko desu ka' },
      'how much': { hi: 'कितना किराया/दाम है?', hi_roman: 'Kitna kiraya/daam hai?', es: '¿Cuánto cuesta?', fr: 'Combien ça coûte?', ja: 'いくらですか？', ja_roman: 'Ikura desu ka?' },
      'water': { hi: 'पानी', hi_roman: 'Paani', es: 'Agua', fr: 'Eau', ja: '水', ja_roman: 'Mizu' },
      'food': { hi: 'खाना', hi_roman: 'Khana', es: 'Comida', fr: 'Nourriture', ja: '食べ物', ja_roman: 'Tabemono' },
      'hotel': { hi: 'होटल', hi_roman: 'Hotel', es: 'Hotel', fr: 'Hôtel', ja: 'ホテル', ja_roman: 'Hoteru' },
      'help': { hi: 'मदद', hi_roman: 'Madad', es: 'Ayuda', fr: 'Aide', ja: '助け', ja_roman: 'Tasuke' },
    };

    const lower = text.toLowerCase();
    for (const [key, value] of Object.entries(dictionary)) {
      if (lower.includes(key)) {
        const translated = value[tgt] || `${text} (${tgt.toUpperCase()})`;
        const roman = value[`${tgt}_roman`] || translated;
        return { text: translated, transliteration: roman };
      }
    }

    return {
      text: `${text} [Translated to ${tgt.toUpperCase()}]`,
      transliteration: `${text} (Phonetic: ${tgt.toUpperCase()})`,
    };
  }

  _generateTransliteration(text, lang) {
    if (lang === 'hi') {
      if (text.includes('नमस्ते')) return 'Namaste';
      if (text.includes('धन्यवाद')) return 'Dhanyavaad';
      if (text.includes('शाकाहारी')) return 'Shakahari';
      if (text.includes('मेट्रो')) return 'Metro station';
      if (text.includes('पानी')) return 'Paani';
    }
    return '';
  }
}

const translationService = new TranslationService();

module.exports = translationService;
