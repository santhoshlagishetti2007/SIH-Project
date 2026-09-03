const { test, describe } = require('node:test');
const assert = require('node:assert');
const translationService = require('../src/services/translation.service');
const app = require('../src/app');

describe('Live Translate AI Pipeline & Offline Phrasebook Suite', () => {
  test('TranslationService.translateText translates English to Hindi with romanized transliteration', async () => {
    const result = await translationService.translateText({
      text: 'Hello! How are you?',
      sourceLanguage: 'en',
      targetLanguage: 'hi',
    });

    assert.strictEqual(result.originalText, 'Hello! How are you?');
    assert.ok(result.translatedText.length > 0, 'Should have translated Hindi text');
    assert.ok(result.transliteration.length > 0, 'Should have transliteration');
  });

  test('TranslationService.liveExchange orchestrates STT -> Translate -> TTS synthesis', async () => {
    const exchange = await translationService.liveExchange({
      text: 'Where is the nearest metro station?',
      sourceLanguage: 'en',
      targetLanguage: 'hi',
      autoSpeak: true,
    });

    assert.ok(exchange.id, 'Should have message ID');
    assert.strictEqual(exchange.originalText, 'Where is the nearest metro station?');
    assert.ok(exchange.translatedText.length > 0, 'Should have translated text');
    assert.ok(exchange.audioBase64.length > 0, 'Should include TTS audio content');
  });

  test('TranslationService.getOfflinePhrasebook returns categorized bilingual travel phrases', () => {
    const phrasebook = translationService.getOfflinePhrasebook({
      sourceLanguage: 'en',
      targetLanguage: 'hi',
    });

    assert.ok(Array.isArray(phrasebook), 'Should return list of categories');
    assert.strictEqual(phrasebook.length, 6, 'Should have 6 travel categories');

    for (const cat of phrasebook) {
      assert.ok(cat.category, 'Category should have key');
      assert.ok(cat.categoryName, 'Category should have name');
      assert.ok(Array.isArray(cat.items) && cat.items.length > 0, 'Category should contain phrases');
      assert.ok(cat.items[0].sourceText, 'Item should have source text');
      assert.ok(cat.items[0].translatedText, 'Item should have translated text');
    }
  });

  test('HTTP REST Translation routes return 200 with JSON payloads', async () => {
    const server = app.listen(0);
    const port = server.address().port;

    try {
      // 1. POST /api/v1/translate/live-exchange
      const exchangeRes = await fetch(`http://127.0.0.1:${port}/api/v1/translate/live-exchange`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer mock-dev-token-user-001',
        },
        body: JSON.stringify({
          text: 'How much to go to the city center?',
          sourceLanguage: 'en',
          targetLanguage: 'hi',
        }),
      });
      const exchangeBody = await exchangeRes.json();
      assert.strictEqual(exchangeRes.status, 200);
      assert.strictEqual(exchangeBody.success, true);
      assert.ok(exchangeBody.data.translatedText.length > 0);

      // 2. GET /api/v1/translate/phrasebook
      const phrasebookRes = await fetch(`http://127.0.0.1:${port}/api/v1/translate/phrasebook?sourceLanguage=en&targetLanguage=hi`, {
        headers: {
          Authorization: 'Bearer mock-dev-token-user-001',
        },
      });
      const phraseBody = await phrasebookRes.json();
      assert.strictEqual(phrasebookRes.status, 200);
      assert.strictEqual(phraseBody.success, true);
      assert.strictEqual(phraseBody.data.length, 6);
    } finally {
      server.close();
    }
  });
});
