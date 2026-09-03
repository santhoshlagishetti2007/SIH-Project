import '../../../../core/network/api_result.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/models/translation_models.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_remote_data_source.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource _remoteDataSource;
  final LocalCacheService _cacheService;

  TranslationRepositoryImpl(
    this._remoteDataSource, [
    LocalCacheService? cacheService,
  ]) : _cacheService = cacheService ?? LocalCacheService();

  @override
  Future<ApiResult<TranslationMessage>> performLiveExchange({
    required String text,
    String? audioBase64,
    required String sourceLanguage,
    required String targetLanguage,
    required SpeakerRole sender,
    bool autoSpeak = true,
  }) async {
    final result = await _remoteDataSource.liveExchange(
      text: text,
      audioBase64: audioBase64,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      sender: sender,
      autoSpeak: autoSpeak,
    );

    return result.when(
      success: (msg) => ApiResponseSuccess(msg),
      failure: (_) {
        // Offline / Network Fallback Translation
        final offlineTranslation = _getOfflineFallbackTranslation(
          text: text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );

        return ApiResponseSuccess(
          TranslationMessage(
            id: 'msg_offline_${DateTime.now().millisecondsSinceEpoch}',
            sender: sender,
            originalText: text,
            translatedText: offlineTranslation.translated,
            transliteration: offlineTranslation.transliteration,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            timestamp: DateTime.now(),
          ),
        );
      },
    );
  }

  @override
  Future<ApiResult<List<PhrasebookCategory>>> getPhrasebook({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final remoteRes = await _remoteDataSource.fetchPhrasebook(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    return remoteRes.when(
      success: (data) => ApiResponseSuccess(data),
      failure: (_) => ApiResponseSuccess(_getLocalOfflinePhrasebook(sourceLanguage, targetLanguage)),
    );
  }

  ({String translated, String transliteration}) _getOfflineFallbackTranslation({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    final t = text.toLowerCase().trim();

    if (t.contains('hello') || t.contains('hi')) {
      return (translated: 'नमस्ते!', transliteration: 'Namaste!');
    }
    if (t.contains('thank')) {
      return (translated: 'बहुत-बहुत धन्यवाद!', transliteration: 'Bahut-bahut dhanyavaad!');
    }
    if (t.contains('how much') || t.contains('price') || t.contains('cost')) {
      return (translated: 'यह कितने का है?', transliteration: 'Yeh kitne ka hai?');
    }
    if (t.contains('where is') || t.contains('station') || t.contains('metro')) {
      return (translated: 'नजदीकी स्टेशन कहाँ है?', transliteration: 'Nazdeeki station kahan hai?');
    }
    if (t.contains('water')) {
      return (translated: 'पीने का पानी चाहिए।', transliteration: 'Peene ka paani chahiye.');
    }
    if (t.contains('vegetarian')) {
      return (translated: 'क्या यह शुद्ध शाकाहारी है?', transliteration: 'Kya yeh shuddh shakahari hai?');
    }
    if (t.contains('help') || t.contains('doctor') || t.contains('police')) {
      return (translated: 'कृपया मेरी मदद कीजिए!', transliteration: 'Kripya meri madad kijiye!');
    }

    return (
      translated: '$text [Offline Translation: ${targetLanguage.toUpperCase()}]',
      transliteration: '$text (${targetLanguage.toUpperCase()} Pronunciation)',
    );
  }

  List<PhrasebookCategory> _getLocalOfflinePhrasebook(String src, String tgt) {
    return [
      PhrasebookCategory(
        category: 'greetings',
        categoryName: 'Greetings & Essentials',
        icon: 'handshake',
        items: [
          PhrasebookItem(
            id: 'g1',
            category: 'greetings',
            sourceText: 'Hello! How are you?',
            translatedText: 'नमस्ते! आप कैसे हैं?',
            transliteration: 'Namaste! Aap kaise hain?',
          ),
          PhrasebookItem(
            id: 'g2',
            category: 'greetings',
            sourceText: 'Thank you very much!',
            translatedText: 'बहुत-बहुत धन्यवाद!',
            transliteration: 'Bahut-bahut dhanyavaad!',
          ),
          PhrasebookItem(
            id: 'g3',
            category: 'greetings',
            sourceText: 'Excuse me / Please help me',
            translatedText: 'माफ कीजिए / कृपया मेरी मदद करें',
            transliteration: 'Maaf kijiye / Kripya meri madad karein',
          ),
          PhrasebookItem(
            id: 'g4',
            category: 'greetings',
            sourceText: 'Do you speak English?',
            translatedText: 'क्या आप अंग्रेजी बोलते हैं?',
            transliteration: 'Kya aap angrezi bolte hain?',
          ),
        ],
      ),
      PhrasebookCategory(
        category: 'transport',
        categoryName: 'Transport & Directions',
        icon: 'directions_bus',
        items: [
          PhrasebookItem(
            id: 't1',
            category: 'transport',
            sourceText: 'How much to go to the city center?',
            translatedText: 'शहर के केंद्र तक जाने का कितना किराया है?',
            transliteration: 'Shahar ke kendra tak jaane ka kitna kiraya hai?',
          ),
          PhrasebookItem(
            id: 't2',
            category: 'transport',
            sourceText: 'Please turn on the meter.',
            translatedText: 'कृपया मीटर चालू कर दीजिए।',
            transliteration: 'Kripya meter chaaloo kar dijiye.',
          ),
          PhrasebookItem(
            id: 't3',
            category: 'transport',
            sourceText: 'Where is the nearest metro station?',
            translatedText: 'सबसे नजदीकी मेट्रो स्टेशन कहाँ है?',
            transliteration: 'Sabse nazdeeki metro station kahan hai?',
          ),
          PhrasebookItem(
            id: 't4',
            category: 'transport',
            sourceText: 'Please stop here.',
            translatedText: 'कृपया यहाँ रोक दीजिए।',
            transliteration: 'Kripya yahan rok dijiye.',
          ),
        ],
      ),
      PhrasebookCategory(
        category: 'dining',
        categoryName: 'Dining & Food',
        icon: 'restaurant',
        items: [
          PhrasebookItem(
            id: 'd1',
            category: 'dining',
            sourceText: 'Is this food pure vegetarian?',
            translatedText: 'क्या यह खाना शुद्ध शाकाहारी है?',
            transliteration: 'Kya yeh khana shuddh shakahari hai?',
          ),
          PhrasebookItem(
            id: 'd2',
            category: 'dining',
            sourceText: 'Make it not too spicy please.',
            translatedText: 'कृपया कम मिर्च वाला बनाइए।',
            transliteration: 'Kripya kam mirch wala banaiye.',
          ),
          PhrasebookItem(
            id: 'd3',
            category: 'dining',
            sourceText: 'Can I have bottled drinking water?',
            translatedText: 'क्या मुझे बोतल बंद पीने का पानी मिल सकता है?',
            transliteration: 'Kya mujhe botal band peene ka paani mil sakta hai?',
          ),
          PhrasebookItem(
            id: 'd4',
            category: 'dining',
            sourceText: 'The bill please.',
            translatedText: 'बिल दे दीजिए कृपया।',
            transliteration: 'Bill de dijiye kripya.',
          ),
        ],
      ),
      PhrasebookCategory(
        category: 'shopping',
        categoryName: 'Shopping & Bargaining',
        icon: 'shopping_bag',
        items: [
          PhrasebookItem(
            id: 's1',
            category: 'shopping',
            sourceText: 'How much does this cost?',
            translatedText: 'यह कितने का है?',
            transliteration: 'Yeh kitne ka hai?',
          ),
          PhrasebookItem(
            id: 's2',
            category: 'shopping',
            sourceText: 'Can you give a better discount?',
            translatedText: 'क्या कुछ छूट मिल सकती है?',
            transliteration: 'Kya kuch chhoot mil sakti hai?',
          ),
          PhrasebookItem(
            id: 's3',
            category: 'shopping',
            sourceText: 'Do you accept UPI / Credit Card?',
            translatedText: 'क्या आप यूपीआई / कार्ड स्वीकार करते हैं?',
            transliteration: 'Kya aap UPI / Card sweekar karte hain?',
          ),
        ],
      ),
      PhrasebookCategory(
        category: 'emergency',
        categoryName: 'Emergency & Safety',
        icon: 'health_and_safety',
        items: [
          PhrasebookItem(
            id: 'e1',
            category: 'emergency',
            sourceText: 'I need a doctor / hospital urgently!',
            translatedText: 'मुझे तुरंत डॉक्टर / अस्पताल की आवश्यकता है!',
            transliteration: 'Mujhe turant doctor / aspatal ki aavashyakta hai!',
          ),
          PhrasebookItem(
            id: 'e2',
            category: 'emergency',
            sourceText: 'Where is the nearest pharmacy / chemist?',
            translatedText: 'पास में दवाई की दुकान (केमिस्ट) कहाँ है?',
            transliteration: 'Paas mein dawai ki dukaan kahan hai?',
          ),
          PhrasebookItem(
            id: 'e3',
            category: 'emergency',
            sourceText: 'Please call the tourist police.',
            translatedText: 'कृपया पुलिस को फोन कीजिए।',
            transliteration: 'Kripya police ko phone kijiye.',
          ),
        ],
      ),
      PhrasebookCategory(
        category: 'hotel',
        categoryName: 'Hotel & Stay',
        icon: 'hotel',
        items: [
          PhrasebookItem(
            id: 'h1',
            category: 'hotel',
            sourceText: 'I have a room reservation under my name.',
            translatedText: 'मेरे नाम पर एक कमरा आरक्षित है।',
            transliteration: 'Mere naam par ek kamra aarakshit hai.',
          ),
          PhrasebookItem(
            id: 'h2',
            category: 'hotel',
            sourceText: 'What is the WiFi password?',
            translatedText: 'वाईफाई का पासवर्ड क्या है?',
            transliteration: 'WiFi ka password kya hai?',
          ),
          PhrasebookItem(
            id: 'h3',
            category: 'hotel',
            sourceText: 'Can I leave my luggage here until evening?',
            translatedText: 'क्या मैं शाम तक अपना सामान यहाँ रख सकता हूँ?',
            transliteration: 'Kya main shaam tak apna saaman yahan rakh sakta hoon?',
          ),
        ],
      ),
    ];
  }
}
